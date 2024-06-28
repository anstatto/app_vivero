import 'package:flutter/material.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    Color themeColor = Colors.green.shade600;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Inicio Vivero'),
        backgroundColor: themeColor, // Usar el color temático aquí
        actions: <Widget>[
          PopupMenuButton<String>(
            icon: Container(
              decoration: const BoxDecoration(
                color: Colors.white, // Fondo blanco
                shape: BoxShape.circle, // Forma circular
              ),
              child: const Padding(
                padding: EdgeInsets.all(3), // Espaciado alrededor del icono para el fondo blanco
                child: Icon(
                  Icons.settings,
                  size: 30, // Tamaño del icono
                  color: Colors.black, // Color del icono
                ),
              ),
            ),
            offset: const Offset(0, 45), // Ajustar la posición del menú
            onSelected: (String result) {
              if (result == 'configuraciones') {
                Navigator.pushNamed(context, '/configuraciones');
              } else if (result == 'cerrar_sesion') {
                // Implementa tu lógica para cerrar sesión aquí
                Navigator.pushReplacementNamed(context, '/login');
              }
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
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
              child: const SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    CircleAvatar(
                      backgroundImage: AssetImage('lib/images/no_content.png'), // Imagen del usuario
                      radius: 40.0,
                    ),
                    SizedBox(height: 10), // Espacio entre la imagen y el texto
                    Text(
                      'Bienvenido, Administrador', // Nombre del usuario
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            ExpansionTile(
              leading: const Icon(Icons.store),
              title: const Text('Productos'),
              children: <Widget>[
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
            ExpansionTile(
              leading: const Icon(Icons.people),
              title: const Text('Clientes'),
              children: <Widget>[
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
            ExpansionTile(
              leading: const Icon(Icons.receipt),
              title: const Text('Facturación'),
              children: <Widget>[
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
      backgroundColor: Colors.green.shade100,
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
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, '/product/create');
        },
        backgroundColor: themeColor, // Color de fondo del botón flotante
        child: const Icon(
          Icons.add,
          color: Colors.white, // Color del icono
        ),
      ),
    );
  }
}
