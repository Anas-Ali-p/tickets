import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_file_dialog/flutter_file_dialog.dart';
import 'package:tickets/main.dart';
import 'dart:io';
import '../models/daily_record.dart';
import '../controllers/database_controller.dart';
import 'package:file_picker/file_picker.dart';
import 'package:device_info_plus/device_info_plus.dart';

class RecordsPage extends StatelessWidget {
  const RecordsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final dbController = Provider.of<DatabaseController>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('سجلات اليوميات',
            style: TextStyle(
                color: Colors.blue[900],
                fontSize: 20,
                fontWeight: FontWeight.bold)),
        backgroundColor: Colors.blue[50],
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.copy, color: Colors.blue[900]),
            onPressed: () => _copyAllRecords(context, dbController),
          ),
          IconButton(
            icon: Icon(Icons.calculate, color: Colors.blue[900]),
            onPressed: () => _calculateGroceryTotal(context, dbController),
          ),
          IconButton(
            icon: Icon(Icons.save, color: Colors.blue[900]),
            onPressed: () => _saveDatabaseToDevice(context, dbController),
          ),
          IconButton(
            icon: Icon(Icons.restore, color: Colors.blue[900]),
            onPressed: () => _restoreDatabaseFromDevice(context, dbController),
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          color: Colors.blue[50],
        ),
        child: FutureBuilder<List<DailyRecord>>(
          future: dbController.getAllRecords(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                  child: CircularProgressIndicator(color: Colors.white));
            }
            if (snapshot.hasError) {
              return Center(
                  child: Text('حدث خطأ: ${snapshot.error}',
                      style: const TextStyle(color: Colors.white)));
            }
            final records = snapshot.data!;
            return ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: records.length,
              itemBuilder: (context, index) => Card(
                margin: const EdgeInsets.symmetric(vertical: 6),
                color: Colors.grey[900],
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                child: _buildRecordItem(records[index], dbController, context),
              ),
            );
          },
        ),
      ),
    );
  }

  // Method to calculate and display the total for a selected field between two dates
  Future<void> _calculateGroceryTotal(
      BuildContext context, DatabaseController dbController) async {
    DateTime? startDate;
    DateTime? endDate;
    double? totalValue;
    String selectedField = 'grocery';
    List<Map<String, dynamic>> recordsDetails = [];

    final Map<String, String> fields = {
      'البقالة': 'grocery',
      'الصندوق': 'total',
      'أنس': 'anas',
      'ماجد': 'majed',
      'الحوري': 'alhouri',
      'هيثم': 'hetham',
      'وايت': 'white',
      'التذاكر': 'tickets',
    };

    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('حساب الإجمالي'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    DropdownButton<String>(
                      value: fields.keys.firstWhere(
                          (k) => fields[k] == selectedField,
                          orElse: () => 'البقالة'),
                      items: fields.keys.map((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        setState(() {
                          selectedField = fields[newValue]!;
                          totalValue = null;
                          recordsDetails = [];
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    ListTile(
                      title: const Text('تاريخ البداية'),
                      trailing: const Icon(Icons.calendar_today),
                      onTap: () async {
                        final selected = await showDatePicker(
                          context: context,
                          initialDate: startDate ?? DateTime.now(),
                          firstDate: DateTime(2000),
                          lastDate: DateTime.now(),
                        );
                        if (selected != null) {
                          setState(() {
                            startDate = selected;
                            totalValue = null;
                            recordsDetails = [];
                          });
                        }
                      },
                    ),
                    ListTile(
                      title: const Text('تاريخ النهاية'),
                      trailing: const Icon(Icons.calendar_today),
                      onTap: () async {
                        final selected = await showDatePicker(
                          context: context,
                          initialDate: endDate ?? DateTime.now(),
                          firstDate: startDate ?? DateTime(2000),
                          lastDate: DateTime.now(),
                        );
                        if (selected != null) {
                          setState(() {
                            endDate = selected;
                            totalValue = null;
                            recordsDetails = [];
                          });
                        }
                      },
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () async {
                        if (startDate == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text('يجب تحديد تاريخ البداية')),
                          );
                          return;
                        }

                        final endDateToUse = endDate ?? DateTime.now();
                        final records = await dbController.getAllRecords();

                        final filtered = records.where((r) {
                          final date = DateTime.parse(r.date);
                          return date.isAfter(
                                  startDate!.subtract(Duration(days: 1))) &&
                              date.isBefore(
                                  endDateToUse.add(Duration(days: 1)));
                        }).toList();

                        double total = 0;
                        recordsDetails = filtered
                            .where((r) {
                              final value = r.toMap()[selectedField] ?? 0.0;
                              return value > 0;
                            })
                            .map((r) => {
                                  'date': r.date,
                                  'value': r.toMap()[selectedField] ?? 0.0
                                })
                            .toList();

                        total = recordsDetails.fold(
                            0, (sum, item) => sum + item['value']);

                        setState(() {
                          totalValue = total;
                        });
                      },
                      child: const Text('حساب الإجمالي'),
                    ),
                    if (totalValue != null) ...[
                      const SizedBox(height: 16),
                      Text(
                        'الإجمالي: ${totalValue!.toStringAsFixed(2)}',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.blueAccent,
                        ),
                      ),
                    ],
                    if (recordsDetails.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      const Text(
                        'التفاصيل:',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      SizedBox(
                        height: 200,
                        child: ListView.builder(
                          shrinkWrap: true,
                          itemCount: recordsDetails.length,
                          itemBuilder: (context, index) {
                            return Container(
                              margin: EdgeInsets.symmetric(vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.blueGrey[800],
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: ListTile(
                                title: Text(
                                  recordsDetails[index]['date'],
                                  style: TextStyle(color: Colors.white),
                                ),
                                trailing: Text(
                                  '${recordsDetails[index]['value'].toStringAsFixed(2)}',
                                  style: TextStyle(
                                    color: Colors.amber,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('إغلاق'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // Add this new method
  Future<void> _saveDatabaseToDevice(
    BuildContext context,
    DatabaseController dbController,
  ) async {
    try {
      // طلب الإذن أولاً
      if (!await _requestStoragePermission(context)) return;

      final sourcePath = await dbController.databasePath;
      final sourceFile = File(sourcePath);

      // اختيار مكان الحفظ
      String? selectedDir = await FilePicker.platform.getDirectoryPath();
      if (selectedDir == null) return;

      final backupFile = File(
          '$selectedDir/ticket_backup_${DateTime.now().millisecondsSinceEpoch}.db');
      await sourceFile.copy(backupFile.path);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('تم الحفظ في: ${backupFile.path}')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('خطأ في الحفظ: ${e}')),
        );
      }
    }
  }

  // Add this new method
  Future<void> _restoreDatabaseFromDevice(
    BuildContext context,
    DatabaseController dbController,
  ) async {
    try {
      // طلب الإذن أولاً
      if (!await _requestStoragePermission(context)) return;

      final result = await FilePicker.platform.pickFiles();
      if (result == null || result.files.isEmpty) return;

      // إغلاق الاتصال الحالي
      await dbController.close();

      // استبدال الملف
      final currentDbPath = await dbController.databasePath;
      await File(result.files.single.path!).copy(currentDbPath);

      // إعادة فتح الاتصال
      await dbController.database;

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تم الاستعادة بنجاح')),
        );

        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const MyApp()),
          (route) => false,
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('فشل الاستعادة: ${e}')),
        );
      }
    }
  }

  Future<bool> _requestStoragePermission(BuildContext context) async {
    try {
      // للإصدارات القديمة (أقل من أندرويد 10)
      if (Platform.isAndroid &&
          await DeviceInfoPlugin()
              .androidInfo
              .then((info) => info.version.sdkInt < 29)) {
        return true; // تخطي الطلب في الإصدارات القديمة
      }

      // للإصدارات الحديثة
      final status = await Permission.storage.status;
      if (status.isGranted) return true;

      final result = await Permission.storage.request();
      if (result.isGranted) return true;

      // إذا رفض المستخدم
      if (context.mounted) {
        await showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('مطلوب إذن التخزين'),
            content: const Text('الرجاء منح الإذن يدوياً من إعدادات التطبيق'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('إلغاء'),
              ),
              TextButton(
                onPressed: () async {
                  Navigator.pop(ctx);
                  await openAppSettings();
                },
                child: const Text('فتح الإعدادات'),
              ),
            ],
          ),
        );
      }
      return false;
    } catch (e) {
      debugPrint('Error requesting permission: $e');
      return true; // افترض الإذن في حالة الخطأ للإصدارات القديمة
    }
  }

  Future<bool> _requestStoragePermission2(BuildContext context) async {
    if (await Permission.manageExternalStorage.isGranted) {
      return true;
    }

    final status = await Permission.manageExternalStorage.request();
    if (status.isGranted) return true;

    if (context.mounted) {
      await showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('مطلوب إذن التخزين'),
          content: const Text('الرجاء منح الإذن من إعدادات التطبيق'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('إلغاء'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(ctx);
                // بديل open_app_settings
                Permission.manageExternalStorage.request();
              },
              child: const Text('فتح الإعدادات'),
            ),
          ],
        ),
      );
    }
    return false;
  }

  Widget _buildRecordItem(DailyRecord record, DatabaseController dbController,
      BuildContext context) {
    final dateFormat = DateFormat('yyyy-MM-dd');
    // final = NumberFormat.currency(symbol: 'د.ع');

    return Card(
      color: Colors.grey[900],
      margin: const EdgeInsets.all(8),
      child: ExpansionTile(
        leading: const Icon(
          Icons.history,
          color: Colors.white,
        ),
        title: Text(dateFormat.format(DateTime.parse(record.date)),
            style: const TextStyle(color: Colors.white)),
        subtitle: Text('الإجمالي: ${(record.total.toStringAsFixed(2))}',
            style: const TextStyle(color: Colors.white)),
        children: [
          _buildDetailRow('التذاكر المباعة', record.tickets, showAlways: true),
          ..._buildRecordDetails(record),
          _buildCopyButton(record, context),
          _buildDeleteButton(record, dbController, context),
        ],
      ),
    );
  }

  List<Widget> _buildRecordDetails(DailyRecord record) {
    print(record.grocery);
    return [
      _buildDetailRow('التذاكر', record.tickets, showAlways: false),
      _buildDetailRow('الصندوق', record.cashBox),
      _buildDetailRow('الصرفة', record.expenseTotal),
      _buildDetailRow('غداء', record.lunch),
      _buildDetailRow('هيثم', record.hetham),
      _buildDetailRow('الحوري', record.alhouri),
      _buildDetailRow('ماجد', record.majed),
      _buildDetailRow('وايت', record.white),
      _buildDetailRow('أنس', record.anas),
      ..._buildManualExpenses(record, NumberFormat()),
      _buildDetailRow('البقالة', record.grocery, showAlways: true),
      _buildDetailRow('الصرف', record.sarf),
      _buildDetailRow('الإجمالي', record.total, isTotal: true),
      _buildDetailRow('التذاكر المتبقية', record.remainingTickets,
          isTotal: true),
    ];
  }

  Widget _buildDetailRow(
    String label,
    dynamic value, {
    bool showAlways = false,
    NumberFormat? formatter,
    bool isTotal = false,
  }) {
    if (!showAlways && (value == 0 || value == 0.0)) {
      return const SizedBox.shrink();
    }

    String formattedValue = format(value);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: TextStyle(
                fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
                color: isTotal ? Colors.white : Colors.grey[200],
              )),
          Text(formattedValue,
              style: TextStyle(
                fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
                color: isTotal ? Colors.white : Colors.grey[200],
              )),
        ],
      ),
    );
  }

  String format(dynamic value) {
    String formattedValue;
    if (value is double && value.truncateToDouble() == value) {
      // If value is a whole number (like 2.0), remove decimal places
      formattedValue = value.toInt().toString();
    } else {
      // Otherwise keep 2 decimal places
      formattedValue = value.toStringAsFixed(2);
    }
    return formattedValue;
  }

  List<Widget> _buildManualExpenses(
      DailyRecord record, NumberFormat formatter) {
    return record.manualExpenses.map((expense) {
      if (expense.value <= 0) return const SizedBox.shrink();
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(expense.name),
            Text(formatter.format(expense.value)),
          ],
        ),
      );
    }).toList();
  }

  Widget _buildCopyButton(DailyRecord record, BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: IconButton(
        icon: const Icon(Icons.copy),
        onPressed: () => _copyRecordToClipboard(record, context),
        tooltip: 'نسخ السجل',
      ),
    );
  }

  Widget _buildDeleteButton(
    DailyRecord record,
    DatabaseController dbController,
    BuildContext context,
  ) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: ElevatedButton.icon(
        icon: const Icon(Icons.delete, color: Colors.white),
        label: const Text('حذف السجل', style: TextStyle(color: Colors.white)),
        style: ElevatedButton.styleFrom(backgroundColor: Colors.blueGrey),
        onPressed: () => _confirmDelete(context, record, dbController),
      ),
    );
  }

  void _copyRecordToClipboard(DailyRecord record, BuildContext context) async {
    final buffer = StringBuffer();
    buffer.writeln(record.date);
    buffer.writeln('التذاكر: ${format(record.tickets)}');
    buffer.writeln('الصندوق: ${format(record.cashBox)}');
    buffer.writeln('الصرفة: ${format(record.expenseTotal)}');
    if (record.lunch > 0) buffer.writeln('غداء: ${format(record.lunch)}');
    if (record.hetham > 0) buffer.writeln('هيثم: ${format(record.hetham)}');
    if (record.alhouri > 0) buffer.writeln('الحوري: ${format(record.alhouri)}');
    if (record.majed > 0) buffer.writeln('ماجد: ${format(record.majed)}');
    if (record.white > 0) buffer.writeln('وايت: ${format(record.white)}');
    if (record.anas > 0) buffer.writeln('أنس: ${format(record.anas)}');
    record.manualExpenses.where((e) => e.value > 0).forEach((e) {
      buffer.writeln('${e.name}: ${format(e.value)}');
    });
    buffer.writeln('البقالة: ${format(record.grocery)}');

    await Clipboard.setData(ClipboardData(text: buffer.toString())).then(
      (_) => {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تم النسخ إلى الحافظة')),
        ),
      },
    );
  }

  Future<void> _confirmDelete(
    BuildContext context,
    DailyRecord record,
    DatabaseController dbController,
  ) async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('تأكيد الحذف'),
          content: const Text('هل أنت متأكد من رغبتك في حذف هذا السجل؟'),
          actions: <Widget>[
            TextButton(
              child: const Text('إلغاء'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: const Text('حذف', style: TextStyle(color: Colors.red)),
              onPressed: () async {
                await dbController.deleteRecord(record.date);
                Navigator.of(context).pop();
                // Refresh the records after deletion
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('تم حذف السجل بنجاح')),
                );
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _copyAllRecords(
      BuildContext context, DatabaseController dbController) async {
    final records = await dbController.getAllRecords();
    final buffer = StringBuffer();
    for (final record in records) {
      buffer.writeln('-' * 30);
      _copyRecordToClipboard(record, context);
      await Future.delayed(const Duration(milliseconds: 100));
    }
    await Clipboard.setData(ClipboardData(text: buffer.toString()));
  }
}
