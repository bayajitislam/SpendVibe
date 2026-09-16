import '../../../../core/database/app_database.dart';
import '../../domain/entities/transaction_entity.dart';
import '../../domain/entities/category_entity.dart';
import '../../domain/repositories/i_transaction_repository.dart';
import '../mappers/transaction_mapper.dart';

class TransactionRepositoryImpl implements ITransactionRepository {
  final AppDatabase _db;

  TransactionRepositoryImpl(this._db);

  @override
  Stream<List<TransactionEntity>> watchAllTransactions() {
    return _db.watchAllTransactions().asyncMap((rows) async {
      final categories = await _db.getAllCategories();
      final catMap = {for (var c in categories) c.id: c};
      return rows.map((r) => TransactionMapper.toEntity(r, category: catMap[r.categoryId])).toList();
    });
  }

  @override
  Stream<List<TransactionEntity>> watchTransactionsBetween(DateTime start, DateTime end) {
    return _db.watchTransactionsBetween(start, end).asyncMap((rows) async {
      final categories = await _db.getAllCategories();
      final catMap = {for (var c in categories) c.id: c};
      return rows.map((r) => TransactionMapper.toEntity(r, category: catMap[r.categoryId])).toList();
    });
  }

  @override
  Future<List<TransactionEntity>> getAllTransactions() async {
    final rows = await _db.getAllTransactions();
    final categories = await _db.getAllCategories();
    final catMap = {for (var c in categories) c.id: c};
    return rows.map((r) => TransactionMapper.toEntity(r, category: catMap[r.categoryId])).toList();
  }

  @override
  Future<void> addTransaction(TransactionEntity transaction) async {
    await _db.insertTransaction(TransactionMapper.toCompanion(transaction));
  }

  @override
  Future<void> deleteTransaction(String id) async {
    await _db.deleteTransaction(id);
  }

  @override
  Stream<List<CategoryEntity>> watchCategories() {
    return _db.watchAllCategories().map((rows) => rows.map(TransactionMapper.toCategoryEntity).toList());
  }

  @override
  Future<List<CategoryEntity>> getAllCategories() async {
    final rows = await _db.getAllCategories();
    return rows.map(TransactionMapper.toCategoryEntity).toList();
  }
}
