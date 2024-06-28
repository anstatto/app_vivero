import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:vivero/models/product.dart';
import 'package:vivero/services/product_service.dart'; // Asegúrate de tener este import para ProductService
import 'package:vivero/widgets/custom_button.dart';
import 'package:vivero/widgets/custom_dropdown.dart';
import 'package:vivero/widgets/custom_text_field.dart';

class ProductCreateView extends StatefulWidget {
  final Product? product;

  const ProductCreateView({Key? key, this.product}) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _ProductCreateViewState createState() => _ProductCreateViewState();
}

class _ProductCreateViewState extends State<ProductCreateView> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _priceController;
  late TextEditingController _stockController;
  ProductStatus? _selectedStatus;
  File? _imageFile;
  final ImagePicker _picker = ImagePicker();
  // ignore: prefer_final_fields
  ProductService _productService =
      ProductService(); // Instancia de ProductService

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.product?.name ?? '');
    _priceController =
        TextEditingController(text: widget.product?.price.toString() ?? '');
    _stockController =
        TextEditingController(text: widget.product?.stock.toString() ?? '');
    _selectedStatus = widget.product?.status ?? ProductStatus.available;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _stockController.dispose();
    super.dispose();
  }

//limpiar el formulario
  void _resetForm() {
    _nameController.clear();
    _priceController.clear();
    _stockController.clear();
    setState(() {
      _selectedStatus = ProductStatus
          .available; // Asume un valor por defecto o ajusta según sea necesario
      _imageFile = null; // Restablecer el archivo de imagen
    });
  }

  Future<void> _pickImage() async {
    final XFile? selectedImage =
        await _picker.pickImage(source: ImageSource.gallery);
    if (selectedImage != null) {
      setState(() => _imageFile = File(selectedImage.path));
    }
  }

  Future<void> _pickImageFromCamera() async {
    final XFile? capturedImage =
        await _picker.pickImage(source: ImageSource.camera);
    if (capturedImage != null) {
      setState(() => _imageFile = File(capturedImage.path));
    }
  }

  void _addProduct() async {
    if (_formKey.currentState?.validate() ?? false) {
      bool isUnique =
          await _productService.isProductNameUnique(_nameController.text);
      if (!isUnique) {
        _showSnackBar("El nombre del producto ya existe.");
        return;
      }
      try {
        Product product = Product(
          id: '',
          name: _nameController.text,
          price: double.parse(_priceController.text),
          stock: int.parse(_stockController.text),
          status: _selectedStatus!,
          imageUrl: '',
        );
        await _productService.addProduct(product, imageFile: _imageFile);
        _showSnackBar("Producto guardado con éxito");
        _resetForm(); // Limpia el formulario después del éxito
      } catch (error) {
        _showSnackBar('Error al guardar el producto: $error');
      }
    }
  }

  void _updateProduct() async {
    if (_formKey.currentState?.validate() ?? false) {
      // Pasar el ID del producto actual para excluirlo en la verificación de unicidad
      bool isUnique = await _productService.isProductNameUnique(
          _nameController.text, widget.product!.id);
      if (!isUnique) {
        _showSnackBar("El nombre del producto ya existe.");
        return;
      }

      try {
        Product product = Product(
          id: widget.product!.id,
          name: _nameController.text,
          price: double.parse(_priceController.text),
          stock: int.parse(_stockController.text),
          status: _selectedStatus!,
          imageUrl: widget.product!.imageUrl,
        );

        await _productService.updateProduct(product, imageFile: _imageFile);
        _showSnackBar("Producto actualizado con éxito");
        // ignore: use_build_context_synchronously
        Navigator.pop(context,
            true); // Retorna a la pantalla anterior si la actualización fue exitosa
      } catch (error) {
        _showSnackBar('Error al actualizar el producto: $error');
      }
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Widget _imageSection() {
    return Column(
      children: [
        Container(
          margin: const EdgeInsets.all(16.0),
          height: 200,
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8.0),
            border: Border.all(color: Colors.grey.shade300),
            boxShadow: [
              BoxShadow(
                  color: Colors.grey.shade200,
                  blurRadius: 5.0,
                  offset: const Offset(0, 3))
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8.0),
            child: _imageFile != null
                ? Image.file(_imageFile!, fit: BoxFit.cover)
                : widget.product?.imageUrl != null
                    ? Image.network(widget.product!.imageUrl, fit: BoxFit.cover)
                    : Image.asset("lib/images/no_content.png",
                        fit: BoxFit.contain),
          ),
        ),
        const SizedBox(height: 24),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            ElevatedButton.icon(
              icon: const Icon(Icons.camera_alt),
              label: const Text('Tomar Foto'),
              onPressed: _pickImageFromCamera,
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: Colors.green[700],
                textStyle:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                padding: const EdgeInsets.symmetric(
                    vertical: 10.0, horizontal: 20.0),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30)),
              ),
            ),
            ElevatedButton.icon(
              icon: const Icon(Icons.photo_library),
              label: const Text('Galería'),
              onPressed: _pickImage,
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: Colors.blue[700],
                textStyle:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                padding: const EdgeInsets.symmetric(
                    vertical: 10.0, horizontal: 20.0),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30)),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _submitButton() {
    return CustomButton(
      label: widget.product == null ? 'Guardar' : 'Actualizar',
      onPressed: () {
        if (_formKey.currentState!.validate()) {
          if (widget.product == null) {
            _addProduct();
          } else {
            _updateProduct();
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
        title:
            Text(widget.product == null ? 'Crear Producto' : 'Editar Producto'),
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
                _imageSection(),
                const SizedBox(height: 16.0),
                CustomTextField(
                  hintText: 'Nombre del Producto',
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
                  hintText: 'Precio',
                  controller: _priceController,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Este campo es obligatorio';
                    }
                    try {
                      final double price = double.parse(value);
                      if (price < 0) return 'El precio no puede ser negativo';
                    } catch (_) {
                      return 'Por favor ingrese un número válido';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 10),
                CustomTextField(
                  hintText: 'Stock',
                  controller: _stockController,
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Este campo es obligatorio';
                    }
                    try {
                      final int stock = int.parse(value);
                      if (stock < 0) return 'El stock no puede ser negativo';
                    } catch (_) {
                      return 'Por favor ingrese un número válido';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 10),
                CustomDropdownButtonFormField<ProductStatus>(
                  value: _selectedStatus,
                  onChanged: (newValue) =>
                      setState(() => _selectedStatus = newValue),
                  itemText: (status) => describeEnum(status),
                  options: ProductStatus.values,
                  decoration: const InputDecoration(
                      labelText: 'Estado del Producto',
                      border: OutlineInputBorder()),
                  validator: (value) => value == null
                      ? 'Por favor seleccione un estado del producto'
                      : null,
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
