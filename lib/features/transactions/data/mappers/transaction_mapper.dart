import 'package:drift/drift.dart';
import '../../../../core/database/app_database.dart';
import '../../../../core/constants/app_categories.dart';
import '../../domain/entities/transaction_entity.dart';
import '../../domain/entities/category_entity.dart';

class TransactionMapper {
  TransactionMapper._();

  static TransactionEntity toEntity(
    TransactionsTableData data, {
    CategoriesTableData? category,
  }) {
    final type = data.type == 'income' ? TransactionType.income : TransactionType.expense;
    
    return TransactionEntity(
      id: data.id,
      title: data.title,
      amount: data.amount,
      date: data.date,
      type: type,
      categoryId: data.categoryId,
      categoryName: category?.name,
      categoryIconCodePoint: category?.iconCodePoint,
      categoryColorValue: category?.colorValue,
      note: data.note,
    );
  }

  static TransactionsTableCompanion toCompanion(TransactionEntity entity) {
    return TransactionsTableCompanion.insert(
      id: entity.id,
      title: entity.title,
      amount: entity.amount,
      date: entity.date,
      type: entity.type.name,
      categoryId: entity.categoryId,
      note: Value(entity.note),
    );
  }

  static CategoryEntity toCategoryEntity(CategoriesTableData data) {
    return CategoryEntity(
      id: data.id,
      name: data.name,
      iconCodePoint: data.iconCodePoint,
      colorValue: data.colorValue,
      type: data.type == 'income' ? TransactionType.income : TransactionType.expense,
      isCustom: data.isCustom,
    );
  }
}
