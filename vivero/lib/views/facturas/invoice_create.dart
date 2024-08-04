import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:logger/logger.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../models/Invoice.dart';
import '../../models/InvoiceDetail.dart';
import '../../models/customer.dart';
import '../../models/product.dart';
import '../../services/invoice_service.dart';
import '../../widgets/invoice_card.dart';
import '../customers/customers_list_view.dart';
import '../products/products_list_view.dart';

class InvoiceScreen extends StatefulWidget {
  final Invoice? invoice;

  const InvoiceScreen({Key? key, this.invoice}) : super(key: key);

  @override
  _InvoiceScreenState createState() => _InvoiceScreenState();
}

class _InvoiceScreenState extends State<InvoiceScreen> {
  late Invoice invoice;
  Color themeColor = Colors.green.shade600;
  final TextEditingController _receivedController = TextEditingController();
  final TextEditingController _customerIdController = TextEditingController();
  final TextEditingController _customerNameController = TextEditingController();
  final TextEditingController _invoiceDateController = TextEditingController();
  String _changeText = '';
  var logger = Logger();

  FlutterBlue flutterBlue = FlutterBlue.instance;
  List<BluetoothDevice> devicesList = [];
  BluetoothDevice? selectedDevice;

  @override
  void initState() {
    super.initState();
    invoice = widget.invoice ??
        Invoice(
          id: '',
          date: Timestamp.now(),
          customerId: '',
          customerName: '',
          details: [],
          type: InvoiceType.cash,
          total: 0.0,
          balance: 0.0,
          paidAmount: 0.0,
          changeGiven: 0.0,
        );

    _customerIdController.text = invoice.customerId;
    _customerNameController.text = invoice.customerName;
    _invoiceDateController.text =
        DateFormat('yyyy-MM-dd').format(invoice.date.toDate());

    _requestPermissions();
  }

