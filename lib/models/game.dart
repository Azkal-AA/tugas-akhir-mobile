class Game {
  final String id;
  final String title;
  final double price;
  final String store;
  final double originalPrice;
  final double discount;
  final String thumb;
  double? detailedPrice;

  Game({
    required this.id,
    required this.title,
    required this.price,
    required this.store,
    required this.originalPrice,
    required this.discount,
    required this.thumb,
    // this.detailedPrice, // Opsional
  });

  factory Game.fromJson(Map<String, dynamic> json) {
    return Game(
      id: json['gameID'] ?? 'N/A',
      title: json['title'] ?? 'Unknown Title',
      price: double.tryParse(json['salePrice']?.toString() ?? '0') ?? 0,
      store: json['storeID'] ?? 'Unknown Store',
      originalPrice:
          double.tryParse(json['normalPrice']?.toString() ?? '0') ?? 0,
      discount: double.tryParse(json['savings']?.toString() ?? '0') ?? 0,
      thumb: json['thumb'] ?? '',
    );
  }

  // Factory method untuk parsing API search
  factory Game.fromJsonSearch(Map<String, dynamic> json) {
    return Game(
      id: json['gameID'] ?? 'N/A',
      title: json['external'] ?? 'Unknown Title',
      price: 0, // Harga tidak ada di hasil pencarian API `games`
      store: 'Unknown Store',
      originalPrice: 0,
      discount: 0,
      thumb: json['thumb'] ?? '',
    );
  }

  get gameID => id;
}
