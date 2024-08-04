import 'package:flutter/material.dart';
import 'package:vivero/models/user.dart';
import 'package:vivero/services/UserService.dart';

class UserSearchDelegate extends SearchDelegate<User> {
  final UserService userService;

  UserSearchDelegate({required this.userService});

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
        close(context, User(id: '', name: '', email: null, password: '', modulePermissions: {}));
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return FutureBuilder<List<User>>(
      future: userService.fetchUsers(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('No hay usuarios disponibles'));
        } else {
          List<User> users = snapshot.data!.where((user) {
            return user.name.toLowerCase().contains(query.toLowerCase()) ||
                   (user.email?.toLowerCase().contains(query.toLowerCase()) ?? false);
          }).toList();

          if (users.isEmpty) {
            return const Center(child: Text('No se encontraron usuarios'));
          }

          return ListView.builder(
            itemCount: users.length,
            itemBuilder: (context, index) {
              User user = users[index];
              return ListTile(
                title: Text(user.name),
                subtitle: Text(user.email ?? ''),
                onTap: () {
                  close(context, user);
                },
              );
            },
          );
        }
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return buildResults(context);
  }
}
