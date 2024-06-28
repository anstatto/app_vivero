import 'package:flutter/material.dart';

// Define una función que convierte el enum en un String. Esto es solo un ejemplo y debe ser adaptado para tu caso específico.
String describeEnum<T>(T enumValue) {
  return enumValue.toString().split('.').last;
}

class CustomDropdownButtonFormField<T> extends StatefulWidget {
  final T? value;
  final void Function(T? newValue) onChanged;
  final List<T> options; // Pasa la lista de opciones directamente en lugar de DropdownMenuItem
  final String Function(T) itemText;
  final String? Function(T?)? validator;
  final InputDecoration decoration;

  const CustomDropdownButtonFormField({
    Key? key,
    this.value,
    required this.onChanged,
    required this.options, // Cambiado para aceptar opciones directamente
    required this.itemText,
    this.validator,
    this.decoration = const InputDecoration(),
  }) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _CustomDropdownButtonFormFieldState<T> createState() => _CustomDropdownButtonFormFieldState<T>();
}

class _CustomDropdownButtonFormFieldState<T> extends State<CustomDropdownButtonFormField<T>> {
  T? _selectedValue;

  @override
  void initState() {
    super.initState();
    _selectedValue = widget.value;
  }

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<T>(
      value: _selectedValue,
      onChanged: (T? newValue) {
        setState(() {
          _selectedValue = newValue;
        });
        widget.onChanged(newValue);
      },
      items: widget.options.map((T value) {
        return DropdownMenuItem<T>(
          value: value,
          child: Text(widget.itemText(value)), // Usa la función itemText para obtener el texto
        );
      }).toList(),
      decoration: widget.decoration,
      validator: widget.validator,
    );
  }
}