  void _requestPermissions() async {
    Map<Permission, PermissionStatus> statuses = await [
      Permission.bluetooth,
      Permission.bluetoothConnect,
      Permission.bluetoothScan,
      Permission.location,
    ].request();

    if (statuses[Permission.bluetoothConnect]?.isGranted ??
        false && statuses[Permission.bluetoothScan]!.isGranted) {
      _scanForDevices();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Permisos de Bluetooth y ubicación no concedidos.')),
      );
    }
  }

  void _scanForDevices() {
    flutterBlue.startScan(timeout: Duration(seconds: 4));
    flutterBlue.scanResults.listen((results) {
      setState(() {
        devicesList = results.map((result) => result.device).toList();
      });
    });
  }

  double _totalInvoice() {
    return invoice.details
        .fold(0, (sum, item) => sum + item.price * item.quantity);
  }

  void _deleteDetail(InvoiceDetail detail) {
    setState(() {
      invoice = invoice.copyWith(
        details: invoice.details
            .where((d) => d.productId != detail.productId)
            .toList(),
      );
    });
  }

  void _calculateChange() {
    double received = double.tryParse(_receivedController.text) ?? 0.0;
    double totalInvoice = _totalInvoice();
    double change = received - totalInvoice;
    if (change >= 0) {
      _changeText = NumberFormat('#,##0.00', 'en_US').format(change);
    } else {
      _changeText = 'Insuficiente';
    }
    setState(() {
      invoice = invoice.copyWith(
          paidAmount: received, changeGiven: change >= 0 ? change : 0.0);
    });
  }

  void _resetInvoiceScreen() {
    setState(() {
      invoice = Invoice(
        id: '',
        date: Timestamp.now(),
        customerId: '',
        customerName: '',
        details: [],
        type: InvoiceType.cash,
        total: 0.0,
        balance: 0.0,
        paidAmount: 0.0,
        changeGiven: 0.0,
      );
      _receivedController.clear();
      _customerIdController.clear();
      _customerNameController.clear();
      _invoiceDateController.clear();
      _changeText = '';
    });
  }

  void _showErrorDialog(String errorMessage) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Error"),
          content: Text(errorMessage),
          actions: <Widget>[
            TextButton(
              child: const Text('Cerrar'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _showInvoiceDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setStateDialog) {
            return AlertDialog(
              title: const Text('Registro de Información'),
              content: SingleChildScrollView(
                child: Column(
                  children: <Widget>[
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            'ID del Cliente: ${invoice.customerId}',
                            style: const TextStyle(fontSize: 16),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.search),
                          onPressed: () async {
                            final Customer? selectedCustomer =
                                await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const CustomerListView(
                                    isSelectionMode: true),
                              ),
                            );
                            if (selectedCustomer != null) {
                              setStateDialog(() {
                                invoice = invoice.copyWith(
                                  customerId: selectedCustomer.id,
                                  customerName: selectedCustomer.name,
                                );
                                _customerIdController.text =
                                    selectedCustomer.id;
                                _customerNameController.text =
                                    selectedCustomer.name;
                              });
                            }
                          },
                        ),
                      ],
                    ),
                    TextFormField(
                      controller: _customerNameController,
                      decoration: const InputDecoration(
                          labelText: 'Nombre del Cliente'),
                    ),
                    TextFormField(
                      controller: _invoiceDateController,
                      decoration: const InputDecoration(
                        labelText: 'Fecha de la Factura',
                        suffixIcon: Icon(Icons.calendar_today),
                      ),
                      readOnly: true,
                      onTap: () async {
                        DateTime? pickedDate = await showDatePicker(
                          context: context,
                          initialDate: invoice.date.toDate(),
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2100),
                        );
                        if (pickedDate != null) {
                          setStateDialog(() {
                            invoice = invoice.copyWith(
                                date: Timestamp.fromDate(pickedDate));
                            _invoiceDateController.text =
                                DateFormat('yyyy-MM-dd').format(pickedDate);
                          });
                        }
                      },
                    ),
                    DropdownButton<InvoiceType>(
                      value: invoice.type,
                      onChanged: (InvoiceType? newValue) {
                        if (newValue != null) {
                          setStateDialog(() {
                            invoice = invoice.copyWith(type: newValue);
                          });
                        }
                      },
                      items: InvoiceType.values.map((InvoiceType type) {
                        return DropdownMenuItem<InvoiceType>(
                          value: type,
                          child: Text(type.toString().split('.').last),
                        );
                      }).toList(),
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: DropdownButton<BluetoothDevice>(
                            hint: const Text('Seleccionar impresora',
                                style: TextStyle(color: Colors.black)),
                            value: selectedDevice,
                            onChanged: (BluetoothDevice? newValue) {
                              setState(() {
                                selectedDevice = newValue;
                              });
                            },
                            items: devicesList.map((BluetoothDevice device) {
                              return DropdownMenuItem<BluetoothDevice>(
                                value: device,
                                child: Text(device.name,
                                    overflow: TextOverflow.ellipsis),
                              );
                            }).toList(),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.refresh),
                          onPressed: _scanForDevices,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              actions: <Widget>[
                TextButton(
                  child: const Text('Cancelar'),
                  onPressed: () => Navigator.of(context).pop(),
                ),
                TextButton(
                  child: const Text('Guardar'),
                  onPressed: () {
                    setState(() {});
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _navigateAndSelectProduct() async {
    final Product? selectedProduct = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const ProductListView(isSelectionMode: true),
      ),
    );
    if (selectedProduct != null) {
      _addProductToInvoice(selectedProduct);
    }
  }

  void _addProductToInvoice(Product product) {
    var existingDetail = invoice.details
        .firstWhereOrNull((detail) => detail.productId == product.id);

    if (existingDetail != null) {
      setState(() {
        existingDetail.quantity += 1;
      });
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content:
            Text("Producto Existente se incrementó: ${existingDetail.name}"),
        duration: const Duration(seconds: 2),
      ));
    } else {
      setState(() {
        invoice.details.add(InvoiceDetail(
          productId: product.id,
          name: product.name,
          imageUrl: product.imageUrl,
          quantity: 1,
          price: product.price,
        ));
      });
    }
    invoice = invoice.copyWith(total: _totalInvoice());
  }

  void _processInvoice() async {
    if (invoice.details.isEmpty) {
      _showErrorDialog("Debe agregar al menos un producto a la factura.");
      return;
    }

    if (invoice.customerId.isEmpty) {
      _showErrorDialog("Debe seleccionar un cliente para la factura.");
      return;
    }

    try {
      invoice = invoice.copyWith(
        total: _totalInvoice(),
        paidAmount: double.tryParse(_receivedController.text) ?? 0.0,
        changeGiven: double.tryParse(_changeText) ?? 0.0,
        date: Timestamp.now(),
      );

      // Generar y asignar el ID personalizado
      String newInvoiceId = await InvoiceService().getNextInvoiceId();
      invoice = invoice.copyWith(id: newInvoiceId);

      // Guardar la factura
      await InvoiceService().addInvoice(invoice);

      // Imprimir la factura
      _printInvoice(invoice);

      // Resetear la pantalla de la factura
      _resetInvoiceScreen();

      logger.d('Factura guardada con éxito con ID: $newInvoiceId');
    } catch (e) {
      logger.e("Error al guardar la factura: $e");
      _showErrorDialog("No se pudo guardar la factura: $e");
    }
  }

  void _resetPrinterConnection() {
    setState(() {
      devicesList.clear();
      selectedDevice = null;
    });
    _scanForDevices();
  }

  void _printInvoice(Invoice invoice) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Factura #${invoice.id}'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(
                    'Fecha: ${DateFormat('yyyy-MM-dd').format(invoice.date.toDate())}'),
                Text('Cliente: ${invoice.customerName}'),
                Text(
                    'Tipo de Pago: ${invoice.type.toString().split('.').last}'),
                const SizedBox(height: 10),
                const Text('_________________________________'),
                const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Producto',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    Text('Cant.',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    Text('Precio',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                  ],
                ),
                const SizedBox(height: 5),
                ...invoice.details
                    .map((detail) => Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(detail.name),
                            Text('${detail.quantity}'),
                            Text('\$${detail.price.toStringAsFixed(2)}'),
                          ],
                        ))
                    .toList(),
                const SizedBox(height: 10),
                const Text('_________________________________'),
                Text(
                    'Total: \$${NumberFormat('#,##0.00', 'en_US').format(invoice.total)}'),
                Text(
                    'Monto Pagado: \$${NumberFormat('#,##0.00', 'en_US').format(invoice.paidAmount)}'),
                Text(
                    'Cambio Devuelto: \$${NumberFormat('#,##0.00', 'en_US').format(invoice.changeGiven)}'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cerrar'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: const Text('Imprimir'),
              onPressed: () {
                Navigator.of(context).pop();
                _printInvoiceBluetooth(invoice);
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _printInvoiceBluetooth(Invoice invoice) async {
    final formatter = NumberFormat('#,##0.00');
    final formatterWithoutDecimals = NumberFormat('#,##0');
    if (selectedDevice != null) {
      try {
        await selectedDevice?.connect();

        List<BluetoothService> services =
            await selectedDevice!.discoverServices();
        BluetoothCharacteristic? characteristic;

        for (BluetoothService service in services) {
          for (BluetoothCharacteristic c in service.characteristics) {
            if (c.properties.write) {
              characteristic = c;
              break;
            }
          }
        }

        if (characteristic != null) {
          // Comando para centrar el texto
          await characteristic.write(utf8.encode("\x1B\x61\x01")); // Centrar

          // Comando para aumentar el tamaño de fuente
          await characteristic.write(
              utf8.encode("\x1D\x21\x11")); // Doble altura y doble anchura
          await characteristic.write(utf8.encode("Vivero Deisy\n"));
          await characteristic.write(utf8.encode(
              "\x1D\x21\x00")); // Restaurar tamaño de fuente predeterminado

          // Comando para restablecer el alineamiento a la izquierda
          await characteristic
              .write(utf8.encode("\x1B\x61\x00")); // Alinear a la izquierda

          await characteristic
              .write(utf8.encode("Monte adentro abajo, Santiago,\n"));
          await characteristic.write(utf8.encode("Entrada los campos #6\n"));
          await characteristic.write(utf8.encode("Tel: +1 809 342 2984\n"));
          await characteristic
              .write(utf8.encode("Email: viveroyesi@gmail.com\n"));
          await characteristic
              .write(utf8.encode("--------------------------------\n"));
          await characteristic.write(utf8.encode("Factura #${invoice.id}\n"));
          await characteristic.write(utf8.encode(
              "Fecha: ${DateFormat('yyyy-MM-dd HH:mm:ss').format(invoice.date.toDate())}\n"));
          await characteristic
              .write(utf8.encode("Cliente: ${invoice.customerName}\n"));
          await characteristic.write(utf8.encode(
              "Tipo de Factura: ${invoice.type == InvoiceType.credit ? 'Crédito' : 'Efectivo'}\n"));
          await characteristic
              .write(utf8.encode("--------------------------------\n"));
          await characteristic
              .write(utf8.encode("articulo  Cantidad Precio Monto.\n"));
          await characteristic
              .write(utf8.encode("--------------------------------\n"));

          for (var detail in invoice.details) {
            String detailLine =
                '${detail.name.padRight(8).substring(0, 8)} ${detail.quantity.toString().padLeft(3).padRight(7)} ${formatterWithoutDecimals.format(detail.price).padLeft(7)} ${formatterWithoutDecimals.format(detail.quantity * detail.price).padLeft(7)}\n';
            await characteristic.write(utf8.encode(detailLine));
          }
          await characteristic
              .write(utf8.encode("--------------------------------\n"));
          // Comando para alinear a la derecha y escribir el total
          String totalLine = "Total: \$${formatter.format(invoice.total)}";
          String paddedTotalLine = totalLine
              .padLeft(30); // Ajusta el número para el ancho de la impresora
          await characteristic.write(utf8.encode(paddedTotalLine + "\n"));
          await characteristic
              .write(utf8.encode("--------------------------------\n"));
          String paidAmountLine =
              "Monto Pagado: \$${formatter.format(invoice.paidAmount)}";
          String paddedPaidAmountLine = paidAmountLine.padLeft(30);
          String changeGivenLine =
              "Monto Devuelto: \$${formatter.format(invoice.changeGiven)}";
          String paddedChangeGivenLine = changeGivenLine.padLeft(30);
          await characteristic.write(utf8.encode(paddedPaidAmountLine + "\n"));
          await characteristic.write(utf8.encode(paddedChangeGivenLine + "\n"));
          await characteristic
              .write(utf8.encode("--------------------------------\n"));
          // Comando para cortar el papel
          await characteristic.write([0x1D, 0x56, 0x42, 0x00]);

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Factura impresa correctamente.')),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text(
                    'No se encontró una característica de escritura en la impresora.')),
          );
        }

        await selectedDevice?.disconnect();
      } catch (e) {
        logger.e("Error printing invoice: $e");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al imprimir la factura: $e')),
        );
        _resetPrinterConnection();
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, selecciona una impresora')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Facturación'),
        backgroundColor: themeColor,
        actions: <Widget>[
          IconButton(
            icon: const Icon(
              Icons.shopping_cart,
              color: Colors.white,
            ),
            onPressed: () => _navigateAndSelectProduct(),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Card(
              elevation: 8.0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16.0),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            'ID del Cliente: ${invoice.customerId}',
                            style: const TextStyle(fontSize: 16),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.search),
                          onPressed: () async {
                            final Customer? selectedCustomer =
                                await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const CustomerListView(
                                    isSelectionMode: true),
                              ),
                            );
                            if (selectedCustomer != null) {
                              setState(() {
                                invoice = invoice.copyWith(
                                  customerId: selectedCustomer.id,
                                  customerName: selectedCustomer.name,
                                );
                                _customerIdController.text =
                                    selectedCustomer.id;
                                _customerNameController.text =
                                    selectedCustomer.name;
                              });
                            }
                          },
                        ),
                      ],
                    ),
                    TextFormField(
                      controller: _customerNameController,
                      decoration: const InputDecoration(
                          labelText: 'Nombre del Cliente'),
                    ),
                    TextFormField(
                      controller: _invoiceDateController,
                      decoration: const InputDecoration(
                        labelText: 'Fecha de la Factura',
                        suffixIcon: Icon(Icons.calendar_today),
                      ),
                      readOnly: true,
                      onTap: () async {
                        DateTime? pickedDate = await showDatePicker(
                          context: context,
                          initialDate: invoice.date.toDate(),
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2100),
                        );
                        if (pickedDate != null) {
                          setState(() {
                            invoice = invoice.copyWith(
                                date: Timestamp.fromDate(pickedDate));
                            _invoiceDateController.text =
                                DateFormat('yyyy-MM-dd').format(pickedDate);
                          });
                        }
                      },
                    ),
                    DropdownButton<InvoiceType>(
                      value: invoice.type,
                      onChanged: (InvoiceType? newValue) {
                        if (newValue != null) {
                          setState(() {
                            invoice = invoice.copyWith(type: newValue);
                          });
                        }
                      },
                      items: InvoiceType.values.map((InvoiceType type) {
                        return DropdownMenuItem<InvoiceType>(
                          value: type,
                          child: Text(type.toString().split('.').last),
                        );
                      }).toList(),
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: DropdownButton<BluetoothDevice>(
                            hint: const Text('Seleccionar impresora',
                                style: TextStyle(color: Colors.black)),
                            value: selectedDevice,
                            onChanged: (BluetoothDevice? newValue) {
                              setState(() {
                                selectedDevice = newValue;
                              });
                            },
                            items: devicesList.map((BluetoothDevice device) {
                              return DropdownMenuItem<BluetoothDevice>(
                                value: device,
                                child: Text(device.name,
                                    overflow: TextOverflow.ellipsis),
                              );
                            }).toList(),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.refresh),
                          onPressed: _scanForDevices,
                        ),
                      ],
                    ),
                    TextButton(
                      onPressed: _resetPrinterConnection,
                      child: const Text('Resetear conexión de impresora'),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: invoice.details.length,
              itemBuilder: (context, index) {
                return InvoiceCard(
                  detail: invoice.details[index],
                  onDelete: _deleteDetail,
                  onIncrement: () {
                    setState(() {
                      invoice.details[index].quantity++;
                      invoice = invoice.copyWith(total: _totalInvoice());
                    });
                  },
                  onDecrement: () {
                    setState(() {
                      if (invoice.details[index].quantity > 1) {
                        invoice.details[index].quantity--;
                        invoice = invoice.copyWith(total: _totalInvoice());
                      }
                    });
                  },
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Card(
              elevation: 8.0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16.0),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    TextFormField(
                      controller: _receivedController,
                      decoration: const InputDecoration(
                        labelText: "Efectivo Recibido",
                      ),
                      keyboardType: TextInputType.number,
                      onChanged: (value) => _calculateChange(),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Text(
                        'Cambio a Devolver: $_changeText',
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ),
                    Text(
                      'Total de Factura: \$${NumberFormat('#,##0.00', 'en_US').format(_totalInvoice())}',
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _processInvoice,
        backgroundColor: themeColor,
        child: const Icon(Icons.save, color: Colors.white),
      ),
    );
  }
}
