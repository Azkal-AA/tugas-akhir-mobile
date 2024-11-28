import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tugas_akhir/pages/home_page.dart';
import 'package:tugas_akhir/pages/loginPage.dart';
import 'package:tugas_akhir/pages/registerPage.dart';
import 'package:tugas_akhir/providers/game_provider.dart';
import 'package:tugas_akhir/providers/currencyProvider.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart'; // Import the plugin
import 'package:timezone/data/latest.dart' as tz;

// Create a global instance of FlutterLocalNotificationsPlugin
final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

void main() {
  // Inisialisasi notifikasi sebelum menjalankan aplikasi
  WidgetsFlutterBinding.ensureInitialized();
  tz.initializeTimeZones();
  initializeNotifications(); // Memanggil fungsi inisialisasi

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => GameProvider()),
        ChangeNotifierProvider(
            create: (_) => CurrencyProvider()), // Inisialisasi provider
      ],
      child: MyApp(),
    ),
  );
}

// Fungsi untuk menginisialisasi notifikasi
void initializeNotifications() {
  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings(
          '@mipmap/gd'); // Ganti dengan nama ikon Anda

  const InitializationSettings initializationSettings =
      InitializationSettings(android: initializationSettingsAndroid);

  flutterLocalNotificationsPlugin.initialize(initializationSettings);
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Game Tracker',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: AuthGate(),
      routes: {
        '/login': (context) => LoginPage(),
        '/register': (context) => RegisterPage(),
        '/home': (context) => HomePage(),
      },
    );
  }
}

class AuthGate extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _checkToken(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else {
          final isLoggedIn = snapshot.data as bool;
          if (isLoggedIn) {
            return HomePage(); // Arahkan ke HomePage jika login
          } else {
            return LoginPage(); // Arahkan ke LoginPage jika tidak login
          }
        }
      },
    );
  }

  Future<bool> _checkToken() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    return token != null; // Return true jika token ada
  }
}
