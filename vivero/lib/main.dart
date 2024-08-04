import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vivero/firebase_options.dart';
import 'package:vivero/models/user.dart';
import 'package:vivero/providers/user_provider.dart';
import 'package:vivero/views/customers/customer_create.dart';
import 'package:vivero/views/customers/customers_list_view.dart';
import 'package:vivero/views/facturas/invoice_create.dart';
import 'package:vivero/views/facturas/invoices_list_view.dart';
import 'package:vivero/views/home/home_view.dart';
import 'package:vivero/views/products/product_create.dart';
import 'package:vivero/views/products/products_list_view.dart';
import 'package:vivero/views/login/login_view.dart';
import 'package:vivero/views/settings/settings_view.dart';
import 'package:vivero/views/settings/user_list_view.dart';
import 'package:vivero/views/settings/users_view.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(
    ChangeNotifierProvider(
      create: (context) => UserProvider(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);
  static const Color themeColor = Colors.green;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Sistema de Punto.',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: themeColor),
        primaryColor: Colors.blue,
        scaffoldBackgroundColor: const Color(0xFFF5F5F5),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          elevation: 0,
          titleTextStyle: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        textTheme: const TextTheme(
          bodyLarge: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Colors.black,
          ),
          bodyMedium: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w400,
            color: Colors.black,
          ),
          titleLarge: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
          titleMedium: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
          titleSmall: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ).apply(
          fontFamily: 'Roboto',
          displayColor: Colors.black,
          bodyColor: Colors.black,
        ),
      ),
      initialRoute: '/login',
      routes: {
        '/login': (context) => const LoginView(),
        '/home': (context) => const HomeView(),
        '/product/create': (context) => const ProductCreateView(),
        '/products': (context) => const ProductListView(),
        '/customer/create': (context) => const CustomerCreateView(),
        '/customers': (context) => const CustomerListView(),
        '/invoice/create': (context) => const InvoiceScreen(),
        '/invoices': (context) => const InvoiceFilterScreen(),
        '/configuraciones': (context) => const SettingsView(),
        '/consulta/usuario': (context) => const UserListView(),
      },
      onGenerateRoute: (settings) {
        if (settings.name == '/users') {
          final args = settings.arguments as Map<String, dynamic>?;
          return MaterialPageRoute(
            builder: (context) {
              return RegisterView(
                user: args?['user'] as User?,
                onSave: args?['onSave'] as Function?,
              );
            },
          );
        }
        return null;
      },
    );
  }
}
