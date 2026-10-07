class Currency {
  /// The single currency Reselio trades in.
  static const String code = 'FCFA';
  static const String symbol = 'FCFA';

  /// Full amount with thousands separators: 5000 -> "5,000 FCFA"
  static String format(num amount) {
    return '${_group(amount.toDoubleAsFixed(0))} $code';
  }

  /// Full amount with two decimals, for places that need cents-like precision.
  static String formatWithDecimals(num amount, {int decimals = 2}) {
    return '${_group(amount.toDoubleAsFixed(decimals))} $code';
  }

  /// Compact form for dense dashboard tiles: 5000000 -> "5.0M FCFA"
  static String formatCompact(num amount) {
    final value = amount.toDouble();

    if (value.abs() >= 1000000000) {
      return '${(value / 1000000000).toStringAsFixed(1)}B $code';
    }
    if (value.abs() >= 1000000) {
      return '${(value / 1000000).toStringAsFixed(1)}M $code';
    }
    if (value.abs() >= 1000) {
      return '${(value / 1000).toStringAsFixed(1)}K $code';
    }
    return '${value.toStringAsFixed(0)} $code';
  }

  /// Parses user input that may contain separators or spaces: "5 000" -> 5000
  static double? parse(String? input) {
    if (input == null) return null;
    final cleaned = input.replaceAll(RegExp(r'[\s,_]'), '');
    if (cleaned.isEmpty) return null;
    return double.tryParse(cleaned);
  }

  static String _group(String value) {
    final negative = value.startsWith('-');
    final digits = negative ? value.substring(1) : value;

    final dotIndex = digits.indexOf('.');
    final whole = dotIndex == -1 ? digits : digits.substring(0, dotIndex);
    final decimals = dotIndex == -1 ? '' : digits.substring(dotIndex);

    final buffer = StringBuffer();
    for (var i = 0; i < whole.length; i++) {
      if (i > 0 && (whole.length - i) % 3 == 0) {
        buffer.write(',');
      }
      buffer.write(whole[i]);
    }

    return '${negative ? '-' : ''}$buffer$decimals';
  }
}