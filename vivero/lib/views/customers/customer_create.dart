import 'package:flutter/material.dart';
import 'package:vivero/models/customer.dart';
import 'package:vivero/services/customer_service.dart';
import 'package:vivero/widgets/custom_button.dart';
import 'package:vivero/widgets/custom_text_field.dart';

class CustomerCreateView extends StatefulWidget {
  final Customer? customer;

  const CustomerCreateView({Key? key, this.customer}) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _CustomerCreateViewState createState() => _CustomerCreateViewState();
}

class _CustomerCreateViewState extends State<CustomerCreateView> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneNumberController;
  late TextEditingController _addressController;
  late TextEditingController _creditLimitController;
  // ignore: prefer_final_fields
  CustomerService _customerService =
      CustomerService(); // Instancia de CustomerService

  @override
  void initState() {
    super.initState();
    _nameController =
        TextEditingController(text: widget.customer?.name ?? '');
    _emailController =
        TextEditingController(text: widget.customer?.email ?? '');
    _phoneNumberController =
        TextEditingController(text: widget.customer?.phoneNumber ?? '');
    _addressController =
        TextEditingController(text: widget.customer?.address ?? '');
    _creditLimitController =
        TextEditingController(text: widget.customer?.creditLimit.toString() ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneNumberController.dispose();
    _addressController.dispose();
    _creditLimitController.dispose();
    super.dispose();
  }

  void _addCustomer() async {
    if (_formKey.currentState?.validate() ?? false) {
      try {
        Customer customer = Customer(
          id: '',
          name: _nameController.text,
          email: _emailController.text,
          phoneNumber: _phoneNumberController.text,
          address: _addressController.text,
          creditLimit: double.parse(_creditLimitController.text),
        );
        await _customerService.addCustomer(customer);
        _showSnackBar("Cliente guardado con éxito");
        _resetForm(); // Limpia el formulario después del éxito
      } catch (error) {
        _showSnackBar('Error al guardar el cliente: $error');
      }
    }
  }

  void _updateCustomer() async {
    if (_formKey.currentState?.validate() ?? false) {
      try {
        Customer customer = Customer(
          id: widget.customer!.id,
          name: _nameController.text,
          email: _emailController.text,
          phoneNumber: _phoneNumberController.text,
          address: _addressController.text,
          creditLimit: double.parse(_creditLimitController.text),
        );

        await _customerService.updateCustomer(customer);
        _showSnackBar("Cliente actualizado con éxito");
        // ignore: use_build_context_synchronously
        Navigator.pop(context,
            true); // Retorna a la pantalla anterior si la actualización fue exitosa
      } catch (error) {
        _showSnackBar('Error al actualizar el cliente: $error');
      }
    }
  }

  void _resetForm() {
    _nameController.clear();
    _emailController.clear();
    _phoneNumberController.clear();
    _addressController.clear();
    _creditLimitController.clear();
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Widget _submitButton() {
    return CustomButton(
      label: widget.customer == null ? 'Guardar' : 'Actualizar',
      onPressed: () {
        if (_formKey.currentState!.validate()) {
          if (widget.customer == null) {
            _addCustomer();
          } else {
            _updateCustomer();
          }
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    Color themeColor = Colors.green.shade600;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.customer == null ? 'Crear Cliente' : 'Editar Cliente'),
        backgroundColor: themeColor,
      ),
      backgroundColor: Colors.green.shade100,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                CustomTextField(
                  hintText: 'Nombre del Cliente',
                  controller: _nameController,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Este campo es obligatorio';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 10),
                CustomTextField(
                  hintText: 'Correo Electrónico',
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Este campo es obligatorio';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 10),
                CustomTextField(
                  hintText: 'Número de Teléfono',
                  controller: _phoneNumberController,
                  keyboardType: TextInputType.phone,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Este campo es obligatorio';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 10),
                CustomTextField(
                  hintText: 'Dirección',
                  controller: _addressController,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Este campo es obligatorio';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 10),
                CustomTextField(
                  hintText: 'Límite de Crédito',
                  controller: _creditLimitController,
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Este campo es obligatorio';
                    }
                    try {
                      final double limit = double.parse(value);
                      if (limit < 0) return 'El límite de crédito no puede ser negativo';
                    } catch (_) {
                      return 'Por favor ingrese un número válido';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                _submitButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
