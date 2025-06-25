import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class CalculationRow extends StatelessWidget {
  final String label;
  final dynamic value;
  final bool isTotal;
  final NumberFormat? formatter;

  const CalculationRow({
    super.key,
    required this.label,
    required this.value,
    this.isTotal = false,
    this.formatter,
  });

  @override
  Widget build(BuildContext context) {
    final defaultFormatter = NumberFormat.currency(
      symbol: 'د.ع',
      decimalDigits: 2,
    );

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 16,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              color: isTotal ? Colors.blue : Colors.black,
            ),
          ),
          Text(
            _formatValue(value, formatter ?? defaultFormatter),
            style: TextStyle(
              fontSize: 16,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              color: isTotal ? Colors.blue : Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  String _formatValue(dynamic value, NumberFormat formatter) {
    if (value is double) {
      return formatter.format(value);
    } else if (value is int) {
      return formatter.format(value);
    }
    return value.toString();
  }
}
