import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_file_dialog/flutter_file_dialog.dart';
import 'dart:io';
import '../models/daily_record.dart';
import '../controllers/database_controller.dart';
import 'package:file_picker/file_picker.dart';

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
    String selectedField = 'grocery'; // Default selected field

    // Map of display names to actual field names
    final Map<String, String> fields = {
      'البقالة': 'grocery',
      'الصندوق': 'total',
      'أنس': 'anas',
      'ماجد': 'majed',
      'الحوري': 'alhouri',
    };

    // Function to show a date picker and return the selected date
    Future<DateTime?> _selectDate(
        BuildContext context, DateTime initialDate) async {
      return await showDatePicker(
        context: context,
        initialDate: initialDate,
        firstDate: DateTime(2000),
        lastDate: DateTime(2100),
      );
    }

    // Show a dialog to select start and end dates and the field
    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('حساب الإجمالي'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Dropdown to select the field
                  DropdownButton<String>(
                    value: fields.keys.firstWhere(
                        (key) => fields[key] == selectedField,
                        orElse: () => 'البقالة'),
                    onChanged: (String? newValue) {
                      setState(() {
                        selectedField = fields[newValue!]!;
                        totalValue = null; // Reset total when field changes
                      });
                    },
                    items: fields.keys
                        .map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                  ),

                  const SizedBox(height: 16),

                  // Start Date Picker
                  ListTile(
                    title: const Text('تاريخ البداية'),
                    trailing: const Icon(Icons.calendar_today),
                    onTap: () async {
                      final selectedDate = await _selectDate(
                          context, startDate ?? DateTime.now());
                      if (selectedDate != null) {
                        setState(() {
                          startDate = selectedDate;
                          totalValue = null; // Reset total when date changes
                        });
                      }
                    },
                  ),
                  if (startDate != null)
                    Text(
                      'التاريخ المحدد: ${DateFormat('yyyy-MM-dd').format(startDate!)}',
                      style: const TextStyle(color: Colors.grey),
                    ),

                  const SizedBox(height: 16),

                  // End Date Picker
                  ListTile(
                    title: const Text('تاريخ النهاية'),
                    trailing: const Icon(Icons.calendar_today),
                    onTap: () async {
                      final selectedDate =
                          await _selectDate(context, endDate ?? DateTime.now());
                      if (selectedDate != null) {
                        setState(() {
                          endDate = selectedDate;
                          totalValue = null; // Reset total when date changes
                        });

                        // Calculate total for the selected field after selecting end date
                        if (startDate != null) {
                          final total =
                              await dbController.getFieldTotalBetweenDates(
                            selectedField,
                            DateFormat('yyyy-MM-dd').format(startDate!),
                            DateFormat('yyyy-MM-dd').format(endDate ??
                                DateTime
                                    .now()), // Use current day if endDate is null
                          );
                          setState(() {
                            totalValue = total;
                          });
                        }
                      }
                    },
                  ),
                  if (endDate != null)
                    Text(
                      'التاريخ المحدد: ${DateFormat('yyyy-MM-dd').format(endDate!)}',
                      style: const TextStyle(color: Colors.grey),
                    ),

                  const SizedBox(height: 16),

                  // Display total value
                  if (totalValue != null)
                    Text(
                      'إجمالي ${fields.keys.firstWhere((key) => fields[key] == selectedField)}: ${totalValue!.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('إلغاء'),
                ),
                TextButton(
                  onPressed: () async {
                    if (startDate == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content:
                                Text('الرجاء تحديد تاريخ البداية على الأقل')),
                      );
                      return;
                    }

                    // Use current day as end date if not specified
                    final endDateToUse = endDate ?? DateTime.now();

                    if (startDate!.isAfter(endDateToUse)) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text(
                                'تاريخ البداية يجب أن يكون قبل تاريخ النهاية')),
                      );
                      return;
                    }

                    final total = await dbController.getFieldTotalBetweenDates(
                      selectedField,
                      DateFormat('yyyy-MM-dd').format(startDate!),
                      DateFormat('yyyy-MM-dd').format(endDateToUse),
                    );
                    setState(() {
                      totalValue = total;
                    });
                  },
                  child: const Text('حساب'),
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
      BuildContext context, DatabaseController dbController) async {
    // Show confirmation dialog
    final bool confirmSave = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('تأكيد الحفظ'),
          content: const Text(
              'هل أنت متأكد من رغبتك في حفظ نسخة احتياطية من السجلات؟'),
          actions: <Widget>[
            TextButton(
              child: const Text('إلغاء'),
              onPressed: () => Navigator.of(context).pop(false),
            ),
            TextButton(
              child: const Text('حفظ', style: TextStyle(color: Colors.blue)),
              onPressed: () => Navigator.of(context).pop(true),
            ),
          ],
        );
      },
    );

    // If user confirms, proceed with saving
    if (confirmSave == true) {
      try {
        // Request storage permission
        if (!await _requestStoragePermission()) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('تم رفض إذن التخزين')),
          );
          return;
        }

        // Get the current database path
        final sourcePath = await dbController.databasePath;
        final sourceFile = File(sourcePath);

        // Generate a unique file name
        final fileName =
            'ticket_backup_${DateFormat('yyyyMMdd_HHmmss').format(DateTime.now())}.db';

        // Save the file using flutter_file_dialog
        final params = SaveFileDialogParams(
          data: await sourceFile.readAsBytes(),
          fileName: fileName,
          mimeTypesFilter: ['application/octet-stream'],
        );

        final filePath = await FlutterFileDialog.saveFile(params: params);

        if (filePath != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('تم حفظ النسخة الاحتياطية في: $filePath')),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('تم إلغاء عملية الحفظ')),
          );
        }
      } catch (e, stackTrace) {
        // Debugging: Print full error details
        print("Error saving file: $e");
        print("Stack trace: $stackTrace");

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('فشل في حفظ الملف: ${e.toString()}')),
        );
      }
    }
  }

  // Add this new method
  Future<void> _restoreDatabaseFromDevice(
      BuildContext context, DatabaseController dbController) async {
    try {
      // Request storage permission
      if (!await _requestStoragePermission()) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تم رفض إذن التخزين')),
        );
        return;
      }

      // Open file picker to select the backup file
      final filePicker = FilePicker.platform;
      final result = await filePicker.pickFiles(
        type: FileType.any,
      );

      if (result != null && result.files.single.path != null) {
        final backupFilePath = result.files.single.path!;
        final backupFile = File(backupFilePath);

        // Get the current database path
        final currentDbPath = await dbController.databasePath;

        // Replace the current database with the backup
        await backupFile.copy(currentDbPath);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تم استعادة البيانات بنجاح')),
        );

        // Refresh the UI
        if (context.mounted) {
          Provider.of<DatabaseController>(context, listen: false)
              .getAllRecords();
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('لم يتم اختيار ملف')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('فشل في استعادة البيانات: ${e.toString()}')),
      );
    }
  }

  Future<bool> _requestStoragePermission() async {
    if (await Permission.storage.request().isGranted) {
      return true;
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
