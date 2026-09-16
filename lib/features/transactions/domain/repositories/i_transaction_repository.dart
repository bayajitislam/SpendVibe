import '../entities/transaction_entity.dart';
import '../entities/category_entity.dart';

abstract class ITransactionRepository {
  Stream<List<TransactionEntity>> watchAllTransactions();
  Stream<List<TransactionEntity>> watchTransactionsBetween(DateTime start, DateTime end);
  Future<List<TransactionEntity>> getAllTransactions();
  Future<void> addTransaction(TransactionEntity transaction);
  Future<void> deleteTransaction(String id);
  Stream<List<CategoryEntity>> watchCategories();
  Future<List<CategoryEntity>> getAllCategories();
}
