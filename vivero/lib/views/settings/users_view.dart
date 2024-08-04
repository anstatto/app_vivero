import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:vivero/models/user.dart';
import 'package:vivero/services/UserService.dart';
import 'package:vivero/widgets/search_delegate.dart'; // Asegúrate de importar el nuevo archivo

class RegisterView extends StatefulWidget {
  final User? user;
  final Function? onSave;

  const RegisterView({Key? key, this.user, this.onSave}) : super(key: key);

  @override
  _RegisterViewState createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final UserService _userService = UserService();

  final Map<String, Map<String, bool>> _modulePermissions = {
    'Productos': {
      'Mostrar': false,
      'Consultar': false,
      'Crear': false,
      'Modificar': false,
      'Eliminar': false,
    },
    'Clientes': {
      'Mostrar': false,
      'Consultar': false,
      'Crear': false,
      'Modificar': false,
      'Eliminar': false,
    },
    'Facturación': {
      'Mostrar': false,
      'Consultar': false,
      'Crear': false,
      'Modificar': false,
      'Eliminar': false,
    },
  };
  User? _selectedUser;

  @override
  void initState() {
    super.initState();
    if (widget.user != null) {
      _selectedUser = widget.user;
      _usernameController.text = _selectedUser!.name;
      _emailController.text = _selectedUser!.email ?? '';
      _passwordController.text = _selectedUser!.password;
      _initializePermissions(_selectedUser!.modulePermissions);
    }
  }

  void _initializePermissions(Map<String, Map<String, bool>> userPermissions) {
    _modulePermissions.forEach((module, permissions) {
      if (userPermissions.containsKey(module)) {
        userPermissions[module]!.forEach((permission, value) {
          _modulePermissions[module]![permission] = value;
        });
      }
    });
  }

  void _registerOrUpdate() async {
    if (_formKey.currentState?.validate() ?? false) {
      String id = _selectedUser?.id ?? Uuid().v4();
      String name = _usernameController.text;
      String? email = _emailController.text.isEmpty ? null : _emailController.text;
      String password = _passwordController.text;

      User user = User(
        id: id,
        name: name,
        email: email,
        password: password,
        modulePermissions: _modulePermissions,
      );

      if (_selectedUser == null) {
        // Crear nuevo usuario
        await _userService.createUser(user);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Usuario creado exitosamente')),
        );
      } else {
        // Actualizar usuario existente
        await _userService.updateUser(user);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Usuario actualizado exitosamente')),
        );
      }

      if (widget.onSave != null) {
        widget.onSave!();
      }
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error al crear/actualizar el usuario')),
      );
    }
  }

  void _resetForm() {
    _usernameController.clear();
    _emailController.clear();
    _passwordController.clear();
    setState(() {
      _modulePermissions.forEach((module, permissions) {
        permissions.updateAll((key, value) => false);
      });
      _selectedUser = null;
    });
  }

  void _openUserSelection() async {
    User? selectedUser = await showSearch(
      context: context,
      delegate: UserSearchDelegate(userService: _userService),
    );
    if (selectedUser != null && selectedUser.id.isNotEmpty) {
      setState(() {
        _selectedUser = selectedUser;
        _usernameController.text = _selectedUser!.name;
        _emailController.text = _selectedUser!.email ?? '';
        _passwordController.text = _selectedUser!.password;
        _modulePermissions.forEach((module, permissions) {
          permissions.updateAll((key, value) => false);
        });
        _initializePermissions(_selectedUser!.modulePermissions);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Registrar Usuario'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: _openUserSelection,
          ),
        ],
      ),
      body: Container(
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
        child: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: 600),
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
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          Text(
                            _selectedUser == null ? 'Registro' : 'Actualizar Usuario',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _usernameController,
                            decoration: const InputDecoration(
                              labelText: 'Nombre de Usuario',
                              border: OutlineInputBorder(),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Por favor, ingrese su nombre de usuario';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _emailController,
                            decoration: const InputDecoration(
                              labelText: 'Correo Electrónico',
                              border: OutlineInputBorder(),
                            ),
                            validator: (value) {
                              if (value != null && value.isNotEmpty) {
                                if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                                  return 'Por favor, ingrese un correo electrónico válido';
                                }
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _passwordController,
                            decoration: const InputDecoration(
                              labelText: 'Contraseña',
                              border: OutlineInputBorder(),
                            ),
                            obscureText: true,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Por favor, ingrese su contraseña';
                              } else if (value.length < 6) {
                                return 'La contraseña debe tener al menos 6 caracteres';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          ..._modulePermissions.keys.map((module) {
                            return ExpansionTile(
                              title: Text(module),
                              children: _modulePermissions[module]!.keys.map((permission) {
                                return SwitchListTile(
                                  title: Text(permission),
                                  value: _modulePermissions[module]![permission]!,
                                  activeColor: Theme.of(context).colorScheme.primary,
                                  onChanged: (bool value) {
                                    setState(() {
                                      _modulePermissions[module]![permission] = value;
                                    });
                                  },
                                );
                              }).toList(),
                            );
                          }).toList(),
                          ElevatedButton.icon(
                            onPressed: _registerOrUpdate,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Theme.of(context).colorScheme.primary,
                              minimumSize: const Size.fromHeight(50),
                            ),
                            icon: Icon(
                              _selectedUser == null ? Icons.person_add : Icons.update,
                              color: Colors.white, // Asegurando que el ícono sea blanco
                            ),
                            label: Text(
                              _selectedUser == null ? 'Crear Usuario' : 'Actualizar Usuario',
                              style: const TextStyle(color: Colors.white), // Asegurando que el texto sea blanco
                            ),
                          ),
                          if (_selectedUser != null)
                            TextButton(
                              onPressed: _resetForm,
                              child: const Text('Cancelar'),
                              style: TextButton.styleFrom(
                                foregroundColor: Theme.of(context).colorScheme.primary, // Asegurando que el texto sea del color primario
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
