import 'dart:convert';

import 'package:tickets/models/manual_expense.dart';

class DailyRecord {
  final String date;
  double ticketPrice;
  int preSale;
  int bookNumber;
  int completedBooks;
  int ticketsPerSheet;
  double grocery;
  double sarf;

  // Expenses
  double lunch;
  double hetham;
  double alhouri;
  double majed;
  double white;
  double anas;
  List<ManualExpense> manualExpenses;

  // Results
  int remainingTickets;
  int tickets;
  double expenseTotal;
  double cashBox;
  double total;

  DailyRecord({
    required this.date,
    this.ticketPrice = 800,
    this.preSale = 0,
    this.bookNumber = 0,
    this.completedBooks = 0,
    this.ticketsPerSheet = 0,
    this.grocery = 0,
    this.sarf = 0,
    this.lunch = 3200,
    this.hetham = 2000,
    this.alhouri = 0,
    this.majed = 0,
    this.white = 0,
    this.anas = 0,
    this.manualExpenses = const [],
    this.remainingTickets = 0,
    this.tickets = 0,
    this.expenseTotal = 5200,
    this.cashBox = 0,
    this.total = 0,
  });

  // Conversion methods for database
  Map<String, dynamic> toMap() {
    return {
      'date': date,
      'ticketPrice': ticketPrice,
      'preSale': preSale,
      'bookNumber': bookNumber,
      'completedBooks': completedBooks,
      'ticketsPerSheet': ticketsPerSheet,
      'grocery': grocery,
      'sarf': sarf,
      'lunch': lunch,
      'hetham': hetham,
      'alhouri': alhouri,
      'majed': majed,
      'white': white,
      'anas': anas,
      // 'manualExpenses': manualExpenses.map((e) => e.toMap()).toList(),
      'manualExpenses':
          jsonEncode(manualExpenses.map((e) => e.toMap()).toList()),
      'remainingTickets': remainingTickets,
      'tickets': tickets,
      'expenseTotal': expenseTotal,
      'cashBox': cashBox,
      'total': total,
    };
  }

  factory DailyRecord.fromMap(Map<String, dynamic> map) {
    return DailyRecord(
      date: map['date'],
      ticketPrice: map['ticketPrice'],
      preSale: map['preSale'],
      bookNumber: map['bookNumber'],
      completedBooks: map['completedBooks'],
      ticketsPerSheet: map['ticketsPerSheet'],
      grocery: map['grocery'],
      sarf: map['sarf'],
      lunch: map['lunch'],
      hetham: map['hetham'],
      alhouri: map['alhouri'],
      majed: map['majed'],
      white: map['white'],
      anas: map['anas'],
      manualExpenses: List<ManualExpense>.from(jsonDecode(map['manualExpenses'])
          .map((x) => ManualExpense.fromMap(x))),
      remainingTickets: map['remainingTickets'],
      tickets: map['tickets'],
      expenseTotal: map['expenseTotal'],
      cashBox: map['cashBox'],
      total: map['total'],
    );
  }
}
