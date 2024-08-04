import 'package:flutter/material.dart';

class SettingsView extends StatelessWidget {
  const SettingsView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Color themeColor = Theme.of(context).colorScheme.primary;
    Color backgroundColor = Theme.of(context).colorScheme.primaryContainer;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Configuraciones'),
        backgroundColor: themeColor,
      ),
      backgroundColor: backgroundColor,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: <Widget>[
            ListTile(
              leading: Icon(Icons.person, color: themeColor),
              title: const Text('Usuarios'),
              onTap: () {
                Navigator.pushNamed(context, '/users');
              },
            ),
            ListTile(
              leading: Icon(Icons.person_search, color: themeColor),
              title: const Text('Consultar'),
              onTap: () {
                Navigator.pushNamed(context, '/consulta/usuario');
              },
            ),
            // Añadir más opciones según necesites
          ],
        ),
      ),
    );
  }
}
