import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:logger/logger.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:vivero/models/Invoice.dart';
import 'package:vivero/services/invoice_service.dart';
import 'package:vivero/utils/reports/pdf_doc.dart';

class InvoiceFilterScreen extends StatefulWidget {
  const InvoiceFilterScreen({Key? key}) : super(key: key);

  @override
  _InvoiceFilterScreenState createState() => _InvoiceFilterScreenState();
}

class _InvoiceFilterScreenState extends State<InvoiceFilterScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController startDateController = TextEditingController();
  final TextEditingController endDateController = TextEditingController();
  final TextEditingController startIdController = TextEditingController();
  final TextEditingController customerNameController = TextEditingController();
  final InvoiceService invoiceService = InvoiceService();
  Set<Invoice> invoices = {};
  var logger = Logger();

  FlutterBlue flutterBlue = FlutterBlue.instance;
  List<BluetoothDevice> devicesList = [];
  BluetoothDevice? selectedDevice;

  @override
  void initState() {
    super.initState();
    _requestPermissions();
    _initializeDates();
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
        const SnackBar(
            content: Text('Permisos de Bluetooth y ubicación no concedidos.')),
      );
    }
  }

  void _initializeDates() {
    final now = DateTime.now();
    startDateController.text = DateFormat('yyyy-MM-dd 00:00:00').format(now);
    endDateController.text = DateFormat('yyyy-MM-dd 23:59:59').format(now);
  }

  void _scanForDevices() {
    flutterBlue.startScan(timeout: const Duration(seconds: 4));
    flutterBlue.scanResults.listen((results) {
      setState(() {
        devicesList = results.map((result) => result.device).toList();
      });
    });
  }

  void _selectDate(
      BuildContext context, TextEditingController controller) async {
    DateTime initialDate = DateTime.now();
    if (controller.text.isNotEmpty) {
      initialDate = DateFormat('yyyy-MM-dd HH:mm:ss').parse(controller.text);
    }

    DateTime? selectedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );

    if (selectedDate != null) {
      setState(() {
        if (controller == startDateController) {
          controller.text =
              DateFormat('yyyy-MM-dd 00:00:00').format(selectedDate);
        } else {
          controller.text =
              DateFormat('yyyy-MM-dd 23:59:59').format(selectedDate);
        }
      });
    }
  }

  void _adjustDate(TextEditingController controller, int days) {
    if (controller.text.isNotEmpty) {
      DateTime date = DateFormat('yyyy-MM-dd HH:mm:ss').parse(controller.text);
      date = date.add(Duration(days: days));
      setState(() {
        if (controller == startDateController) {
          controller.text = DateFormat('yyyy-MM-dd 00:00:00').format(date);
        } else {
          controller.text = DateFormat('yyyy-MM-dd 23:59:59').format(date);
        }
      });
    }
  }

  void applyFilters() async {
    if (_formKey.currentState?.validate() ?? false) {
      String startDate = startDateController.text;
      String endDate = endDateController.text;
      String id = startIdController.text;
      String customerName = customerNameController.text;

      try {
        Set<Invoice> filteredInvoices =
            await invoiceService.filterInvoicesByDateAndIdAndCustomer(
          startDate,
          endDate,
          id,
          customerName,
        );
        setState(() {
          invoices = filteredInvoices;
        });
      } catch (e) {
        logger.e("Error fetching invoices: $e");
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error al cargar las facturas.'),
          ),
        );
      }
    }
  }

  String getInvoiceTypeString(InvoiceType type) {
    switch (type) {
      case InvoiceType.cash:
        return 'Efectivo';
      case InvoiceType.credit:
        return 'Crédito';
      default:
        return 'Desconocido';
    }
  }

  void showInvoiceDetails(BuildContext context, Invoice invoice) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Detalles de la Factura'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Cliente: ${invoice.customerName}'),
                Text('Código: ${invoice.id}'),
                Text(
                    'Fecha: ${DateFormat('yyyy-MM-dd HH:mm:ss').format(invoice.date.toDate())}'),
                Text('Total: \$${invoice.total}'),
                Text('Tipo de pago: ${getInvoiceTypeString(invoice.type)}'),
                const SizedBox(height: 5),
                const Text('Detalles:',
                    style:
                        TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                Column(
                  children: invoice.details.map((detail) {
                    return ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(detail.name),
                      subtitle: Text(
                          'Cantidad: ${detail.quantity} - Precio: \$${detail.price}'),
                      leading: detail.imageUrl.isNotEmpty
                          ? Image.network(detail.imageUrl,
                              width: 50, height: 50, fit: BoxFit.cover)
                          : const SizedBox.shrink(),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
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

  void clearFilters() {
    _initializeDates();
    startIdController.clear();
    customerNameController.clear();
    setState(() {
      invoices = {};
    });
  }

  Future<void> _printInvoice(Invoice invoice) async {
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
              .write(utf8.encode("Redes Sociales: @viverodeisy\n"));
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
          await characteristic.write(utf8.encode("Detalles de la Factura:\n"));
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
        title: const Text('Filtro de Facturas'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        actions: [
          DropdownButton<BluetoothDevice>(
            hint: const Text('Seleccionar impresora',
                style: TextStyle(color: Colors.white)),
            value: selectedDevice,
            onChanged: (BluetoothDevice? newValue) {
              setState(() {
                selectedDevice = newValue;
              });
            },
            items: devicesList.map((BluetoothDevice device) {
              return DropdownMenuItem<BluetoothDevice>(
                value: device,
                child: Text(device.name),
              );
            }).toList(),
          ),
        ],
      ),
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Theme.of(context).colorScheme.primary,
                  Theme.of(context).colorScheme.primaryContainer,
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            child: Column(
              children: [
                SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: ConstrainedBox(
                      constraints:
                          BoxConstraints(maxWidth: 800, maxHeight: 340),
                      child: Card(
                        elevation: 8.0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16.0),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Form(
                            key: _formKey,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: buildTextField(startDateController,
                                          'Fecha de Inicio (YYYY-MM-DD HH:MM:SS)'),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.calendar_today),
                                      onPressed: () => _selectDate(
                                          context, startDateController),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.add),
                                      onPressed: () =>
                                          _adjustDate(startDateController, 1),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.remove),
                                      onPressed: () =>
                                          _adjustDate(startDateController, -1),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                Row(
                                  children: [
                                    Expanded(
                                      child: buildTextField(endDateController,
                                          'Fecha de Fin (YYYY-MM-DD HH:MM:SS)'),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.calendar_today),
                                      onPressed: () => _selectDate(
                                          context, endDateController),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.add),
                                      onPressed: () =>
                                          _adjustDate(endDateController, 1),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.remove),
                                      onPressed: () =>
                                          _adjustDate(endDateController, -1),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                buildTextField(
                                    startIdController, 'ID de Factura'),
                                const SizedBox(height: 16),
                                buildTextField(customerNameController,
                                    'Nombre del Cliente'),
                                const SizedBox(height: 20),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          if (invoices.isNotEmpty)
                            ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: invoices.length,
                              itemBuilder: (context, index) {
                                Invoice invoice = invoices.elementAt(index);
                                logger.d(
                                    "Invoice: ${invoice.id}, Customer: ${invoice.customerName}");
                                return GestureDetector(
                                  onDoubleTap: () {
                                    showInvoiceDetails(context, invoice);
                                  },
                                  child: Card(
                                    elevation: 5,
                                    margin: const EdgeInsets.symmetric(
                                        vertical: 10),
                                    child: Padding(
                                      padding: const EdgeInsets.all(10.0),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Cliente: ${invoice.customerName}',
                                            style: const TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold),
                                          ),
                                          const SizedBox(height: 5),
                                          Text('Código: ${invoice.id}'),
                                          Text(
                                              'Fecha: ${DateFormat('yyyy-MM-dd HH:mm:ss').format(invoice.date.toDate())}'),
                                          Text('Total: \$${invoice.total}'),
                                          Text(
                                              'Tipo de pago: ${getInvoiceTypeString(invoice.type)}'),
                                          const SizedBox(height: 5),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              IconButton(
                                                onPressed: () {
                                                  generatePDFAndShare(invoice);
                                                },
                                                icon: const Icon(Icons.share,
                                                    color: Colors.blue),
                                              ),
                                              IconButton(
                                                onPressed: () {
                                                  _printInvoice(invoice);
                                                },
                                                icon: const Icon(Icons.print,
                                                    color: Colors.green),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              },
                            )
                          else
                            const Text('No se encontraron facturas.'),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            bottom: 20,
            right: 20,
            child: Column(
              children: [
                FloatingActionButton(
                  onPressed: applyFilters,
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  child: const Icon(Icons.search, color: Colors.white),
                ),
                const SizedBox(height: 10),
                FloatingActionButton(
                  onPressed: clearFilters,
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  child: const Icon(Icons.clear, color: Colors.white),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget buildTextField(TextEditingController controller, String label) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(),
      ),
      validator: (value) {
        if (controller == startDateController ||
            controller == endDateController) {
          if (value == null || value.isEmpty) {
            return 'Por favor, ingrese una fecha válida';
          }
        }
        return null;
      },
    );
  }
}

class InvoicePrintScreen extends StatelessWidget {
  final Invoice invoice;

  const InvoicePrintScreen({Key? key, required this.invoice}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Aquí implementamos la lógica para mostrar el formato de impresión de 58 mm
    return Scaffold(
      appBar: AppBar(
        title: const Text('Imprimir Factura'),
      ),
      body: Center(
        child: Text(
            'Formato de impresión de 58 mm para la factura: ${invoice.id}'),
      ),
    );
  }
}
