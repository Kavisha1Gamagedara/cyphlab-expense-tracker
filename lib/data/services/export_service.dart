import 'dart:io';
import 'package:csv/csv.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:share_plus/share_plus.dart';

import '../../core/constants.dart';
import '../models/expense_model.dart';

/// Service responsible for exporting expense records into PDF reports and CSV spreadsheets.
class ExportService {
  /// Generate a PDF document for the given expenses and display the print/share sheet.
  static Future<void> exportPdf({
    required List<Expense> expenses,
    required String periodTitle,
    required double totalAmount,
    String? currencySymbol,
  }) async {
    final currency = currencySymbol ?? AppConstants.defaultCurrency;
    final pdf = pw.Document();

    // Load logo if available
    pw.MemoryImage? logoImage;
    try {
      final logoBytes = await rootBundle.load(AppConstants.appLogo);
      logoImage = pw.MemoryImage(logoBytes.buffer.asUint8List());
    } catch (_) {
      // Continue without logo if not found
    }

    final dateFormat = DateFormat('yyyy-MM-dd');
    final generatedOn = DateFormat('MMM dd, yyyy HH:mm').format(DateTime.now());

    // Sort expenses chronologically descending
    final sortedExpenses = List<Expense>.from(expenses)
      ..sort((a, b) => b.date.compareTo(a.date));

    // Calculate category breakdown
    final Map<String, double> categoryTotals = {};
    for (final exp in sortedExpenses) {
      categoryTotals[exp.category] =
          (categoryTotals[exp.category] ?? 0.0) + exp.amount;
    }

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (pw.Context context) {
          return [
            // Header with branding
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              crossAxisAlignment: pw.CrossAxisAlignment.center,
              children: [
                pw.Row(
                  children: [
                    if (logoImage != null)
                      pw.Container(
                        width: 44,
                        height: 44,
                        margin: const pw.EdgeInsets.only(right: 12),
                        child: pw.Image(logoImage),
                      ),
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(
                          'Trace Expense Tracker',
                          style: pw.TextStyle(
                            fontSize: 20,
                            fontWeight: pw.FontWeight.bold,
                            color: PdfColors.indigo800,
                          ),
                        ),
                        pw.SizedBox(height: 2),
                        pw.Text(
                          'Expense & Financial Summary Report',
                          style: pw.TextStyle(
                            fontSize: 10,
                            color: PdfColors.grey700,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.end,
                  children: [
                    pw.Container(
                      padding: const pw.EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: pw.BoxDecoration(
                        color: PdfColors.indigo50,
                        borderRadius: pw.BorderRadius.circular(6),
                      ),
                      child: pw.Text(
                        periodTitle,
                        style: pw.TextStyle(
                          fontSize: 11,
                          fontWeight: pw.FontWeight.bold,
                          color: PdfColors.indigo900,
                        ),
                      ),
                    ),
                    pw.SizedBox(height: 4),
                    pw.Text(
                      'Generated: $generatedOn',
                      style: pw.TextStyle(fontSize: 8, color: PdfColors.grey600),
                    ),
                  ],
                ),
              ],
            ),

            pw.SizedBox(height: 16),
            pw.Divider(color: PdfColors.indigo200, thickness: 1.5),
            pw.SizedBox(height: 14),

            // Summary metrics cards
            pw.Row(
              children: [
                pw.Expanded(
                  child: pw.Container(
                    padding: const pw.EdgeInsets.all(12),
                    decoration: pw.BoxDecoration(
                      color: PdfColors.indigo600,
                      borderRadius: pw.BorderRadius.circular(8),
                    ),
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(
                          'TOTAL SPENDING',
                          style: pw.TextStyle(
                            fontSize: 9,
                            fontWeight: pw.FontWeight.bold,
                            color: PdfColors.indigo100,
                          ),
                        ),
                        pw.SizedBox(height: 4),
                        pw.Text(
                          '$currency${totalAmount.toStringAsFixed(2)}',
                          style: pw.TextStyle(
                            fontSize: 18,
                            fontWeight: pw.FontWeight.bold,
                            color: PdfColors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                pw.SizedBox(width: 12),
                pw.Expanded(
                  child: pw.Container(
                    padding: const pw.EdgeInsets.all(12),
                    decoration: pw.BoxDecoration(
                      color: PdfColors.grey100,
                      borderRadius: pw.BorderRadius.circular(8),
                      border: pw.Border.all(color: PdfColors.grey300),
                    ),
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(
                          'TOTAL TRANSACTIONS',
                          style: pw.TextStyle(
                            fontSize: 9,
                            fontWeight: pw.FontWeight.bold,
                            color: PdfColors.grey700,
                          ),
                        ),
                        pw.SizedBox(height: 4),
                        pw.Text(
                          '${sortedExpenses.length}',
                          style: pw.TextStyle(
                            fontSize: 18,
                            fontWeight: pw.FontWeight.bold,
                            color: PdfColors.indigo900,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                pw.SizedBox(width: 12),
                pw.Expanded(
                  child: pw.Container(
                    padding: const pw.EdgeInsets.all(12),
                    decoration: pw.BoxDecoration(
                      color: PdfColors.grey100,
                      borderRadius: pw.BorderRadius.circular(8),
                      border: pw.Border.all(color: PdfColors.grey300),
                    ),
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(
                          'ACTIVE CATEGORIES',
                          style: pw.TextStyle(
                            fontSize: 9,
                            fontWeight: pw.FontWeight.bold,
                            color: PdfColors.grey700,
                          ),
                        ),
                        pw.SizedBox(height: 4),
                        pw.Text(
                          '${categoryTotals.keys.length}',
                          style: pw.TextStyle(
                            fontSize: 18,
                            fontWeight: pw.FontWeight.bold,
                            color: PdfColors.indigo900,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            pw.SizedBox(height: 20),

            // Category breakdown table
            if (categoryTotals.isNotEmpty) ...[
              pw.Text(
                'Spending by Category',
                style: pw.TextStyle(
                  fontSize: 13,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.grey900,
                ),
              ),
              pw.SizedBox(height: 6),
              pw.TableHelper.fromTextArray(
                headers: ['Category', 'Amount', '% of Total'],
                data: categoryTotals.entries.map((entry) {
                  final pct = totalAmount > 0
                      ? (entry.value / totalAmount * 100).toStringAsFixed(1)
                      : '0.0';
                  return [
                    entry.key,
                    '$currency${entry.value.toStringAsFixed(2)}',
                    '$pct%',
                  ];
                }).toList(),
                border: pw.TableBorder.all(color: PdfColors.grey200),
                headerStyle: pw.TextStyle(
                  fontSize: 9,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.white,
                ),
                headerDecoration: const pw.BoxDecoration(
                  color: PdfColors.indigo700,
                ),
                cellStyle: const pw.TextStyle(fontSize: 8.5),
                cellPadding: const pw.EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 5,
                ),
                cellAlignment: pw.Alignment.centerLeft,
                cellAlignments: {
                  1: pw.Alignment.centerRight,
                  2: pw.Alignment.centerRight,
                },
              ),
              pw.SizedBox(height: 20),
            ],

            // Itemized Transaction Table
            pw.Text(
              'Itemized Transactions (${sortedExpenses.length})',
              style: pw.TextStyle(
                fontSize: 13,
                fontWeight: pw.FontWeight.bold,
                color: PdfColors.grey900,
              ),
            ),
            pw.SizedBox(height: 6),
            if (sortedExpenses.isEmpty)
              pw.Padding(
                padding: const pw.EdgeInsets.symmetric(vertical: 16),
                child: pw.Center(
                  child: pw.Text(
                    'No expenses recorded for this period.',
                    style: pw.TextStyle(
                      color: PdfColors.grey600,
                      fontStyle: pw.FontStyle.italic,
                    ),
                  ),
                ),
              )
            else
              pw.TableHelper.fromTextArray(
                headers: ['Date', 'Title', 'Category', 'Notes', 'Amount'],
                data: sortedExpenses.map((exp) {
                  return [
                    dateFormat.format(exp.date),
                    exp.title,
                    exp.category,
                    exp.notes?.trim().isNotEmpty == true ? exp.notes! : '-',
                    '$currency${exp.amount.toStringAsFixed(2)}',
                  ];
                }).toList(),
                border: pw.TableBorder.all(color: PdfColors.grey200),
                headerStyle: pw.TextStyle(
                  fontSize: 9,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.white,
                ),
                headerDecoration: const pw.BoxDecoration(
                  color: PdfColors.indigo900,
                ),
                cellStyle: const pw.TextStyle(fontSize: 8),
                cellPadding: const pw.EdgeInsets.symmetric(
                  horizontal: 6,
                  vertical: 5,
                ),
                rowDecoration: const pw.BoxDecoration(color: PdfColors.white),
                oddRowDecoration: const pw.BoxDecoration(
                  color: PdfColors.grey50,
                ),
                cellAlignment: pw.Alignment.centerLeft,
                cellAlignments: {
                  0: pw.Alignment.centerLeft,
                  1: pw.Alignment.centerLeft,
                  2: pw.Alignment.centerLeft,
                  3: pw.Alignment.centerLeft,
                  4: pw.Alignment.centerRight,
                },
              ),

            pw.SizedBox(height: 24),
            // Footer notice
            pw.Center(
              child: pw.Text(
                'Generated via Trace Expense Tracker - Keep your finances on trace.',
                style: pw.TextStyle(
                  fontSize: 8,
                  color: PdfColors.grey500,
                  fontStyle: pw.FontStyle.italic,
                ),
              ),
            ),
          ];
        },
      ),
    );

    final safePeriodName = periodTitle.replaceAll(RegExp(r'[^a-zA-Z0-9_-]'), '_');
    final fileName = 'trace_expenses_$safePeriodName.pdf';

    await Printing.sharePdf(
      bytes: await pdf.save(),
      filename: fileName,
    );
  }

  /// Generate a CSV file from expenses and open the system share sheet.
  static Future<void> exportCsv({
    required List<Expense> expenses,
    required String periodTitle,
    String? currencySymbol,
  }) async {
    final currency = currencySymbol ?? AppConstants.defaultCurrency;
    final dateFormat = DateFormat('yyyy-MM-dd HH:mm');

    // Build tabular rows
    final List<List<dynamic>> rows = [];

    // Header row
    rows.add([
      'ID',
      'Date',
      'Title',
      'Category',
      'Amount ($currency)',
      'Notes',
    ]);

    // Sort chronologically descending
    final sortedExpenses = List<Expense>.from(expenses)
      ..sort((a, b) => b.date.compareTo(a.date));

    for (final exp in sortedExpenses) {
      rows.add([
        exp.id,
        dateFormat.format(exp.date),
        exp.title,
        exp.category,
        exp.amount.toStringAsFixed(2),
        exp.notes ?? '',
      ]);
    }

    // Convert to CSV string using csv package
    final csvData = csv.encode(rows);

    final safePeriodName = periodTitle.replaceAll(RegExp(r'[^a-zA-Z0-9_-]'), '_');
    final fileName = 'trace_expenses_$safePeriodName.csv';

    // Save to temp directory and share via SharePlus
    final directory = await getTemporaryDirectory();
    final file = File('${directory.path}/$fileName');
    await file.writeAsString(csvData);

    await SharePlus.instance.share(
      ShareParams(
        files: [XFile(file.path, mimeType: 'text/csv')],
        text: 'Trace Expense Report - $periodTitle',
        subject: 'Expense Report ($periodTitle)',
      ),
    );
  }
}
