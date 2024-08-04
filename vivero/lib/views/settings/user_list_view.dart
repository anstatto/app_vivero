import 'package:flutter/material.dart';
import 'package:vivero/services/UserService.dart';
import 'package:vivero/models/user.dart';

class UserListView extends StatefulWidget {
  const UserListView({Key? key}) : super(key: key);

  @override
  _UserListViewState createState() => _UserListViewState();
}

class _UserListViewState extends State<UserListView> {
  final UserService _userService = UserService();
  List<User> _users = [];
  String _searchQuery = '';
  Map<String, bool> _showPassword = {};

  @override
  void initState() {
    super.initState();
    _fetchUsers();
  }

  void _fetchUsers() async {
    List<User> users = await _userService.fetchUsers();
    setState(() {
      _users = users;
      _showPassword = {for (var user in users) user.id: false};
    });
  }

  void _deactivateUser(String id) async {
    await _userService.deactivateUser(id);
    _fetchUsers();
  }

  Future<bool?> _showConfirmationDialog() async {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmación'),
        content:
            const Text('¿Estás seguro de que deseas desactivar este usuario?'),
        actions: <Widget>[
          TextButton(
            child: const Text('Cancelar'),
            onPressed: () => Navigator.of(context).pop(false),
          ),
          TextButton(
            child: const Text('Desactivar'),
            onPressed: () => Navigator.of(context).pop(true),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    Color themeColor = Theme.of(context).colorScheme.primary;

    List<User> filteredUsers = _users.where((user) {
      return user.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          (user.email != null &&
              user.email!.toLowerCase().contains(_searchQuery.toLowerCase()));
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Lista de Usuarios'),
        backgroundColor: themeColor,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              decoration: const InputDecoration(
                labelText: 'Buscar',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
            ),
          ),
          Expanded(
            child: filteredUsers.isEmpty
                ? const Center(child: Text('No hay usuarios disponibles'))
                : ListView.builder(
                    itemCount: filteredUsers.length,
                    itemBuilder: (context, index) {
                      User user = filteredUsers[index];
                      return Card(
                        child: ListTile(
                          title: Text(user.name),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(user.email ?? ''),
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      _showPassword[user.id] ?? false
                                          ? user.password
                                          : '********', // Contraseña oculta con longitud fija
                                    ),
                                  ),
                                  IconButton(
                                    icon: Icon(
                                      _showPassword[user.id] ?? false
                                          ? Icons.visibility
                                          : Icons.visibility_off,
                                      color: _showPassword[user.id] ?? false
                                          ? Colors.blue
                                          : Colors.red,
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        _showPassword[user.id] =
                                            !_showPassword[user.id]!;
                                      });
                                    },
                                  ),
                                ],
                              ),
                            ],
                          ),
                          trailing: Switch(
                            value: user.isActive,
                            onChanged: (value) async {
                              if (!value) {
                                bool confirm =
                                    (await _showConfirmationDialog()) ?? false;
                                if (confirm) {
                                  _deactivateUser(user.id);
                                }
                              }
                            },
                            activeColor: themeColor,
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
