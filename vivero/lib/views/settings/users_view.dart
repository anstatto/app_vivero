import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:vivero/models/user.dart';
import 'package:vivero/services/UserService.dart';

class RegisterView extends StatefulWidget {
  const RegisterView({Key? key}) : super(key: key);

  @override
  _RegisterViewState createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final UserService _userService = UserService();
  final Map<String, bool> _permissions = {
    'Consultar': false,
    'Crear': false,
    'Modificar': false,
    'Eliminar': false,
  };
  User? _selectedUser;
  List<User> _users = [];
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _fetchUsers();
  }

  Future<void> _fetchUsers() async {
    List<User> users = await _userService.fetchUsers();
    setState(() {
      _users = users;
    });
  }

  void _registerOrUpdate() async {
    if (_formKey.currentState?.validate() ?? false) {
      String id = _selectedUser?.id ?? Uuid().v4();
      String name = _usernameController.text;
      String email = _emailController.text;

      User user = User(
        id: id,
        name: name,
        email: email,
        permissions: _permissions,
      );

      if (_selectedUser == null) {
        await _userService.createUser(user);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Usuario creado exitosamente')),
        );
      } else {
        await _userService.updateUser(user);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Usuario actualizado exitosamente')),
        );
      }

      _resetForm();
      await _fetchUsers();
      Navigator.pushReplacementNamed(context, '/home');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error al crear/actualizar el usuario')),
      );
    }
  }

  void _resetForm() {
    _usernameController.clear();
    _emailController.clear();
    setState(() {
      _permissions.updateAll((key, value) => false);
      _selectedUser = null;
    });
  }

  void _selectUser(User user) {
    _usernameController.text = user.name;
    _emailController.text = user.email;
    setState(() {
      _permissions.addAll(user.permissions);
      _selectedUser = user;
    });
  }

  @override
  Widget build(BuildContext context) {
    List<User> filteredUsers = _users.where((user) {
      return user.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          user.email.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Registrar/Actualizar Usuario'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              showSearch(
                context: context,
                delegate: UserSearchDelegate(users: filteredUsers, onSelected: _selectUser),
              );
            },
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
          child: Padding(
            padding: const EdgeInsets.all(16.0),
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
                          if (value == null || value.isEmpty) {
                            return 'Por favor, ingrese su correo electrónico';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      Expanded(
                        child: ListView(
                          children: _permissions.keys.map((permission) {
                            return SwitchListTile(
                              title: Text(permission),
                              value: _permissions[permission]!,
                              activeColor: Theme.of(context).colorScheme.primary,
                              onChanged: (bool value) {
                                setState(() {
                                  _permissions[permission] = value;
                                });
                              },
                            );
                          }).toList(),
                        ),
                      ),
                      ElevatedButton.icon(
                        onPressed: _registerOrUpdate,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).colorScheme.primary,
                          minimumSize: const Size.fromHeight(50),
                        ),
                        icon: Icon(_selectedUser == null ? Icons.person_add : Icons.update),
                        label: Text(_selectedUser == null ? 'Crear Usuario' : 'Actualizar Usuario'),
                      ),
                      if (_selectedUser != null)
                        TextButton(
                          onPressed: _resetForm,
                          child: const Text('Cancelar'),
                        ),
                    ],
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
    super.dispose();
  }
}

class UserSearchDelegate extends SearchDelegate<User> {
  final List<User> users;
  final Function(User) onSelected;

  UserSearchDelegate({required this.users, required this.onSelected});

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        close(context, User(id: '', name: '', email: '', permissions: {}));
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    final List<User> filteredUsers = users.where((user) {
      return user.name.toLowerCase().contains(query.toLowerCase()) ||
          user.email.toLowerCase().contains(query.toLowerCase());
    }).toList();

    return ListView.builder(
      itemCount: filteredUsers.length,
      itemBuilder: (context, index) {
        final User user = filteredUsers[index];
        return ListTile(
          title: Text(user.name),
          subtitle: Text(user.email),
          onTap: () {
            onSelected(user);
            close(context, user);
          },
        );
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    final List<User> filteredUsers = users.where((user) {
      return user.name.toLowerCase().contains(query.toLowerCase()) ||
          user.email.toLowerCase().contains(query.toLowerCase());
    }).toList();

    return ListView.builder(
      itemCount: filteredUsers.length,
      itemBuilder: (context, index) {
        final User user = filteredUsers[index];
        return ListTile(
          title: Text(user.name),
          subtitle: Text(user.email),
          onTap: () {
            onSelected(user);
            close(context, user);
          },
        );
      },
    );
  }
}
