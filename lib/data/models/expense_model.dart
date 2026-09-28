import 'package:cloud_firestore/cloud_firestore.dart';

/// Dart model representing an individual Expense item.
class Expense {
  final String id;
  final String title;
  final double amount;
  final String category;
  final DateTime date;
  final String? notes;

  const Expense({
    this.id = '',
    required this.title,
    required this.amount,
    required this.category,
    required this.date,
    this.notes,
  });

  /// Convert an Expense instance to a Map for Firestore storage
  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'amount': amount,
      'category': category,
      'date': Timestamp.fromDate(date),
      'notes': notes ?? '',
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  /// Create an Expense instance from a Map and Document ID
  factory Expense.fromMap(Map<String, dynamic> map, String id) {
    DateTime parsedDate;
    final dateVal = map['date'];

    if (dateVal is Timestamp) {
      parsedDate = dateVal.toDate();
    } else if (dateVal is String) {
      parsedDate = DateTime.tryParse(dateVal) ?? DateTime.now();
    } else if (dateVal is int) {
      parsedDate = DateTime.fromMillisecondsSinceEpoch(dateVal);
    } else {
      parsedDate = DateTime.now();
    }

    return Expense(
      id: id,
      title: map['title'] as String? ?? 'Untitled Expense',
      amount: (map['amount'] is num) ? (map['amount'] as num).toDouble() : 0.0,
      category: map['category'] as String? ?? 'Other',
      date: parsedDate,
      notes: (map['notes'] as String?)?.isNotEmpty == true ? map['notes'] as String : null,
    );
  }

  /// Create an Expense from a Firestore DocumentSnapshot
  factory Expense.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return Expense.fromMap(data, doc.id);
  }

  /// Clone the expense with optional updated fields
  Expense copyWith({
    String? id,
    String? title,
    double? amount,
    String? category,
    DateTime? date,
    String? notes,
  }) {
    return Expense(
      id: id ?? this.id,
      title: title ?? this.title,
      amount: amount ?? this.amount,
      category: category ?? this.category,
      date: date ?? this.date,
      notes: notes ?? this.notes,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Expense &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          title == other.title &&
          amount == other.amount &&
          category == other.category &&
          date == other.date &&
          notes == other.notes;

  @override
  int get hashCode =>
      id.hashCode ^
      title.hashCode ^
      amount.hashCode ^
      category.hashCode ^
      date.hashCode ^
      (notes?.hashCode ?? 0);

  @override
  String toString() {
    return 'Expense(id: $id, title: $title, amount: $amount, category: $category, date: $date)';
  }
}
