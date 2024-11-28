import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tugas_akhir/models/game.dart';
import 'package:tugas_akhir/pages/loginPage.dart';

class SearchResultPage extends StatefulWidget {
  final List<Game> searchResults;

  SearchResultPage({required this.searchResults});

  @override
  _SearchResultPageState createState() => _SearchResultPageState();
}

class _SearchResultPageState extends State<SearchResultPage> {
  @override
  void initState() {
    super.initState();
    _validateSession(); // Verifikasi sesi pengguna
  }

  // Fungsi untuk memvalidasi sesi pengguna
  Future<void> _validateSession() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    if (token == null) {
      // Jika token tidak ada, arahkan ke halaman login
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => LoginPage()),
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Search Results",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color.fromARGB(255, 10, 57, 129),
      ),
      body: widget.searchResults.isEmpty
          ? Center(
              child: Text(
                "No results found",
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
            )
          : ListView.builder(
              itemCount: widget.searchResults.length,
              itemBuilder: (context, index) {
                final game = widget.searchResults[index];
                return Card(
                  margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  elevation: 3,
                  child: ListTile(
                    leading: ClipRRect(
                      borderRadius: BorderRadius.circular(8.0),
                      child: Image.network(
                        game.thumb.isNotEmpty
                            ? game.thumb
                            : 'https://via.placeholder.com/50',
                        width: 80,
                        height: 80,
                        fit: BoxFit.fill,
                        errorBuilder: (context, error, stackTrace) =>
                            const Icon(Icons.image_not_supported, size: 50),
                      ),
                    ),
                    title: Text(
                      game.title,
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      game.detailedPrice != null
                          ? "Price: \$${game.detailedPrice!.toStringAsFixed(2)}"
                          : "Price unavailable",
                      style: TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                    onTap: () {
                      // Navigasi ke halaman detail
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => GameDetailPage(game: game),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
    );
  }
}

class GameDetailPage extends StatefulWidget {
  final Game game;

  GameDetailPage({required this.game});

  @override
  _GameDetailPageState createState() => _GameDetailPageState();
}

class _GameDetailPageState extends State<GameDetailPage> {
  @override
  void initState() {
    super.initState();
    _validateSession(); // Verifikasi sesi pengguna
  }

  // Fungsi untuk memvalidasi sesi pengguna
  Future<void> _validateSession() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    if (token == null) {
      // Jika token tidak ada, arahkan ke halaman login
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => LoginPage()),
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          widget.game.title,
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color.fromARGB(255, 10, 57, 129),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Image.network(
                widget.game.thumb,
                height: 250,
                fit: BoxFit.fill,
              ),
              SizedBox(height: 16),
              Text(
                widget.game.title,
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text(
                widget.game.detailedPrice != null
                    ? "Price: \$${widget.game.detailedPrice!.toStringAsFixed(2)}"
                    : "Price unavailable",
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
              SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
