import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../controllers/database_controller.dart';
import '../models/daily_record.dart';

class MonthlyReportsPage extends StatelessWidget {
  const MonthlyReportsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // تغيير الخلفية للأبيض
      appBar: AppBar(
        title: const Text('التقارير الشهرية',
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        centerTitle: true,
        backgroundColor: Colors.blue[800],
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.blue[50]!, Colors.white],
          ),
        ),
        child: FutureBuilder<List<DailyRecord>>(
          future: Provider.of<DatabaseController>(context).getAllRecords(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.report_problem,
                        size: 50, color: Colors.grey[400]),
                    const SizedBox(height: 16),
                    Text('لا يوجد بيانات متاحة',
                        style:
                            TextStyle(fontSize: 18, color: Colors.grey[600])),
                  ],
                ),
              );
            }

            final monthlyData = _groupByMonth(snapshot.data!);
            if (monthlyData.isEmpty) {
              return Center(
                  child: Text('لا توجد بيانات شهرية',
                      style: TextStyle(fontSize: 18, color: Colors.grey[600])));
            }

            return _buildReportsList(monthlyData);
          },
        ),
      ),
    );
  }

  Map<String, List<DailyRecord>> _groupByMonth(List<DailyRecord> records) {
    final Map<String, List<DailyRecord>> monthlyData = {};

    for (var record in records) {
      final date = DateTime.parse(record.date);
      final monthYear = DateFormat('yyyy-MM').format(date);

      monthlyData.putIfAbsent(monthYear, () => []);
      monthlyData[monthYear]!.add(record);
    }

    return monthlyData;
  }

  Widget _buildReportsList(Map<String, List<DailyRecord>> monthlyData) {
    final sortedMonths = monthlyData.keys.toList()
      ..sort((a, b) => b.compareTo(a));

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: ListView.builder(
        physics: const BouncingScrollPhysics(), // تأثير تمرير ناعم
        shrinkWrap: true,
        itemCount: sortedMonths.length,
        itemBuilder: (context, index) {
          final month = sortedMonths[index];
          final records = monthlyData[month]!;
          final total = _calculateMonthlyTotal(records);

          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.2),
                  spreadRadius: 2,
                  blurRadius: 5,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: ExpansionTile(
                initiallyExpanded: index == 0, // فتح أول شهر تلقائياً
                leading: Icon(Icons.calendar_month, color: Colors.blue[800]),
                title: Text(
                  _formatMonth(month),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                subtitle: Text(
                  '${records.length} يوم',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 14,
                  ),
                ),
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: _buildMonthlySummary(total),
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildMonthlySummary(Map<String, double> totals) {
    return Column(
      children: [
        _buildSummaryRow(
            'إجمالي التذاكر', totals['tickets']!, Colors.blue[800]!),
        _buildSummaryRow(
            'إجمالي البقالة', totals['grocery']!, Colors.green[800]!),
        _buildSummaryRow(
            'إجمالي المصروفات', totals['expenses']!, Colors.red[800]!),
        const Divider(height: 30),
        _buildSummaryRow('الصافي النهائي', totals['net']!, Colors.purple[800]!,
            isTotal: true),
      ],
    );
  }

  Widget _buildSummaryRow(String title, double amount, Color color,
      {bool isTotal = false}) {
    final formattedAmount = _formatYER(amount);

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
        color: isTotal ? Colors.grey[100] : null,
        borderRadius: BorderRadius.circular(8),
      ),
      child: ListTile(
        dense: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: 8),
        title: Text(title,
            style: TextStyle(
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              color: isTotal ? Colors.blue[800] : Colors.grey[700],
              fontSize: isTotal ? 16 : 14,
            )),
        trailing: Text(formattedAmount,
            style: TextStyle(
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              color: isTotal ? Colors.blue[800] : color,
              fontSize: isTotal ? 16 : 14,
            )),
      ),
    );
  }

  String _formatYER(double amount) {
    final formatter = NumberFormat.currency(
      symbol: 'ريال يمني',
      decimalDigits: 0,
      locale: 'ar_YE',
    );

    // تنسيق الأرقام بالملايين إذا لزم الأمر
    if (amount >= 1000000) {
      return '${formatter.format(amount ~/ 1000000)} مليون';
    } else if (amount >= 1000) {
      return '${formatter.format(amount ~/ 1000)} ألف';
    }
    return formatter.format(amount);
  }

  Map<String, double> _calculateMonthlyTotal(List<DailyRecord> records) {
    double tickets = 0;
    double grocery = 0;
    double expenses = 0;

    for (var record in records) {
      tickets += record.tickets * record.ticketPrice;
      grocery += record.grocery;
      expenses += record.expenseTotal;
    }

    return {
      'tickets': tickets,
      'grocery': grocery,
      'expenses': expenses,
      'net': tickets - expenses,
    };
  }

  String _formatMonth(String monthYear) {
    final parts = monthYear.split('-');
    final year = parts[0];
    final month = parts[1];

    final monthName =
        DateFormat('MMMM', 'ar').format(DateTime(0, int.parse(month)));
    return '$monthName $year';
  }
}
