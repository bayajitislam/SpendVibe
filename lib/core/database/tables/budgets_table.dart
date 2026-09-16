import 'package:drift/drift.dart';

class BudgetsTable extends Table {
  TextColumn get id => text()();
  IntColumn get month => integer()(); // 1 - 12
  IntColumn get year => integer()();
  RealColumn get amount => real()();
  TextColumn get categoryId => text().nullable()(); // null = overall monthly budget

  @override
  Set<Column> get primaryKey => {id};
}
