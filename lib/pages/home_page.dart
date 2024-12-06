import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_swiper_null_safety/flutter_swiper_null_safety.dart';
import 'package:tugas_akhir/models/game.dart';
import 'package:tugas_akhir/pages/detailPage.dart';
import 'package:tugas_akhir/pages/dropdown.dart';
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
  String _username = "Guest";
  File? _profileImage;

  @override
  void initState() {
    super.initState();
    _validateSession();
    _loadUserData();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<GameProvider>(context, listen: false).fetchDeals();
    });
  }

  Future<void> _validateSession() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (token == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushReplacementNamed(context, '/login');
      });
    }
  }

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

  Widget _buildDealsSwiper(String storeID, String storeName) {
    return FutureBuilder<List<Game>>(
      future: Provider.of<GameProvider>(context, listen: false)
          .fetchDealsByStore(storeID),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError ||
            snapshot.data == null ||
            snapshot.data!.isEmpty) {
          return Center(child: Text("No deals found for $storeName"));
        } else {
          final games = snapshot.data!;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Text(
                  '$storeName Deals',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),
              Container(
                height: MediaQuery.of(context).size.height * 0.45,
                child: Swiper(
                  itemCount: games.length,
                  itemBuilder: (context, index) {
                    final game = games[index];
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
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
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
                await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ProfilePage()),
                );
                _loadUserData();
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Row(
                  children: [
                    Text(
                      _username,
                      style: TextStyle(color: Colors.white),
                    ),
                    SizedBox(width: 8.0),
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
                    : SingleChildScrollView(
                        child: Column(
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
                              height: MediaQuery.of(context).size.height * 0.45,
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
                            _buildDealsSwiper('1', 'Steam'),
                            _buildDealsSwiper('7', 'GOG'),
                            _buildDealsSwiper('8', 'Origin'),
                            _buildDealsSwiper('13', 'Uplay'),
                            _buildDealsSwiper('25', 'Epic Games Store'),
                          ],
                        ),
                      );
          },
        ),
      ),
      WishlistPage(),
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
                            fontSize: 16.0,
                            decoration: TextDecoration.lineThrough,
                            color: Colors.grey,
                          ),
                        ),
                    ],
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
