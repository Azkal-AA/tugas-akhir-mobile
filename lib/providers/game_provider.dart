import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/game.dart';

class GameProvider with ChangeNotifier {
  List<Game> _games = [];
  bool _isLoading = false;

  List<Game> get games => _games;
  bool get isLoading => _isLoading;

  void setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  Future<void> fetchDeals() async {
    setLoading(true);
    notifyListeners();

    const url = 'https://www.cheapshark.com/api/1.0/deals?';
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        _games = data.map((json) => Game.fromJson(json)).toList();
      }
    } catch (error) {
      print("Error fetching deals: $error");
    } finally {
      setLoading(false);
      notifyListeners();
    }
  }

  Future<List<Game>> fetchDealsByStore(String storeID) async {
    final url =
        'https://www.cheapshark.com/api/1.0/deals?storeID=$storeID&upperPrice=15';
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body) as List;
        return data.map((item) => Game.fromJson(item)).toList();
      } else {
        throw Exception("Failed to fetch deals for store ID $storeID");
      }
    } catch (error) {
      print("Error fetching deals for store ID $storeID: $error");
      return [];
    }
  }

  Future<List<Game>> searchGames(String query) async {
    setLoading(true);

    final url = 'https://www.cheapshark.com/api/1.0/games?title=$query';
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => Game.fromJsonSearch(json)).toList();
      } else {
        return [];
      }
    } catch (error) {
      print("Error searching games: $error");
      return [];
    } finally {
      setLoading(false);
    }
  }

  Future<Map<String, dynamic>> getGameDetailsById(String gameId) async {
    final url =
        Uri.parse('https://www.cheapshark.com/api/1.0/games?id=$gameId');
    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to load game details');
      }
    } catch (e) {
      print("Error fetching game details by ID: $e");
      return {};
    }
  }

  Future<Map<String, dynamic>?> fetchGameDetails(String gameName) async {
    try {
      final searchResults = await searchGames(gameName);
      print(searchResults);

      if (searchResults.isNotEmpty) {
        final gameId = searchResults[0].gameID;
        final gameDetails = await getGameDetailsById(gameId);
        return gameDetails;
      } else {
        print("No games found for $gameName");
        return null;
      }
    } catch (e) {
      print("Error fetching game details: $e");
      return null;
    }
  }

  Future<List<Game>> searchGamesWithDetails(String query) async {
    setLoading(true);
    final searchResults = await searchGames(query);

    await Future.wait(searchResults.map((game) async {
      try {
        final gameDetails = await getGameDetailsById(game.gameID);
        game.detailedPrice =
            double.tryParse(gameDetails['cheapestPriceEver']['price'] ?? '0');
      } catch (e) {
        print("Error fetching details for gameID ${game.gameID}: $e");
      }
    }));

    setLoading(false);
    return searchResults;
  }
}
