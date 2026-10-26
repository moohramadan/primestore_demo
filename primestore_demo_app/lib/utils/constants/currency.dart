class TCurrency {
  TCurrency._();

  static const symbol = '\$';

  static String format(double amount) => '$symbol${amount.toStringAsFixed(2)}';
}
