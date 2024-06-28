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

  @override
  void initState() {
    super.initState();
    _fetchUsers();
  }

  void _fetchUsers() async {
    List<User> users = await _userService.fetchUsers();
    setState(() {
      _users = users;
    });
  }

  void _deactivateUser(String id) async {
    await _userService.deactivateUser(id);
    _fetchUsers();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lista de Usuarios'),
        backgroundColor: Colors.green.shade600,
      ),
      body: ListView.builder(
        itemCount: _users.length,
        itemBuilder: (context, index) {
          User user = _users[index];
          return ListTile(
            title: Text(user.name),
            subtitle: Text(user.email),
            trailing: Switch(
              value: user.isActive,
              onChanged: (value) {
                if (!value) {
                  _deactivateUser(user.id);
                }
              },
            ),
          );
        },
      ),
    );
  }
}
