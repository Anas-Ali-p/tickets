import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

class ManualExpenseField extends StatefulWidget {
  final String name;
  final double value;
  final Function(String, double) onChanged;
  final VoidCallback onRemove;

  const ManualExpenseField({
    super.key,
    required this.name,
    required this.value,
    required this.onChanged,
    required this.onRemove,
  });

  @override
  State<ManualExpenseField> createState() => _ManualExpenseFieldState();
}

class _ManualExpenseFieldState extends State<ManualExpenseField> {
  late final TextEditingController _nameController;
  late final TextEditingController _valueController;
  bool isFirstEdit = true;
  String? placeholder;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.name);
    _valueController = TextEditingController(
      text: widget.value > 0 ? widget.value.toStringAsFixed(2) : '',
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _valueController.dispose();
    super.dispose();
  }

  void _handleValueChanged(String value) {
    if (value.isNotEmpty) {
      if (isFirstEdit) {
        setState(() {
          isFirstEdit = false;
          placeholder = null;
        });
      }
      final parsedValue = double.tryParse(value) ?? 0.0;
      widget.onChanged(_nameController.text, parsedValue);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: TextFormField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: 'اسم المصروف',
                prefixIcon: const Icon(Icons.label),
                filled: true,
                fillColor: Colors.blueGrey[900],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged: (value) => widget.onChanged(value, _parseValue()),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            flex: 2,
            child: TextFormField(
              controller: _valueController,
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[\d.]')),
              ],
              decoration: InputDecoration(
                labelText: 'القيمة',
                prefixIcon: const Icon(Icons.attach_money),
                filled: true,
                fillColor: Colors.blueGrey[900],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                  borderSide: BorderSide.none,
                ),
                hintText: placeholder,
              ),
              onChanged: _handleValueChanged,
              textInputAction: TextInputAction.next,
              onFieldSubmitted: (_) => FocusScope.of(context).nextFocus(),
              textAlign: TextAlign.center,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.red),
            onPressed: widget.onRemove,
          ),
        ],
      ),
    );
  }

  double _parseValue() {
    return double.tryParse(_valueController.text) ?? 0.0;
  }
}
