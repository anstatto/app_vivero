// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:vivero/models/customer.dart';
import 'package:vivero/services/customer_service.dart';
import 'package:vivero/views/customers/customer_create.dart';

class CustomerListView extends StatefulWidget {
  final bool isSelectionMode;
  final Function(Customer)? onCustomerSelected;
  const CustomerListView(
      {Key? key, this.isSelectionMode = false, this.onCustomerSelected})
      : super(key: key);

  @override
  _CustomerListViewState createState() => _CustomerListViewState();
}

class _CustomerListViewState extends State<CustomerListView> {
  List<Customer>? _customers;
  bool _isLoading = false;
  final TextEditingController _filter = TextEditingController();
  final Color themeColor = Colors.green;

  @override
  void initState() {
    super.initState();
    _getCustomers();
  }

  Future<void> _getCustomers() async {
    setState(() => _isLoading = true);
    try {
      final List<Customer> customers = await CustomerService().getCustomers();
      setState(() => _customers = customers);
    } catch (e) {
      print("Error al obtener clientes: $e");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _editCustomer(Customer customer) async {
    var result = await Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => CustomerCreateView(customer: customer)),
    );
    if (result == true) {
      _getCustomers();
    }
  }

  void _navigateAndCreateCostumer() async {
    var result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const CustomerCreateView()),
    );
    if (result == true) {
      _getCustomers();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lista de Clientes'),
        backgroundColor: Colors.green,
        actions: [
          _isLoading
              ? const CircularProgressIndicator(color: Colors.white)
              : const SizedBox.shrink(),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60.0),
          child: Container(
            padding: const EdgeInsets.fromLTRB(16.0, 6.0, 16.0, 10.0),
            child: Material(
              borderRadius: BorderRadius.circular(30.0),
              elevation: 2.0,
              child: TextField(
                controller: _filter,
                decoration: const InputDecoration(
                  hintText: 'Buscar cliente...',
                  prefixIcon: Icon(Icons.search),
                  border: InputBorder.none,
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 20.0, vertical: 15.0),
                ),
                onChanged: (_) => _filterCustomers(),
              ),
            ),
          ),
        ),
      ),
      backgroundColor: Colors.green.shade100,
      body: _buildCustomerList(),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateAndCreateCostumer,
        backgroundColor: themeColor,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildCustomerList() {
    if (_customers == null || _customers!.isEmpty) {
      return const Center(child: Text('No hay clientes disponibles'));
    }
    return ListView.builder(
      itemCount: _customers!.length,
      itemBuilder: (context, index) {
        final customer = _customers![index];
        return _buildCustomerCard(customer);
      },
    );
  }

 Widget _buildCustomerCard(Customer customer) {
  final NumberFormat currencyFormat = NumberFormat.currency(locale: 'es_ES', symbol: '\$');
  final formattedCreditLimit = currencyFormat.format(customer.creditLimit);

  return Card(
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    elevation: 4,
    shadowColor: Colors.grey.withOpacity(0.5),
    margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
    child: InkWell(
      onTap: () {
        if (widget.isSelectionMode) {
          widget.onCustomerSelected?.call(customer);
        }
      },
      child: ListTile(
        leading: const Icon(Icons.person, color: Colors.green),
        title: Text(customer.name),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(customer.email),
            const SizedBox(height: 4),
            Text(
              'Límite de crédito: $formattedCreditLimit',
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        trailing: widget.isSelectionMode ? IconButton(
          icon: const Icon(Icons.check_circle, color: Colors.green),
          onPressed: () {
            Navigator.pop(context, customer);
          },
        ) : Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit, color: Colors.blue),
              onPressed: () => _editCustomer(customer),
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () => _confirmDeleteCustomer(customer),
            ),
          ],
        ),
      ),
    ),
  );
}


  void _confirmDeleteCustomer(Customer customer) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Confirmar eliminación"),
          content:
              const Text("¿Estás seguro de que quieres eliminar este cliente?"),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("Cancelar"),
            ),
            TextButton(
              onPressed: () {
                _deleteCustomer(customer);
                Navigator.of(context).pop();
              },
              child: const Text("Eliminar"),
            ),
          ],
        );
      },
    );
  }

  Future<void> _deleteCustomer(Customer customer) async {
    try {
      await CustomerService().deleteCustomer(customer.id);
      setState(() {
        _customers!.remove(customer);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Cliente eliminado correctamente'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error al eliminar el cliente'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _filterCustomers() {
    final String searchTerm = _filter.text.toLowerCase();
    if (searchTerm.isEmpty) {
      // Si el campo de búsqueda está vacío, mostrar todos los clientes
      setState(() {
        _getCustomers(); // Volver a cargar todos los clientes
      });
    } else {
      // Filtrar los clientes basándose en el término de búsqueda
      setState(() {
        _customers = _customers!
            .where((customer) =>
                customer.name.toLowerCase().contains(searchTerm) ||
                customer.email.toLowerCase().contains(searchTerm))
            .toList();
      });
    }
  }

  @override
  void dispose() {
    _filter.dispose();
    super.dispose();
  }
}
