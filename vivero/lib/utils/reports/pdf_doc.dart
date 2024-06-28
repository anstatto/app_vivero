import 'dart:io';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:share_plus/share_plus.dart';
import 'package:vivero/models/Invoice.dart';

Future<void> generatePDFAndShare(Invoice invoice) async {
  final pdf = pw.Document();

  // Cargar el logo de la empresa desde los assets
  final Uint8List logoData = (await rootBundle.load('lib/images/logo.jpeg')).buffer.asUint8List();
  final pw.MemoryImage logo = pw.MemoryImage(logoData);

  pdf.addPage(
    pw.Page(
      build: (pw.Context context) {
        return pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Center(
              child: pw.Image(logo, width: 150, height: 100),
            ),
            pw.SizedBox(height: 20),
            pw.Text('Vivero Deisy',
                style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
            pw.Text('Monte adentro abajo, Santiago, Entrada los campos #6'),
            pw.Text('Teléfono: +1 809 342 2984'),
            pw.Text('Email:  viveroyesi@gmail.com'),
            pw.Text('Redes Sociales: @viverodeisy'),
            pw.Divider(),
            pw.SizedBox(height: 20),
            pw.Text('Factura #${invoice.id}',
                style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold)),
            pw.Text('Fecha: ${DateFormat('yyyy-MM-dd').format(invoice.date)}',
                style: const pw.TextStyle(fontSize: 18)),
            pw.SizedBox(height: 10),
            pw.Text('Información del Cliente:',
                style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
            pw.Text('Nombre: ${invoice.customerName}',
                style: const pw.TextStyle(fontSize: 16)),
            pw.Text(
                'Tipo de Factura: ${invoice.type == InvoiceType.credit ? 'Crédito' : 'Efectivo'}',
                style: const pw.TextStyle(fontSize: 16)),
            pw.SizedBox(height: 20),
            pw.Text('Detalles de la Factura:',
                style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
            pw.Table(
              border: pw.TableBorder.all(),
              children: [
                pw.TableRow(
                  children: [
                    pw.Text('Producto'),
                    pw.Text('Cantidad'),
                    pw.Text('Precio Unitario'),
                    pw.Text('Total'),
                  ],
                  decoration: const pw.BoxDecoration(color: PdfColors.grey300),
                ),
                ...invoice.details.map((detail) => pw.TableRow(
                  children: [
                    pw.Text(detail.name),
                    pw.Text(detail.quantity.toString()),
                    pw.Text('\$${detail.price.toStringAsFixed(2)}'),
                    pw.Text('\$${(detail.quantity * detail.price).toStringAsFixed(2)}'),
                  ],
                )),
              ],
            ),
            pw.SizedBox(height: 20),
              pw.Align(
                alignment: pw.Alignment.centerRight,
                child: pw.Text('Total: \$${invoice.total.toStringAsFixed(2)}',
                    style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
              ),
          ],
        );
      },
    ),
  );

  // Guardar el PDF en un archivo temporal
  final output = await getTemporaryDirectory();
  final file = File("${output.path}/factura-${invoice.id}.pdf");
  await file.writeAsBytes(await pdf.save());

  // Compartir el PDF usando Share
  await Share.shareFiles([file.path], text: 'Factura #${invoice.id}');
}
