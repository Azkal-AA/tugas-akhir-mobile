// import 'package:flutter/material.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:tugas_akhir/pages/loginPage.dart';

// class NotificationPage extends StatefulWidget {
//   @override
//   _NotificationPageState createState() => _NotificationPageState();
// }

// class _NotificationPageState extends State<NotificationPage> {
//   List<String> notifications = []; // Daftar notifikasi yang akan ditampilkan

//   @override
//   void initState() {
//     super.initState();
//     _validateSession(); // Validasi sesi pengguna
//     _loadNotifications(); // Memuat notifikasi yang sudah ada
//   }

//   // Fungsi untuk memvalidasi sesi pengguna
//   Future<void> _validateSession() async {
//     final prefs = await SharedPreferences.getInstance();
//     final token = prefs.getString('token');
//     if (token == null) {
//       // Jika token tidak ada, arahkan ke halaman login
//       WidgetsBinding.instance.addPostFrameCallback((_) {
//         Navigator.pushReplacement(
//           context,
//           MaterialPageRoute(builder: (context) => LoginPage()),
//         );
//       });
//     }
//   }

//   // Fungsi untuk memuat notifikasi dari SharedPreferences
//   Future<void> _loadNotifications() async {
//     final prefs = await SharedPreferences.getInstance();
//     final List<String>? storedNotifications =
//         prefs.getStringList('notifications');
//     if (storedNotifications != null) {
//       setState(() {
//         notifications = storedNotifications;
//       });
//     }
//   }

//   // Fungsi untuk menambahkan notifikasi ke SharedPreferences
//   Future<void> _addNotification(String notification) async {
//     final prefs = await SharedPreferences.getInstance();
//     final List<String> updatedNotifications = List.from(notifications)
//       ..add(notification);
//     await prefs.setStringList('notifications', updatedNotifications);
//     setState(() {
//       notifications = updatedNotifications;
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Notifications'),
//         centerTitle: true,
//       ),
//       body: notifications.isEmpty
//           ? Center(child: Text("No notifications available."))
//           : ListView.builder(
//               itemCount: notifications.length,
//               itemBuilder: (context, index) {
//                 return Card(
//                   margin: EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
//                   elevation: 3,
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(10.0),
//                   ),
//                   child: ListTile(
//                     leading: Icon(
//                       Icons.notifications_active,
//                       color: Colors.blue,
//                       size: 40.0,
//                     ),
//                     title: Text(
//                       'Notification ${index + 1}',
//                       style: TextStyle(
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                     subtitle: Text(notifications[index]),
//                     trailing: Icon(
//                       Icons.arrow_forward_ios,
//                       size: 16.0,
//                     ),
//                     onTap: () {
//                       // Tambahkan aksi yang sesuai
//                       ScaffoldMessenger.of(context).showSnackBar(
//                         SnackBar(
//                             content:
//                                 Text('Tapped on Notification ${index + 1}')),
//                       );
//                     },
//                   ),
//                 );
//               },
//             ),
//     );
//   }
// }
