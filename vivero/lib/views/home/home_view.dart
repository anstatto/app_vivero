import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vivero/models/user.dart';
import 'package:vivero/providers/user_provider.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    Color themeColor = Theme.of(context).colorScheme.primary;
    final userProvider = Provider.of<UserProvider>(context);
    final User user = userProvider.user!;
    final bool isAdmin = userProvider.isAdmin;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Inicio Vivero'),
        backgroundColor: themeColor,
        actions: <Widget>[
          PopupMenuButton<String>(
            icon: Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: const Padding(
                padding: EdgeInsets.all(3),
                child: Icon(
                  Icons.settings,
                  size: 30,
                  color: Colors.black,
                ),
              ),
            ),
            offset: const Offset(0, 45),
            onSelected: (String result) {
              if (result == 'configuraciones') {
                Navigator.pushNamed(context, '/configuraciones');
              } else if (result == 'cerrar_sesion') {
                userProvider.clearUser();
                Navigator.pushReplacementNamed(context, '/login');
              }
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
              if (isAdmin)
                const PopupMenuItem<String>(
                  value: 'configuraciones',
                  child: Text('Configuraciones'),
                ),
              const PopupMenuItem<String>(
                value: 'cerrar_sesion',
                child: Text('Cerrar Sesión'),
              ),
            ],
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              decoration: BoxDecoration(
                color: themeColor,
              ),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    const CircleAvatar(
                      backgroundImage: AssetImage('lib/images/no_content.png'),
                      radius: 30.0,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Bienvenido, ${user.name}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                      ),
                    ),
                    Text(
                      user.email ?? '',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (isAdmin || user.modulePermissions['Productos']!['Mostrar']!)
              ExpansionTile(
                leading: const Icon(Icons.store),
                title: const Text('Productos'),
                children: <Widget>[
                  if (isAdmin || user.modulePermissions['Productos']!['Crear']!)
                    ListTile(
                      leading: const Icon(Icons.add),
                      title: const Text('Crear Producto'),
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.pushNamed(context, '/product/create');
                      },
                    ),
                  ListTile(
                    leading: const Icon(Icons.list),
                    title: const Text('Lista de Productos'),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.pushNamed(context, '/products');
                    },
                  ),
                ],
              ),
            if (isAdmin || user.modulePermissions['Clientes']!['Mostrar']!)
              ExpansionTile(
                leading: const Icon(Icons.people),
                title: const Text('Clientes'),
                children: <Widget>[
                  if (isAdmin || user.modulePermissions['Clientes']!['Crear']!)
                    ListTile(
                      leading: const Icon(Icons.group_add),
                      title: const Text('Añadir Cliente'),
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.pushNamed(context, '/customer/create');
                      },
                    ),
                  ListTile(
                    leading: const Icon(Icons.list_alt),
                    title: const Text('Lista de Clientes'),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.pushNamed(context, '/customers');
                    },
                  ),
                ],
              ),
            if (isAdmin || user.modulePermissions['Facturación']!['Mostrar']!)
              ExpansionTile(
                leading: const Icon(Icons.receipt),
                title: const Text('Facturación'),
                children: <Widget>[
                  if (isAdmin || user.modulePermissions['Facturación']!['Crear']!)
                    ListTile(
                      leading: const Icon(Icons.add_shopping_cart),
                      title: const Text('Nueva Factura'),
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.pushNamed(context, '/invoice/create');
                      },
                    ),
                  ListTile(
                    leading: const Icon(Icons.list_alt),
                    title: const Text('Historial de Facturas'),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.pushNamed(context, '/invoices');
                    },
                  ),
                ],
              ),
          ],
        ),
      ),
      backgroundColor: Theme.of(context).colorScheme.primaryContainer,
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Card(
              child: ListTile(
                leading: Icon(Icons.local_florist, color: themeColor),
                title: const Text('Último Producto Añadido'),
                subtitle: const Text('Orquidea'),
              ),
            ),
            Card(
              child: ListTile(
                leading: Icon(Icons.monetization_on, color: themeColor),
                title: const Text('Ventas del Día'),
                subtitle: const Text('\$1,234.00'),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: (isAdmin || user.modulePermissions['Productos']!['Crear']!)
          ? FloatingActionButton(
              onPressed: () {
                Navigator.pushNamed(context, '/product/create');
              },
              backgroundColor: themeColor,
              child: const Icon(
                Icons.add,
                color: Colors.white,
              ),
            )
          : null,
    );
  }
}
