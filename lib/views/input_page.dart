import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/input_controller.dart';
import '../widgets/expense_field.dart';
import '../controllers/database_controller.dart';

class InputPage extends StatefulWidget {
  const InputPage({super.key});

  @override
  State<InputPage> createState() => _InputPageState();
}

class _InputPageState extends State<InputPage> {
  final _formKey = GlobalKey<FormState>();
  late final List<FocusNode> focusNodes;

  @override
  void initState() {
    super.initState();
    focusNodes = List.generate(13, (index) => FocusNode());
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final controller = Provider.of<InputController>(context, listen: false);
      controller.loadLastRecord();
    });
  }

  @override
  Widget build(BuildContext context) {
    final controller = Provider.of<InputController>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('يومية جديدة',
            style: TextStyle(
                color: Colors.blue[900],
                fontSize: 20,
                fontWeight: FontWeight.bold)),
        backgroundColor: Colors.blue[50],
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.history, color: Colors.blue[900]),
            onPressed: () => Navigator.pushNamed(context, '/records'),
          ),
          IconButton(
            icon: const Icon(Icons.bar_chart),
            onPressed: () => Navigator.pushNamed(context, '/reports'),
          ),
        ],
      ),
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: Container(
          decoration: BoxDecoration(color: Colors.blue[50]),
          child: SafeArea(
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Form(
                key: _formKey,
                child: ListView(
                  children: [
                    Card(
                      margin: const EdgeInsets.symmetric(vertical: 8.0),
                      color: Colors.blueGrey,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: _buildBookInfoSection(controller),
                      ),
                    ),
                    Card(
                      margin: const EdgeInsets.symmetric(vertical: 8.0),
                      color: Colors.blueGrey,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: _buildExpensesSection(controller),
                      ),
                    ),
                    Card(
                      margin: const EdgeInsets.symmetric(vertical: 8.0),
                      color: Colors.blueGrey,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: _buildResultsSection(controller),
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildSaveButton(context),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBookInfoSection(InputController controller) {
    if (controller.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    return ExpansionTile(
      leading: const Icon(Icons.book, color: Colors.white),
      title: const Text('معلومات الدفاتر',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
      childrenPadding: const EdgeInsets.only(top: 5, bottom: 15),
      children: [
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          childAspectRatio: 3,
          mainAxisSpacing: 20,
          crossAxisSpacing: 10,
          children: [
            NumberField(
                label: 'سعر التذكرة',
                value: controller.ticketPrice,
                onChanged: (v) => controller.ticketPrice = v,
                focusNodes: focusNodes,
                focusIndex: 0),
            NumberField(
                label: 'قبل البيع',
                value: controller.preSale.toDouble(),
                onChanged: (v) => controller.preSale = v.toInt(),
                focusNodes: focusNodes,
                focusIndex: 1),
            NumberField(
                label: 'رقم الدفتر',
                value: controller.bookNumber.toDouble(),
                onChanged: (v) => controller.bookNumber = v.toInt(),
                focusNodes: focusNodes,
                focusIndex: 2),
            NumberField(
                label: 'دفاتر مكتملة',
                value: controller.completedBooks.toDouble(),
                onChanged: (v) => controller.completedBooks = v.toInt(),
                focusNodes: focusNodes,
                focusIndex: 3),
            NumberField(
                label: 'تذاكر/الورقة',
                value: controller.ticketsPerSheet.toDouble(),
                onChanged: (v) => controller.ticketsPerSheet = v.toInt(),
                focusNodes: focusNodes,
                focusIndex: 4),
            NumberField(
              label: 'البقالة',
              value: controller.grocery,
              onChanged: (v) => controller.grocery = v,
              focusNodes: focusNodes,
              focusIndex: 5,
            ),
            NumberField(
              label: 'الصرف',
              value: controller.sarf,
              onChanged: (v) => controller.sarf = v,
              focusNodes: focusNodes,
              focusIndex: 6,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildExpensesSection(InputController controller) {
    return ExpansionTile(
      leading: const Icon(Icons.money_off, color: Colors.white),
      title: const Text('المصروفات',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
      childrenPadding: const EdgeInsets.only(top: 5, bottom: 15),
      children: [
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          childAspectRatio: 3,
          mainAxisSpacing: 20,
          crossAxisSpacing: 10,
          children: [
            _buildExpenseField(
                'غداء', controller.lunch, (v) => controller.lunch = v, 1),
            _buildExpenseField(
                'هيثم', controller.hetham, (v) => controller.hetham = v, 2),
            _buildExpenseField(
                'الحوري', controller.alhouri, (v) => controller.alhouri = v, 3),
            _buildExpenseField(
                'ماجد', controller.majed, (v) => controller.majed = v, 4),
            _buildExpenseField(
                'وايت', controller.white, (v) => controller.white = v, 5),
            _buildExpenseField(
                'أنس', controller.anas, (v) => controller.anas = v, 6),
          ],
        ),
        ...controller.manualExpenses
            .map(
              (expense) => ManualExpenseField(
                name: expense.name,
                value: expense.value,
                onChanged: (n, v) => controller.updateManualExpense(
                    controller.manualExpenses.indexOf(expense), n, v),
                onRemove: () => controller.removeManualExpense(
                    controller.manualExpenses.indexOf(expense)),
              ),
            )
            .toList(),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
          child: ElevatedButton.icon(
            icon: const Icon(Icons.add),
            label: const Text('إضافة مصروف جديد'),
            onPressed: () => controller.addManualExpense('', 0.0),
          ),
        ),
      ],
    );
  }

  Widget _buildResultsSection(InputController controller) {
    return ExpansionTile(
      iconColor: Colors.white,
      leading: const Icon(Icons.calculate, color: Colors.white),
      title: const Text('النتائج',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            children: [
              _buildResultRow('التذاكر المتبقية', controller.remainingTickets),
              _buildResultRow('التذاكر المباعة', controller.tickets),
              _buildResultRow('إجمالي الصرفة', controller.expenseTotal),
              _buildResultRow('صندوق التذاكر', controller.cashBox),
              _buildResultRow('صندوق البقالة', controller.grocery),
              _buildResultRow('الإجمالي النهائي', controller.total,
                  isTotal: true),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildExpenseField(
      String label, double value, Function(double) onChanged, int exIndex) {
    return NumberField(
      label: label,
      value: value,
      onChanged: onChanged,
      focusNodes: focusNodes,
      focusIndex: 6 + exIndex,
    );
  }

  Widget _buildResultRow(String label, dynamic value, {bool isTotal = false}) {
    return ListTile(
      title: Text(label),
      trailing: Text(
        value.toStringAsFixed(2),
        style: TextStyle(
          fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
          color: isTotal ? Colors.white : Colors.grey[200],
          fontSize: 16,
        ),
      ),
    );
  }

  Widget _buildSaveButton(BuildContext context) {
    final controller = Provider.of<InputController>(context, listen: false);
    final dbController =
        Provider.of<DatabaseController>(context, listen: false);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: ElevatedButton.icon(
        icon: const Icon(Icons.save, color: Colors.white),
        label: const Text('حفظ اليومية',
            style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white)),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF3949AB),
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          elevation: 4,
        ),
        onPressed: () async {
          if (_formKey.currentState!.validate()) {
            final recordExists = await dbController
                .recordExists(DateTime.now().toIso8601String().split('T')[0]);

            if (recordExists) {
              final shouldReplace = await showDialog<bool>(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('تأكيد'),
                      content:
                          const Text('يوجد سجل لهذا اليوم. هل تريد استبداله؟'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context, false),
                          child: const Text('إلغاء'),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pop(context, true),
                          child: const Text('استبدال'),
                        ),
                      ],
                    ),
                  ) ??
                  false;

              if (!shouldReplace) return;
            }

            final success = await controller.saveRecord();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                  content:
                      Text(success ? 'تم الحفظ بنجاح' : 'حدث خطأ أثناء الحفظ')),
            );
          }
        },
      ),
    );
  }
}

class NumberField extends StatefulWidget {
  final String label;
  final double value;
  final Function(double) onChanged;
  final List<FocusNode> focusNodes;
  final int focusIndex;

  const NumberField({
    Key? key,
    required this.label,
    required this.value,
    required this.onChanged,
    required this.focusNodes,
    required this.focusIndex,
  }) : super(key: key);

  @override
  _NumberFieldState createState() => _NumberFieldState();
}

class _NumberFieldState extends State<NumberField> {
  late TextEditingController _controller;
  double? _tempValue;
  late final List<FocusNode> focusNodes = widget.focusNodes;
  late final int focusIndex = widget.focusIndex;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.value.toStringAsFixed(2));
    focusNodes[focusIndex].addListener(() {
      if (focusNodes[focusIndex].hasFocus && mounted) {
        setState(() {
          _tempValue = widget.value;
          _controller.clear();
        });
      } else {
        if (mounted) {
          setState(() {
            if (_controller.text.isNotEmpty) {
              _tempValue = double.tryParse(_controller.text);
              widget.onChanged(_tempValue ?? widget.value);
            } else {
              _controller.text = _tempValue?.toStringAsFixed(2) ??
                  widget.value.toStringAsFixed(2);
            }
          });
        }
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      child: TextFormField(
        focusNode: focusNodes[focusIndex],
        controller: _controller,
        onChanged: (value) {
          final numValue = double.tryParse(value) ?? widget.value;
          widget.onChanged(numValue);
        },
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          hintStyle: TextStyle(
            fontSize: _controller.text.isEmpty ? 16 : 12,
            fontWeight:
                _controller.text.isEmpty ? FontWeight.normal : FontWeight.bold,
            color: Colors.white54,
          ),
          labelText: widget.label,
          hintText:
              _tempValue?.toStringAsFixed(2) ?? widget.value.toStringAsFixed(2),
          filled: true,
          fillColor: Colors.blueGrey[900],
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide.none,
          ),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 24, vertical: 15),
          labelStyle: TextStyle(
            fontSize: _controller.text.isEmpty ? 16 : 12,
            fontWeight:
                _controller.text.isEmpty ? FontWeight.normal : FontWeight.bold,
            color: Colors.white,
          ),
        ),
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        textInputAction: TextInputAction.next,
        onFieldSubmitted: (_) {
          FocusScope.of(context)
              .requestFocus(focusNodes[(focusIndex + 1) % focusNodes.length]);
        },
        validator: (v) {
          if (v != null && v.isNotEmpty) {
            final number = double.tryParse(v);
            if (number == null) {
              return 'الرجاء إدخال رقم صحيح';
            }
          }
          return null;
        },
      ),
    );
  }
}
