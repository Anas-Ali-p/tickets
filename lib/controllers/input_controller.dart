import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/daily_record.dart';
import '../models/manual_expense.dart';
import 'database_controller.dart';

class InputController with ChangeNotifier {
  final DatabaseController _dbController = DatabaseController();

  // Book Information Fields
  double _ticketPrice = 0.8;
  int _preSale = 0;
  int _bookNumber = 0;
  int _completedBooks = 0;
  int _ticketsPerSheet = 0;
  double _grocery = 0;
  double _sarf = 0;

  // Expenses Fields
  double _lunch = 3.2;
  double _hetham = 2.0;
  double _alhouri = 0;
  double _majed = 0;
  double _white = 0;
  double _anas = 0;
  List<ManualExpense> _manualExpenses = [];

  // Results Fields
  int _remainingTickets = 0;
  int _tickets = 0;
  double _expenseTotal = 0;
  double _cashBox = 0;
  double _total = 0;

  // Getters
  double get ticketPrice => _ticketPrice;
  int get preSale => _preSale;
  int get bookNumber => _bookNumber;
  int get completedBooks => _completedBooks;
  int get ticketsPerSheet => _ticketsPerSheet;
  double get grocery => _grocery;
  double get sarf => _sarf;
  double get lunch => _lunch;
  double get hetham => _hetham;
  double get alhouri => _alhouri;
  double get majed => _majed;
  double get white => _white;
  double get anas => _anas;
  List<ManualExpense> get manualExpenses => _manualExpenses;
  int get remainingTickets => _remainingTickets;
  int get tickets => _tickets;
  double get expenseTotal => _expenseTotal;
  double get cashBox => _cashBox;
  double get total => _total;

  // Setters with calculations
  set ticketPrice(double value) {
    _ticketPrice = value;
    _calculateCashBox();
    notifyListeners();
  }

  set preSale(int value) {
    _preSale = value;
    _calculateTickets();
    notifyListeners();
  }

  set bookNumber(int value) {
    _bookNumber = value;
    _calculateRemainingTickets();
    notifyListeners();
  }

  set completedBooks(int value) {
    _completedBooks = value;
    _calculateRemainingTickets();
    _calculateTickets();
    notifyListeners();
  }

  set ticketsPerSheet(int value) {
    _ticketsPerSheet = value;
    _calculateRemainingTickets();
    notifyListeners();
  }

  set grocery(double value) {
    _grocery = value;
    notifyListeners();
  }

  set sarf(double value) {
    _sarf = value;
    notifyListeners();
  }

  // Expenses Setters
  set lunch(double value) {
    _lunch = value;
    _calculateExpenseTotal();
    notifyListeners();
  }

  set hetham(double value) {
    _hetham = value;
    _calculateExpenseTotal();
    notifyListeners();
  }

  set alhouri(double value) {
    _alhouri = value;
    _calculateExpenseTotal();
    notifyListeners();
  }

  set majed(double value) {
    _majed = value;
    _calculateExpenseTotal();
    notifyListeners();
  }

  set white(double value) {
    _white = value;
    _calculateExpenseTotal();
    notifyListeners();
  }

  set anas(double value) {
    _anas = value;
    _calculateExpenseTotal();
    notifyListeners();
  }

  // Manual Expenses Management
  void addManualExpense(String name, double value) {
    _manualExpenses.add(ManualExpense(name: name, value: value));
    _calculateExpenseTotal();
    notifyListeners();
  }

  void removeManualExpense(int index) {
    _manualExpenses.removeAt(index);
    _calculateExpenseTotal();
    notifyListeners();
  }

  // Calculation Methods
  void _calculateRemainingTickets() {
    final base = ((50 - (_bookNumber - 1)) * 5) - (5 - _ticketsPerSheet);
    final booksBonus = _completedBooks > 0 ? _completedBooks * 250 : 0;
    _remainingTickets = base + booksBonus;
    _calculateTickets();
  }

  void _calculateTickets() {
    final preSaleTotal = _preSale + (_completedBooks * 250);
    _tickets = preSaleTotal - _remainingTickets;
    _calculateCashBox();
  }

  void _calculateCashBox() {
    _cashBox = _tickets * _ticketPrice;
    _calculateTotal();
  }

  void _calculateExpenseTotal() {
    final manualTotal =
        _manualExpenses.fold(0.0, (sum, item) => sum + item.value);
    _expenseTotal =
        _lunch + _hetham + _alhouri + _majed + _white + _anas + manualTotal;
    _calculateTotal();
  }

  void _calculateTotal() {
    _total = _cashBox - _expenseTotal;
    notifyListeners();
  }

  // Save to Database
  Future<bool> saveRecord() async {
    try {
      final today = DateFormat('yyyy-MM-dd').format(DateTime.now());

      final record = DailyRecord(
        date: today,
        ticketPrice: _ticketPrice,
        preSale: _preSale,
        bookNumber: _bookNumber,
        completedBooks: _completedBooks,
        ticketsPerSheet: _ticketsPerSheet,
        grocery: _grocery,
        sarf: _sarf,
        lunch: _lunch,
        hetham: _hetham,
        alhouri: _alhouri,
        majed: _majed,
        white: _white,
        anas: _anas,
        manualExpenses: _manualExpenses,
        remainingTickets: _remainingTickets,
        tickets: _tickets,
        expenseTotal: _expenseTotal,
        cashBox: _cashBox,
        total: _total,
      );

      // Check for existing record
      final exists = await _dbController.recordExists(today);
      if (exists) {
        await _dbController.deleteRecord(today);
      }

      await _dbController.insertRecord(record);
      return true;
    } catch (e) {
      debugPrint('Error saving record: $e');
      return false;
    }
  }

  // Reset all fields
  void resetFields() {
    _ticketPrice = 0.8;
    _preSale = 0;
    _bookNumber = 0;
    _completedBooks = 0;
    _ticketsPerSheet = 0;
    _grocery = 0;
    _sarf = 0;
    _lunch = 3.2;
    _hetham = 2.0;
    _alhouri = 0;
    _majed = 0;
    _white = 0;
    _anas = 0;
    _manualExpenses.clear();
    _remainingTickets = 0;
    _tickets = 0;
    _expenseTotal = 0;
    _cashBox = 0;
    _total = 0;
    notifyListeners();
  }

  void updateManualExpense(int index, String newName, double newValue) {
    if (index >= 0 && index < _manualExpenses.length) {
      _manualExpenses[index] = _manualExpenses[index].copyWith(
        name: newName,
        value: newValue,
      );
      _calculateExpenseTotal();
      notifyListeners();
    }
  }

  void updateManualExpenseName(int index, String newName) {
    if (index >= 0 && index < _manualExpenses.length) {
      _manualExpenses[index] = _manualExpenses[index].copyWith(name: newName);

      _calculateExpenseTotal();

      notifyListeners();
    }
  }

  void updateManualExpenseValue(int index, double newValue) {
    if (index >= 0 && index < _manualExpenses.length) {
      _manualExpenses[index] = _manualExpenses[index].copyWith(
        //name: newName,

        value: newValue,
      );

      _calculateExpenseTotal();

      notifyListeners();
    }
  }

  bool isLoading = false;

  Future<void> loadLastRecord() async {
    isLoading = true;
    notifyListeners();

    try {
      final dbController = DatabaseController();
      final records = await dbController.getAllRecords();

      if (records.isNotEmpty) {
        preSale = records.first.remainingTickets;
      } else {
        preSale = 0;
      }
    } catch (e) {
      debugPrint('Error loading last record: $e');
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
