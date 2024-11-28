import 'package:flutter/material.dart';
import 'package:crypto/crypto.dart'; // Import the crypto package
import 'dart:convert'; // For utf8 encoding
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tugas_akhir/pages/loginPage.dart';

String hashPassword(String password) {
  final bytes = utf8.encode(password); // Convert password to bytes
  final digest = sha256.convert(bytes); // Hash with SHA-256
  return digest.toString(); // Return the hashed password as a string
}

class RegisterPage extends StatefulWidget {
  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  Future<void> _register() async {
    final username = _usernameController.text.trim();
    final password = _passwordController.text.trim();

    if (username.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Username dan password tidak boleh kosong')));
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    final hashedPassword = hashPassword(password);

    await prefs.setString('username', username);
    await prefs.setString('password', hashedPassword);

    // Show success message
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text('Registrasi berhasil')));

    // Navigate to LoginPage
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          "Register",
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: const Color.fromARGB(255, 227, 142, 73),
        automaticallyImplyLeading: false, // Hapus tombol kembali
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Tambahkan logo di atas kolom pengisian (opsional)
                Image.asset(
                  'assets/logo.png', // Pastikan file logo ada di folder assets
                  height: 200,
                  width: 200,
                ),
                SizedBox(height: 20),
                TextField(
                  controller: _usernameController,
                  decoration: InputDecoration(
                    labelText: 'Username',
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 10),
                TextField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _register,
                  child: Text(
                    'Register',
                    style: TextStyle(color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 227, 142, 73),
                    minimumSize: Size(double.infinity, 50),
                  ),
                ),
                SizedBox(height: 20),
                // Teks untuk mengarahkan ke halaman login
                TextButton(
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => LoginPage()),
                    );
                  },
                  child: Text(
                    'Already have an account? Login',
                    style: TextStyle(
                      color: const Color.fromARGB(255, 31, 80, 154),
                      fontSize: 16,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
