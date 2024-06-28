import 'package:flutter/material.dart';

class SettingsView extends StatelessWidget {
  const SettingsView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
     Color themeColor = Colors.green.shade600;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Configuraciones'),
         backgroundColor: themeColor,
      ),
       backgroundColor: Colors.green.shade100,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: <Widget>[
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text('Usuarios'),
              onTap: () {
                Navigator.pushNamed(context, '/users');
              },
            ),
            
            // Añadir más opciones según necesites
          ],
        ),
      ),
    );
  }
}
