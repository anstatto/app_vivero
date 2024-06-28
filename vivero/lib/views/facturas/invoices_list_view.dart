import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:logger/logger.dart';
import 'package:vivero/models/Invoice.dart'; // Asegúrate de que esta ruta es correcta y consistente
import 'package:vivero/services/invoice_service.dart';

import 'package:vivero/utils/reports/pdf_doc.dart';

class InvoiceFilterScreen extends StatefulWidget {
  const InvoiceFilterScreen({Key? key}) : super(key: key);

  @override
  _InvoiceFilterScreenState createState() => _InvoiceFilterScreenState();
}

class _InvoiceFilterScreenState extends State<InvoiceFilterScreen> {
  final TextEditingController startDateController = TextEditingController();
  final TextEditingController endDateController = TextEditingController();
  final TextEditingController startIdController = TextEditingController();
  final TextEditingController customerNameController = TextEditingController();
  final InvoiceService invoiceService = InvoiceService();
  Set<Invoice> invoices = {}; // Aquí manejamos un Set de Invoice, no Future
  var logger = Logger();

  void _selectDate(
      BuildContext context, TextEditingController controller) async {
    DateTime? selectedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (selectedDate != null) {
      setState(() {
        controller.text = DateFormat('yyyy-MM-dd').format(selectedDate);
      });
    }
  }

  void _adjustDate(TextEditingController controller, int days) {
    if (controller.text.isNotEmpty) {
      DateTime date = DateFormat('yyyy-MM-dd').parse(controller.text);
      date = date.add(Duration(days: days));
      setState(() {
        controller.text = DateFormat('yyyy-MM-dd').format(date);
      });
    }
  }

  void applyFilters() async {
    String startDate = startDateController.text;
    String endDate = endDateController.text;
    String id = startIdController.text;
    String customerName = customerNameController.text;

    if (startDate.isEmpty || endDate.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor ingrese las fechas de inicio y fin.'),
        ),
      );
      return;
    }

    try {
      // Espera a que el Future se complete y asigna el resultado a filteredInvoices
      Set<Invoice> filteredInvoices =
          await invoiceService.filterInvoicesByDateAndIdAndCustomer(
              startDate, endDate, id, customerName);
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
                    'Fecha: ${DateFormat('yyyy-MM-dd HH:mm:ss').format(invoice.date)}'),
                Text('Total: \$${invoice.total}'),
                Text('Tipo de pago: ${getInvoiceTypeString(invoice.type)}'),
                const SizedBox(height: 5),
                const Text(
                  'Detalles:',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
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
    startDateController.clear();
    endDateController.clear();
    startIdController.clear();
    customerNameController.clear();
    setState(() {
      invoices = {};
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Filtro de Facturas'),
        backgroundColor: Colors.green.shade600,
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: applyFilters,
          ),
          IconButton(
            icon: const Icon(Icons.clear),
            onPressed: clearFilters,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: buildTextField(
                      startDateController, 'Fecha de Inicio (YYYY-MM-DD)'),
                ),
                IconButton(
                  icon: const Icon(Icons.calendar_today),
                  onPressed: () => _selectDate(context, startDateController),
                ),
                IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: () => _adjustDate(startDateController, 1),
                ),
                IconButton(
                  icon: const Icon(Icons.remove),
                  onPressed: () => _adjustDate(startDateController, -1),
                ),
              ],
            ),
            Row(
              children: [
                Expanded(
                  child: buildTextField(
                      endDateController, 'Fecha de Fin (YYYY-MM-DD)'),
                ),
                IconButton(
                  icon: const Icon(Icons.calendar_today),
                  onPressed: () => _selectDate(context, endDateController),
                ),
                IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: () => _adjustDate(endDateController, 1),
                ),
                IconButton(
                  icon: const Icon(Icons.remove),
                  onPressed: () => _adjustDate(endDateController, -1),
                ),
              ],
            ),
            buildTextField(startIdController, 'ID de Factura'),
            buildTextField(customerNameController, 'Nombre del Cliente'),
            const SizedBox(height: 20),
            invoices.isNotEmpty
                ? ListView.builder(
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
                          margin: const EdgeInsets.symmetric(vertical: 10),
                          child: Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Cliente: ${invoice.customerName}',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 5),
                                Text('Código: ${invoice.id}'),
                                Text(
                                    'Fecha: ${DateFormat('yyyy-MM-dd HH:mm:ss').format(invoice.date)}'),
                                Text('Total: \$${invoice.total}'),
                                Text(
                                    'Tipo de pago: ${getInvoiceTypeString(invoice.type)}'),
                                const SizedBox(height: 5),
                                IconButton(
                                  onPressed: () {
                                    generatePDFAndShare(invoice);
                                  },
                                  icon: const Icon(Icons.share,
                                      color: Colors.blue), // Color del icono
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  )
                : const SizedBox.shrink(),
          ],
        ),
      ),
    );
  }

  Widget buildTextField(TextEditingController controller, String label) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(labelText: label),
    );
  }
}
