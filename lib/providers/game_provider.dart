import 'package:flutter/material.dart';
import '../models/game.dart';
import '../services/api_service.dart';

class GameProvider with ChangeNotifier {
  List<Game> _games = [];
  bool _isLoading = false;

  List<Game> get games => _games;
  bool get isLoading => _isLoading;

  // Fungsi untuk memanggil data dari API
  void fetchDeals() async {
    _isLoading = true;
    notifyListeners();

    try {
      _games = await ApiService().fetchDeals();
    } catch (e) {
      print("Error loading deals: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
