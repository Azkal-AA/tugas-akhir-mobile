class Game {
  final String id;
  final String title;
  final double price;
  final String store;
  final double originalPrice;
  final double discount;
  final String thumb;

  Game({
    required this.id,
    required this.title,
    required this.price,
    required this.store,
    required this.originalPrice,
    required this.discount,
    required this.thumb,
  });

  factory Game.fromJson(Map<String, dynamic> json) {
    print("GameID: ${json['gameID']}");
    print("Title: ${json['title']}");
    print("Sale Price: ${json['salePrice']}");
    print("Normal Price: ${json['normalPrice']}");
    print("Savings: ${json['savings']}");
    print("Thumbnail: ${json['thumb']}");

    return Game(
      id: json['gameID'] ?? 'N/A',
      title: json['title'] ?? 'Unknown Title',
      price: double.tryParse(json['salePrice']?.toString() ?? '0') ?? 0,
      store: json['storeID'] ?? 'Unknown Store',
      originalPrice:
          double.tryParse(json['normalPrice']?.toString() ?? '0') ?? 0,
      discount: double.tryParse(json['savings']?.toString() ?? '0') ?? 0,
      thumb: json['thumb'] ?? '', // Mengambil URL gambar langsung dari JSON
    );
  }
}
