import 'dart:io';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

class PdfService {
  static Future<void> generateReport({
    required String userName,
    required double income,
    required double units,
    required double energyCost,
    required double stressPercent,
    required String stressLevel,
    required List<double> monthlyUsage,
    required List<String> months,
  }) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build: (context) => [
          pw.Header(
            level: 0,
            child: pw.Text('Energy Tracker Report', style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
          ),
          pw.SizedBox(height: 20),
          pw.Text('Report generated on: ${DateTime.now().toString().substring(0, 16)}'),
          pw.SizedBox(height: 20),
          pw.Text('User Information', style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 10),
          pw.Text('Name: $userName'),
          pw.Text('Monthly Income: ₹${income.toStringAsFixed(0)}'),
          pw.Text('Units Consumed: ${units.toStringAsFixed(0)} kWh'),
          pw.SizedBox(height: 20),
          pw.Text('Energy Analysis', style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 10),
          pw.Text('Total Energy Cost: ₹${energyCost.toStringAsFixed(0)}'),
          pw.Text('Stress Percentage: ${stressPercent.toStringAsFixed(2)}%'),
          pw.Text('Stress Level: $stressLevel'),
          pw.SizedBox(height: 20),
          pw.Text('Monthly Usage History', style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 10),
          pw.TableHelper.fromTextArray(
            headers: ['Month', 'Usage (kWh)'],
            data: List.generate(months.length, (i) => [months[i], monthlyUsage[i].toString()]),
          ),
        ],
      ),
    );

    final output = await getTemporaryDirectory();
    final file = File('${output.path}/energy_report.pdf');
    await file.writeAsBytes(await pdf.save());
    await Share.shareXFiles([XFile(file.path)], text: 'Energy Report');
  }
}