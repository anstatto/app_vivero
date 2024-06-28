// ignore_for_file: unnecessary_null_comparison

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:vivero/models/InvoiceDetail.dart';

class InvoiceCard extends StatefulWidget {
  final InvoiceDetail detail;
  final Function(InvoiceDetail) onUpdate;
  final Function(InvoiceDetail) onDelete;

  const InvoiceCard(
      {Key? key,
      required this.detail,
      required this.onUpdate,
      required this.onDelete})
      : super(key: key);

  @override
  _InvoiceCardState createState() => _InvoiceCardState();
}

class _InvoiceCardState extends State<InvoiceCard> {
  void _increment() {
    setState(() {
      widget.detail.quantity++;
    });
    widget.onUpdate(widget.detail);
  }

  void _decrement() {
    if (widget.detail.quantity > 0) {
      setState(() {
        widget.detail.quantity--;
      });
      widget.onUpdate(widget.detail);
    }
  }

  void _showDeleteConfirmation() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Eliminar Producto'),
          content: const Text(
              '¿Estás seguro de que quieres eliminar este producto de la factura?'),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                widget.onDelete(widget.detail);
                Navigator.of(context).pop();
              },
              child: const Text('Eliminar'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    String imageUrl = widget.detail
        .imageUrl; // Asumiendo que este es el campo para la URL de la imagen
    return Card(
      elevation: 4,
      margin: const EdgeInsets.all(10),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            imageUrl != null && Uri.tryParse(imageUrl)?.isAbsolute == true
                ? Image.network(imageUrl, height: 120, fit: BoxFit.cover)
                : Image.asset('lib/images/no_content.png',
                    height: 120, fit: BoxFit.cover), // Imagen predeterminada
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Text(widget.detail.name,
                  style: const TextStyle(fontWeight: FontWeight.bold)),
            ),
            Text(
                'Precio: \$${NumberFormat('#,##0.00', 'en_US').format(widget.detail.price)}'),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                IconButton(
                    icon: const Icon(Icons.remove), onPressed: _decrement),
                Text('${widget.detail.quantity}'),
                IconButton(icon: const Icon(Icons.add), onPressed: _increment),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Total: \$${NumberFormat('#,##0.00', 'en_US').format(widget.detail.price * widget.detail.quantity)}',
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: _showDeleteConfirmation,
                  color: Colors.red,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
