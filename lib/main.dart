import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';

// Screens
import 'screens/auth_screen.dart';
import 'screens/register_screen.dart';
import 'screens/products_screen.dart';
import 'screens/home_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/carrito_screen.dart';
import 'screens/checkout_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tienda 3D',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      debugShowCheckedModeBanner: false,
      home: FirebaseAuth.instance.currentUser == null
          ? const AuthScreen()
          : const MainNavigation(),

      // ✅ Rutas nombradas
      routes: {
        '/auth': (context) => const AuthScreen(),
        '/register': (context) => const RegisterScreen(),
        '/main': (context) => const MainNavigation(),

        // ✅ Ruta para carrito de compras
        '/carrito': (context) {
          final carrito =
              ModalRoute.of(context)!.settings.arguments
                  as List<Map<String, dynamic>>;
          return CarritoScreen(carrito: carrito);
        },

        // ✅ Ruta para checkout
        '/checkout': (context) {
          final carrito =
              ModalRoute.of(context)!.settings.arguments
                  as List<Map<String, dynamic>>;
          return CheckoutScreen(carrito: carrito);
        },
      },
    );
  }
}

// ✅ Widget principal con navegación inferior
class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _selectedIndex = 0;

  final List<Widget> _screens = const [
    HomeScreen(),
    ProductosScreen(),
    ProfileScreen(),
  ];

  final List<BottomNavigationBarItem> _navItems = const [
    BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Inicio'),
    BottomNavigationBarItem(icon: Icon(Icons.shopping_bag), label: 'Productos'),
    BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Perfil'),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: _navItems,
        selectedItemColor: Colors.deepPurple,
      ),
    );
  }
}
