import '../../../../core/constants/app_categories.dart';

class CategoryEntity {
  final String id;
  final String name;
  final int iconCodePoint;
  final int colorValue;
  final TransactionType type;
  final bool isCustom;

  const CategoryEntity({
    required this.id,
    required this.name,
    required this.iconCodePoint,
    required this.colorValue,
    required this.type,
    this.isCustom = false,
  });
}
