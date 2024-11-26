import 'package:flutter/material.dart';
import 'package:crypto/crypto.dart'; // Import the crypto package
import 'dart:convert'; // For utf8 encoding
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tugas_akhir/pages/home_page.dart'; // Pastikan import HomePage

// Fungsi untuk mengenkripsi password menggunakan SHA-256 (hashing)
String hashPassword(String password) {
  final bytes = utf8.encode(password); // Convert password to bytes
  final digest = sha256.convert(bytes); // Hash with SHA-256
  return digest.toString(); // Return the hashed password as a string
}

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoggedIn = false;

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  // Cek status login
  Future<void> _checkLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    setState(() {
      _isLoggedIn = token != null;
    });
  }

  // Fungsi untuk login
  Future<void> _login() async {
    final username = _usernameController.text;
    final password = _passwordController.text;

    final prefs = await SharedPreferences.getInstance();
    final storedUsername = prefs.getString('username');
    final storedHashedPassword = prefs.getString('password');

    if (storedUsername != null &&
        storedHashedPassword != null &&
        username == storedUsername) {
      final hashedPassword = hashPassword(password);
      if (hashedPassword == storedHashedPassword) {
        // Login berhasil
        await prefs.setString('token', 'your_session_token_here');
        setState(() {
          _isLoggedIn = true;
        });
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Login berhasil')));

        // Arahkan ke halaman Home dan kirim username
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => HomePage(), // Kirim username ke HomePage
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Username atau password salah')));
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Username atau password salah')));
    }
  }

  // Fungsi untuk logout
  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    setState(() {
      _isLoggedIn = false;
    });
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text('Logout berhasil')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Login")),
      body: _isLoggedIn
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("You are logged in!"),
                  ElevatedButton(
                    onPressed: _logout,
                    child: Text("Logout"),
                  ),
                ],
              ),
            )
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  TextField(
                    controller: _usernameController,
                    decoration: InputDecoration(labelText: 'Username'),
                  ),
                  TextField(
                    controller: _passwordController,
                    obscureText: true,
                    decoration: InputDecoration(labelText: 'Password'),
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _login,
                    child: Text('Login'),
                  ),
                  SizedBox(height: 20),
                  TextButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/register');
                    },
                    child: Text('Don\'t have an account? Register'),
                  )
                ],
              ),
            ),
    );
  }
}