import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:logger/logger.dart';

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

  @override
  void initState() {
    super.initState();
    invoice = widget.invoice ??
        Invoice(
          id: '',
          date: DateTime.now(),
          customerId: '',
          customerName: '',
          details: [],
          type: InvoiceType.cash,
          total: 0.0,
          balance: 0.0,
        );

    _customerIdController.text = invoice.customerId;
    _customerNameController.text = invoice.customerName;
    _invoiceDateController.text = DateFormat('yyyy-MM-dd').format(invoice.date);
  }

  double _totalInvoice() {
    return invoice.details.fold(0, (sum, item) => sum + item.price * item.quantity);
  }

  void _updateDetail(InvoiceDetail detail) {
    setState(() {
      invoice = invoice.copyWith(
        details: invoice.details.map((d) => d.productId == detail.productId ? detail : d).toList(),
      );
    });
  }

  void _deleteDetail(InvoiceDetail detail) {
    setState(() {
      invoice = invoice.copyWith(
        details: invoice.details.where((d) => d.productId != detail.productId).toList(),
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
    setState(() {});
  }

  void _resetInvoiceScreen() {
    setState(() {
      invoice = Invoice(
        id: '',
        date: DateTime.now(),
        customerId: '',
        customerName: '',
        details: [],
        type: InvoiceType.cash,
        total: 0.0,
        balance: 0.0,
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
                            final Customer? selectedCustomer = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const CustomerListView(isSelectionMode: true),
                              ),
                            );
                            if (selectedCustomer != null) {
                              setStateDialog(() {
                                invoice = invoice.copyWith(
                                  customerId: selectedCustomer.id,
                                  customerName: selectedCustomer.name,
                                );
                                _customerIdController.text = selectedCustomer.id;
                                _customerNameController.text = selectedCustomer.name;
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
                          suffixIcon: Icon(Icons.calendar_today)),
                      readOnly: true,
                      onTap: () async {
                        DateTime? pickedDate = await showDatePicker(
                          context: context,
                          initialDate: invoice.date,
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2100),
                        );
                        if (pickedDate != null) {
                          setStateDialog(() {
                            invoice = invoice.copyWith(date: pickedDate);
                            _invoiceDateController.text = DateFormat('yyyy-MM-dd').format(pickedDate);
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
        content: Text("Producto Existente se incremento ${existingDetail.name}"),
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
      invoice = invoice.copyWith(total: _totalInvoice());

      String newInvoiceId = await InvoiceService().getNextInvoiceId();
      invoice = invoice.copyWith(id: newInvoiceId);
      await InvoiceService().addInvoice(invoice);

      _printInvoice(invoice);

      _resetInvoiceScreen();

      logger.d('Factura guardada con éxito con ID: $newInvoiceId');
    } catch (e) {
      logger.e("Error al guardar la factura: $e");
      _showErrorDialog("No se pudo guardar la factura: $e");
    }
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
                Text('Fecha: ${DateFormat('yyyy-MM-dd').format(invoice.date)}'),
                Text('Cliente: ${invoice.customerName}'),
                Text('Tipo de Pago: ${invoice.type.toString().split('.').last}'),
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
                ...invoice.details.map((detail) => Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(detail.name),
                    Text('${detail.quantity}'),
                    Text('\$${detail.price.toStringAsFixed(2)}'),
                  ],
                )).toList(),
                const SizedBox(height: 10),
                const Text('_________________________________'),
                Text('Total: \$${NumberFormat('#,##0.00', 'en_US').format(invoice.total)}'),
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
              },
            ),
          ],
        );
      },
    );
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
              Icons.app_registration,
              color: Colors.white,
            ),
            onPressed: () => _showInvoiceDialog(),
          ),
          IconButton(
            icon: const Icon(
              Icons.save,
              color: Colors.white,
            ),
            onPressed: () => _processInvoice(),
          ),
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
          Expanded(
            child: ListView.builder(
              itemCount: invoice.details.length,
              itemBuilder: (context, index) {
                return InvoiceCard(
                  detail: invoice.details[index],
                  onUpdate: _updateDetail,
                  onDelete: _deleteDetail,
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: TextFormField(
              controller: _receivedController,
              decoration: const InputDecoration(
                labelText: "Efectivo Recibido",
              ),
              keyboardType: TextInputType.number,
              onChanged: (value) => _calculateChange(),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Text(
              'Cambio a Devolver: $_changeText',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          Text(
            'Total de Factura: \$${NumberFormat('#,##0.00', 'en_US').format(_totalInvoice())}',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
