// Order Book Entry Model
class OrderBookEntry {
  final double price;
  final int volume;
  double total;

  OrderBookEntry({
    required this.price,
    required this.volume,
    required this.total,
  });
}
