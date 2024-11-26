import 'package:flutter/material.dart';
import 'package:tugas_akhir/models/game.dart';
import 'package:tugas_akhir/database/wishlist_database.dart';
import 'package:tugas_akhir/providers/currencyProvider.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tugas_akhir/pages/loginPage.dart';

class DetailPage extends StatefulWidget {
  final Game game;

  DetailPage({required this.game});

  @override
  _DetailPageState createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  bool isWishlisted = false;

  @override
  void initState() {
    super.initState();
    _validateSession(); // Validasi sesi pengguna
    _checkWishlist();
  }

  // Fungsi untuk memvalidasi sesi
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

  Future<void> _checkWishlist() async {
    final wishlist = await WishlistDatabase.instance.getWishlist();
    setState(() {
      isWishlisted = wishlist.any((item) => item['id'] == widget.game.id);
    });
  }

  Future<void> _toggleWishlist() async {
    try {
      if (isWishlisted) {
        await WishlistDatabase.instance.removeFromWishlist(widget.game.id);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${widget.game.title} removed from wishlist')),
        );
      } else {
        final gameData = {
          'id': widget.game.id,
          'title': widget.game.title,
          'price': widget.game.price,
          'originalPrice': widget.game.originalPrice,
          'discount': widget.game.discount,
          'thumb': widget.game.thumb,
          'store': widget.game.store
        };
        await WishlistDatabase.instance.addToWishlist(gameData);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${widget.game.title} added to wishlist')),
        );
      }
      _checkWishlist(); // Refresh state
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Item ini telah masuk dalam wishlist')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final currencyProvider = Provider.of<CurrencyProvider>(context);
    final rate = currencyProvider.getRate(currencyProvider.currentCurrency);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.game.title),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Image.network(
              widget.game.thumb,
              height: 250,
              fit: BoxFit.fill,
              errorBuilder: (context, error, stackTrace) =>
                  Icon(Icons.image_not_supported, size: 250),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.game.title,
                    style: TextStyle(
                      fontSize: 24.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 16.0),
                  Text(
                    widget.game.price > 0
                        ? "${currencyProvider.currentCurrency} ${(widget.game.price * rate).toStringAsFixed(2)}"
                        : "Price unavailable",
                    style: TextStyle(
                      fontSize: 20.0,
                      color: widget.game.price > 0 ? Colors.green : Colors.grey,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (widget.game.originalPrice > 0) ...[
                    SizedBox(height: 8.0),
                    Text(
                      "Original Price: ${currencyProvider.currentCurrency} ${(widget.game.originalPrice * rate).toStringAsFixed(2)}",
                      style: TextStyle(
                        fontSize: 18.0,
                        color: Colors.grey,
                        decoration: TextDecoration.lineThrough,
                      ),
                    ),
                    SizedBox(height: 8.0),
                    Text(
                      "Discount: ${((widget.game.originalPrice - widget.game.price) / widget.game.originalPrice * 100).toStringAsFixed(1)}%",
                      style: TextStyle(
                        fontSize: 14.0,
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8.0),
                    Text(
                      "You save ${((widget.game.originalPrice - widget.game.price) * rate).toStringAsFixed(2)}!",
                      style: TextStyle(
                        fontSize: 16.0,
                        color: Colors.red,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: DropdownButton<String>(
                value: currencyProvider.currentCurrency,
                onChanged: (String? newValue) {
                  if (newValue != null) {
                    currencyProvider.changeCurrency(newValue);
                  }
                },
                items:
                    currencyProvider.availableCurrencies.map((String currency) {
                  return DropdownMenuItem<String>(
                    value: currency,
                    child: Text(currency),
                  );
                }).toList(),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: ElevatedButton.icon(
                onPressed: _toggleWishlist,
                icon: Icon(
                  isWishlisted ? Icons.favorite : Icons.favorite_border,
                ),
                label: Text(
                  isWishlisted ? "Remove from Wishlist" : "Add to Wishlist",
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: isWishlisted ? Colors.red : Colors.blue,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
