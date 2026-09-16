import '../../../../core/constants/app_categories.dart';

class TransactionEntity {
  final String id;
  final String title;
  final double amount;
  final DateTime date;
  final TransactionType type;
  final String categoryId;
  final String? categoryName;
  final int? categoryIconCodePoint;
  final int? categoryColorValue;
  final String? note;

  const TransactionEntity({
    required this.id,
    required this.title,
    required this.amount,
    required this.date,
    required this.type,
    required this.categoryId,
    this.categoryName,
    this.categoryIconCodePoint,
    this.categoryColorValue,
    this.note,
  });

  TransactionEntity copyWith({
    String? id,
    String? title,
    double? amount,
    DateTime? date,
    TransactionType? type,
    String? categoryId,
    String? categoryName,
    int? categoryIconCodePoint,
    int? categoryColorValue,
    String? note,
  }) {
    return TransactionEntity(
      id: id ?? this.id,
      title: title ?? this.title,
      amount: amount ?? this.amount,
      date: date ?? this.date,
      type: type ?? this.type,
      categoryId: categoryId ?? this.categoryId,
      categoryName: categoryName ?? this.categoryName,
      categoryIconCodePoint: categoryIconCodePoint ?? this.categoryIconCodePoint,
      categoryColorValue: categoryColorValue ?? this.categoryColorValue,
      note: note ?? this.note,
    );
  }
}
