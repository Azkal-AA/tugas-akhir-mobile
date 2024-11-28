import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:tugas_akhir/pages/detailPage.dart';
import 'package:tugas_akhir/pages/loginPage.dart';
import 'package:tugas_akhir/providers/currencyProvider.dart';
import '../database/wishlist_database.dart';
import '../models/game.dart';
import 'package:intl/intl.dart';

FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

class WishlistPage extends StatefulWidget {
  @override
  _WishlistPageState createState() => _WishlistPageState();
}

class _WishlistPageState extends State<WishlistPage> {
  List<Map<String, dynamic>> wishlistGames = [];

  @override
  void initState() {
    super.initState();
    _validateSession();
    _loadWishlist();
  }

  Future<void> scheduleReminder(
      String gameTitle, tz.TZDateTime reminderTime) async {
    try {
      await flutterLocalNotificationsPlugin.zonedSchedule(
        0, // ID notifikasi unik
        'Game Reminder',
        'Don\'t forget to check the deal for $gameTitle!',
        reminderTime,
        const NotificationDetails(
          android: AndroidNotificationDetails(
              'reminder_channel', 'Reminder Notif',
              importance: Importance.high,
              priority: Priority.high,
              showWhen: false,
              icon: '@mipmap/ic_launcher'),
        ),
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      );
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Notification set for $gameTitle')),
      );
      print('Current time: ${DateTime.now()}');
      print('Reminder time: $reminderTime');
    } catch (e) {
      print('Failed to send notification: $e');
    }
  }

  void _showReminderDialog(BuildContext context, String gameTitle) {
    // Daftar zona waktu yang diizinkan
    final Map<String, String> timeZones = {
      "WIB": "Asia/Jakarta", // WIB - Jakarta
      "WITA": "Asia/Makassar", // WITA - Makassar
      "WIT": "Asia/Jayapura", // WIT - Jayapura
      "London": "Europe/London", // London
      "New York": "America/New_York", // New York
      "Sydney": "Australia/Sydney", // Sydney
      "Tokyo": "Asia/Tokyo", // Tokyo
    };

    String selectedTimeZone =
        timeZones["WIB"]!; // Default zona waktu digunakan (WIB)
    String targetTimeZone =
        timeZones["WIB"]!; // Default zona waktu konversi (WIB)
    TimeOfDay? selectedTime; // Waktu yang dipilih oleh pengguna

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return AlertDialog(
              title: Text("Set Reminder for $gameTitle"),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Menampilkan zona waktu yang digunakan (default: WIB)
                  Text(
                    "Using Time Zone: ${timeZones.entries.firstWhere((entry) => entry.value == selectedTimeZone).key}",
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 20),

                  // Dropdown untuk memilih zona waktu tujuan konversi
                  DropdownButton<String>(
                    value: timeZones.entries
                        .firstWhere((entry) => entry.value == targetTimeZone)
                        .key, // Mendapatkan nama zona waktu konversi
                    items: timeZones.keys.map((String timeZone) {
                      return DropdownMenuItem<String>(
                        value: timeZone,
                        child: Text(timeZone),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      if (newValue != null) {
                        setState(() {
                          targetTimeZone = timeZones[newValue]!;
                        });
                      }
                    },
                  ),
                  SizedBox(height: 20),

                  // Tombol untuk memilih waktu
                  TextButton(
                    onPressed: () async {
                      final TimeOfDay? pickedTime = await showTimePicker(
                        context: context,
                        initialTime: TimeOfDay.now(),
                      );
                      if (pickedTime != null) {
                        setState(() {
                          selectedTime = pickedTime;
                        });
                      }
                    },
                    child: Text(selectedTime == null
                        ? "Pick Time"
                        : "Selected Time: ${selectedTime!.format(context)}"),
                  ),
                  SizedBox(height: 10),

                  // Menampilkan waktu hasil konversi berdasarkan zona waktu tujuan
                  if (selectedTime != null)
                    Text(
                      "Converted Time: ${DateFormat('HH:mm:ss').format(
                        // Mengonversi waktu dari WIB ke zona waktu yang dipilih
                        tz.TZDateTime.from(
                          tz.TZDateTime(
                            tz.getLocation(selectedTimeZone), // Zona WIB
                            DateTime.now().year,
                            DateTime.now().month,
                            DateTime.now().day,
                            selectedTime!.hour,
                            selectedTime!.minute,
                          ),
                          tz.getLocation(
                              targetTimeZone), // Zona target (misalnya WITA)
                        ),
                      )}",
                      style:
                          TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                    ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text("Cancel"),
                ),
                TextButton(
                  onPressed: () {
                    if (selectedTime != null) {
                      // Konversi waktu dari WIB ke zona waktu target yang dipilih
                      final tz.TZDateTime reminderTime = tz.TZDateTime.from(
                        tz.TZDateTime(
                          tz.getLocation(selectedTimeZone),
                          DateTime.now().year,
                          DateTime.now().month,
                          DateTime.now().day,
                          selectedTime!.hour,
                          selectedTime!.minute,
                        ),
                        tz.getLocation(targetTimeZone),
                      );

                      // Panggil fungsi scheduleReminder
                      scheduleReminder(gameTitle, reminderTime);

                      Navigator.of(context).pop();
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("Please select a time.")),
                      );
                    }
                  },
                  child: Text("Set Reminder"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _validateSession() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    if (token == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => LoginPage()),
        );
      });
    }
  }

  Future<void> _loadWishlist() async {
    try {
      final wishlist = await WishlistDatabase.instance.getWishlist();
      setState(() {
        wishlistGames = wishlist;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load wishlist: $e')),
      );
    }
  }

  void checkPriceChanges(List<Map<String, dynamic>> wishlistGames) async {
    for (var gameData in wishlistGames) {
      final originalPrice = gameData['originalPrice'] ?? 0.0;
      final currentPrice = gameData['price'] ?? 0.0;

      // Jika harga telah berubah
      if (originalPrice != currentPrice) {
        final game = Game(
          id: gameData['id'].toString(),
          title: gameData['title'],
          price: gameData['price'],
          originalPrice: gameData['originalPrice'],
          discount: gameData['discount'],
          thumb: gameData['thumb'],
          store: gameData['store'] ?? 'Unknown',
        );
        // Kirimkan notifikasi
        await sendPriceChangeNotification(game);
      }
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Price check completed. Notifications sent.')),
    );
  }

  Future<void> sendPriceChangeNotification(Game game) async {
    try {
      final notificationId =
          game.id?.hashCode ?? DateTime.now().millisecondsSinceEpoch;

      print("Game ID: ${game.id}");
      const AndroidNotificationDetails androidPlatformChannelSpecifics =
          AndroidNotificationDetails(
        'price_change_channel',
        'Price Changes',
        importance: Importance.high,
        priority: Priority.high,
        icon: '@mipmap/ic_launcher',
      );

      const NotificationDetails platformChannelSpecifics =
          NotificationDetails(android: androidPlatformChannelSpecifics);

      await flutterLocalNotificationsPlugin.show(
        notificationId, // Default to a unique ID if game.id is null
        'Price Change Alert!',
        'The price of ${game.title} has changed to \$${game.price}',
        platformChannelSpecifics,
        payload: 'game_${game.id}',
      );
      print('Notification sent for ${game.title}');
    } catch (e) {
      print('Failed to send notification: $e');
    }
  }

  Future<void> _removeFromWishlist(String id) async {
    try {
      await WishlistDatabase.instance.removeFromWishlist(id);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Game removed from wishlist')),
      );
      _loadWishlist();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to remove game: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final currencyProvider = Provider.of<CurrencyProvider>(context);
    final rate = currencyProvider.getRate(currencyProvider.currentCurrency);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: const Color.fromARGB(255, 10, 57, 129),
        title: Text(
          "Your Wishlist",
          style: TextStyle(color: Colors.white),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.notifications_active_outlined),
            color: Colors.white,
            onPressed: () {
              if (wishlistGames.isNotEmpty) {
                checkPriceChanges(wishlistGames);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('No games in wishlist to check.')),
                );
              }
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Row(
              children: [
                Text(
                  "Currency: ",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                Expanded(
                  child: DropdownButton<String>(
                    value: currencyProvider.currentCurrency,
                    onChanged: (String? newValue) {
                      if (newValue != null) {
                        currencyProvider.changeCurrency(newValue);
                      }
                    },
                    items: currencyProvider.availableCurrencies
                        .map((String currency) {
                      return DropdownMenuItem<String>(
                        value: currency,
                        child: Text(currency),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: wishlistGames.isEmpty
                ? Center(child: Text("No games in wishlist"))
                : ListView.builder(
                    itemCount: wishlistGames.length,
                    itemBuilder: (context, index) {
                      final game = wishlistGames[index];
                      return Card(
                        margin: EdgeInsets.all(8.0),
                        elevation: 3,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        child: InkWell(
                          onTap: () {
                            final gameData = Game(
                              id: game['id'].toString(),
                              title: game['title'],
                              price: game['price'],
                              originalPrice: game['originalPrice'],
                              discount: game['discount'],
                              thumb: game['thumb'],
                              store: game['store'] ?? 'Unknown',
                            );
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    DetailPage(game: gameData),
                              ),
                            );
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(8.0),
                                  child: Image.network(
                                    game['thumb'],
                                    width: 100,
                                    height: 80,
                                    fit: BoxFit.fill,
                                    errorBuilder:
                                        (context, error, stackTrace) => Icon(
                                            Icons.image_not_supported,
                                            size: 80),
                                  ),
                                ),
                                SizedBox(width: 12.0),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        game['title'] ?? 'Unknown Title',
                                        style: TextStyle(
                                          fontSize: 16.0,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      SizedBox(height: 4.0),
                                      Text(
                                        game['price'] != null
                                            ? "${currencyProvider.currentCurrency} ${(game['price'] * rate).toStringAsFixed(2)}"
                                            : "Price not available",
                                        style: TextStyle(
                                          fontSize: 14.0,
                                          color: Colors.green,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      SizedBox(height: 4.0),
                                      if (game['originalPrice'] != null &&
                                          game['originalPrice'] > game['price'])
                                        Text(
                                          "Original Price: ${currencyProvider.currentCurrency} ${(game['originalPrice'] * rate).toStringAsFixed(2)}",
                                          style: TextStyle(
                                            fontSize: 12.0,
                                            color: Colors.grey,
                                            decoration:
                                                TextDecoration.lineThrough,
                                          ),
                                        ),
                                      if (game['discount'] != null)
                                        Text(
                                          "Discount: ${((game['originalPrice'] - game['price']) / game['originalPrice'] * 100).toStringAsFixed(1)}%",
                                          style: TextStyle(
                                            fontSize: 12.0,
                                            color: Colors.redAccent,
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                                IconButton(
                                  icon: Icon(Icons.alarm),
                                  onPressed: () {
                                    _showReminderDialog(context, game['title']);
                                  },
                                ),
                                IconButton(
                                  icon: Icon(Icons.delete, color: Colors.red),
                                  onPressed: () =>
                                      _removeFromWishlist(game['id']),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
