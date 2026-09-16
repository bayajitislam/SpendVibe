import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:intl/intl.dart';
import '../../../transactions/domain/entities/transaction_entity.dart';

class CsvExporter {
  CsvExporter._();

  static Future<void> exportAndShare(List<TransactionEntity> transactions) async {
    final buffer = StringBuffer();
    // CSV Header
    buffer.writeln('Date,Type,Category,Title,Amount,Note');

    final dateFormat = DateFormat('yyyy-MM-dd HH:mm');

    for (final t in transactions) {
      final dateStr = dateFormat.format(t.date);
      final typeStr = t.type.name.toUpperCase();
      final categoryStr = _escapeCsv(t.categoryName ?? t.categoryId);
      final titleStr = _escapeCsv(t.title);
      final amountStr = t.amount.toStringAsFixed(2);
      final noteStr = _escapeCsv(t.note ?? '');

      buffer.writeln('$dateStr,$typeStr,$categoryStr,$titleStr,$amountStr,$noteStr');
    }

    final tempDir = await getTemporaryDirectory();
    final timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
    final file = File('${tempDir.path}/SpendVibe_Report_$timestamp.csv');

    await file.writeAsString(buffer.toString());

    await SharePlus.instance.share(
      ShareParams(
        files: [XFile(file.path, mimeType: 'text/csv')],
        text: 'SpendVibe Financial Report Export',
        subject: 'SpendVibe Transactions CSV',
      ),
    );
  }

  static String _escapeCsv(String field) {
    if (field.contains(',') || field.contains('"') || field.contains('\n')) {
      return '"${field.replaceAll('"', '""')}"';
    }
    return field;
  }
}
