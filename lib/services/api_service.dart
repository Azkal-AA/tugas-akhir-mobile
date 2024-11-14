import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/game.dart';

class ApiService {
  static const String baseUrl = "https://www.cheapshark.com/api/1.0";

  Future<List<Game>> fetchDeals() async {
    final response = await http.get(Uri.parse("$baseUrl/deals"));

    if (response.statusCode == 200) {
      List data = jsonDecode(response.body);
      return data.map((json) => Game.fromJson(json)).toList();
    } else {
      throw Exception("Failed to load deals");
    }
  }
}
