import 'package:flutter/material.dart';
import '../../models/InvoiceDetail.dart';

class InvoiceCard extends StatelessWidget {
  final InvoiceDetail detail;
  final Function(InvoiceDetail) onDelete;
  final Function() onIncrement;
  final Function() onDecrement;

  const InvoiceCard({
    Key? key,
    required this.detail,
    required this.onDelete,
    required this.onIncrement,
    required this.onDecrement,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 5,
      margin: const EdgeInsets.symmetric(vertical: 10),
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                if (detail.imageUrl.isNotEmpty)
                  Image.network(detail.imageUrl,
                      width: 50, height: 50, fit: BoxFit.cover),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        detail.name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.remove),
                            onPressed: onDecrement,
                          ),
                          Text('Cantidad: ${detail.quantity}'),
                          IconButton(
                            icon: const Icon(Icons.add),
                            onPressed: onIncrement,
                          ),
                        ],
                      ),
                      Text('Precio: \$${detail.price}'),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () => onDelete(detail),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
