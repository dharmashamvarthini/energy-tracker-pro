import 'dart:io';
import 'package:csv/csv.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

class CsvService {
  static Future<void> exportToCSV({
    required String userName,
    required double income,
    required double units,
    required double energyCost,
    required double stressPercent,
    required String stressLevel,
    required List<double> monthlyUsage,
    required List<String> months,
  }) async {
    List<List<dynamic>> csvData = [
      ['Energy Tracker Report'],
      ['Generated on:', DateTime.now().toString()],
      [],
      ['User Information'],
      ['Name', userName],
      ['Monthly Income', income],
      ['Units Consumed', units],
      ['Energy Cost', energyCost],
      ['Stress Percentage', stressPercent],
      ['Stress Level', stressLevel],
      [],
      ['Monthly Usage History'],
      ['Month', 'Usage (kWh)'],
    ];
    
    for (int i = 0; i < months.length; i++) {
      csvData.add([months[i], monthlyUsage[i]]);
    }
    
    String csv = const ListToCsvConverter().convert(csvData);
    final directory = await getTemporaryDirectory();
    final file = File('${directory.path}/energy_report.csv');
    await file.writeAsString(csv);
    await Share.shareXFiles([XFile(file.path)], text: 'Energy Report CSV');
  }
}