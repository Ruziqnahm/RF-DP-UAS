import 'package:intl/intl.dart';

class CurrencyFormatter {
  static final NumberFormat _currencyFormat = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  );

  /// Format number to Indonesian Rupiah currency
  /// Example: 50000 -> "Rp 50.000"
  static String format(dynamic amount) {
    if (amount == null) return 'Rp 0';
    
    if (amount is String) {
      amount = double.tryParse(amount) ?? 0;
    }
    
    return _currencyFormat.format(amount);
  }

  /// Format without symbol
  /// Example: 50000 -> "50.000"
  static String formatWithoutSymbol(dynamic amount) {
    if (amount == null) return '0';
    
    if (amount is String) {
      amount = double.tryParse(amount) ?? 0;
    }
    
    final formatted = _currencyFormat.format(amount);
    return formatted.replaceAll('Rp ', '');
  }

  /// Parse currency string to double
  /// Example: "Rp 50.000" -> 50000.0
  static double parse(String currencyString) {
    final cleaned = currencyString
        .replaceAll('Rp', '')
        .replaceAll('.', '')
        .replaceAll(',', '.')
        .trim();
    return double.tryParse(cleaned) ?? 0;
  }
}
