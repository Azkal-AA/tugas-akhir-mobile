import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_swiper_null_safety/flutter_swiper_null_safety.dart';
import 'package:tugas_akhir/models/game.dart';
import 'package:tugas_akhir/pages/detailPage.dart';
import 'package:tugas_akhir/pages/dropdown.dart';
import 'package:tugas_akhir/pages/notificationPage.dart';
import 'package:tugas_akhir/pages/searchResultPage.dart';
import 'package:tugas_akhir/pages/wishlistPage.dart';
import 'package:tugas_akhir/providers/game_provider.dart';
import 'package:tugas_akhir/providers/currencyProvider.dart';
import 'package:tugas_akhir/pages/profile_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  String _username = "Guest"; // Default username
  File? _profileImage; // Variable to store profile image

  @override
  void initState() {
    super.initState();
    _validateSession(); // Tambahkan validasi sesi
    _loadUserData(); // Memuat data pengguna
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<GameProvider>(context, listen: false).fetchDeals();
    });
  }

// Fungsi untuk memvalidasi sesi
  Future<void> _validateSession() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (token == null) {
      // Jika token tidak ada, arahkan ke halaman login
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushReplacementNamed(context, '/login');
      });
    }
  }

  // Function to load user data from SharedPreferences
  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _username = prefs.getString('username') ?? "Guest";
      String? imagePath = prefs.getString('profileImage');
      if (imagePath != null && File(imagePath).existsSync()) {
        _profileImage = File(imagePath);
      }
    });
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final gameProvider = Provider.of<GameProvider>(context);
    final currencyProvider = Provider.of<CurrencyProvider>(context);

    final List<Widget> pages = [
      Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            automaticallyImplyLeading: false,
            backgroundColor: const Color.fromARGB(255, 10, 57, 129),
            title: TextField(
              decoration: InputDecoration(
                hintText: "Search games...",
                border: InputBorder.none,
                hintStyle: TextStyle(color: Colors.white),
              ),
              style: TextStyle(color: Colors.white),
              onSubmitted: (value) async {
                if (value.isNotEmpty) {
                  final gameProvider =
                      Provider.of<GameProvider>(context, listen: false);
                  List<Game> searchResults =
                      await gameProvider.searchGamesWithDetails(value);

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          SearchResultPage(searchResults: searchResults),
                    ),
                  );
                }
              },
            ),
            actions: [
              GestureDetector(
                onTap: () async {
                  // Navigasikan ke halaman ProfilePage dan tunggu hasilnya
                  await Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => ProfilePage()),
                  );
                  // Setelah kembali, muat ulang data pengguna (foto profil)
                  _loadUserData();
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Row(
                    children: [
                      // Tampilkan nama pengguna
                      Text(
                        _username,
                        style: TextStyle(color: Colors.white),
                      ),
                      SizedBox(width: 8.0),
                      // Tampilkan gambar profil atau placeholder
                      CircleAvatar(
                        backgroundImage: _profileImage != null
                            ? FileImage(_profileImage!)
                            : NetworkImage('https://via.placeholder.com/150')
                                as ImageProvider,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          body: Consumer<GameProvider>(
            builder: (context, gameProvider, child) {
              return gameProvider.isLoading
                  ? Center(child: CircularProgressIndicator())
                  : gameProvider.games.isEmpty
                      ? Center(child: Text("No games found"))
                      : Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: CurrencyDropdown(),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Text(
                                'Featured',
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            Container(
                              height: 450,
                              child: Swiper(
                                itemCount: gameProvider.games.length,
                                itemBuilder: (context, index) {
                                  final game = gameProvider.games[index];
                                  return GameCarouselItem(game: game);
                                },
                                autoplay: true,
                                loop: true,
                                itemWidth: double.infinity,
                                layout: SwiperLayout.DEFAULT,
                                control: SwiperControl(),
                              ),
                            ),
                          ],
                        );
            },
          )),
      WishlistPage(),
      // NotificationPage(),
    ];

    return Scaffold(
      body: pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite),
            label: 'Wishlist',
          ),
          // BottomNavigationBarItem(
          //   icon: Icon(Icons.notifications),
          //   label: 'Notification',
          // ),
        ],
        currentIndex: _selectedIndex,
        unselectedItemColor: Colors.white,
        backgroundColor: const Color.fromARGB(255, 10, 57, 129),
        selectedItemColor: const Color.fromARGB(255, 227, 142, 73),
        onTap: _onItemTapped,
      ),
    );
  }
}

class GameCarouselItem extends StatelessWidget {
  final Game game;

  GameCarouselItem({required this.game});

  @override
  Widget build(BuildContext context) {
    final currencyProvider = Provider.of<CurrencyProvider>(context);
    final rate = currencyProvider.getRate(currencyProvider.currentCurrency);

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DetailPage(game: game),
          ),
        );
      },
      child: Card(
        margin: EdgeInsets.all(8.0),
        elevation: 3,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(10.0),
                topRight: Radius.circular(10.0),
              ),
              child: Image.network(
                game.thumb,
                height: 300,
                fit: BoxFit.fill,
                errorBuilder: (context, error, stackTrace) =>
                    Icon(Icons.image_not_supported, size: 200),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    game.title,
                    style: TextStyle(
                      fontSize: 18.0,
                      fontWeight: FontWeight.bold,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 8.0),
                  Row(
                    children: [
                      Text(
                        "${currencyProvider.currentCurrency} ${(game.price * rate).toStringAsFixed(2)}",
                        style: TextStyle(
                          fontSize: 16.0,
                          color: Colors.green,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(width: 8.0),
                      if (game.originalPrice > 0)
                        Text(
                          "${currencyProvider.currentCurrency} ${(game.originalPrice * rate).toStringAsFixed(2)}",
                          style: TextStyle(
                            fontSize: 14.0,
                            color: Colors.grey,
                            decoration: TextDecoration.lineThrough,
                          ),
                        ),
                    ],
                  ),
                  SizedBox(height: 8.0),
                  if (game.originalPrice > 0)
                    Text(
                      "Discount: ${((game.originalPrice - game.price) / game.originalPrice * 100).toStringAsFixed(1)}%",
                      style: TextStyle(
                        fontSize: 14.0,
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
