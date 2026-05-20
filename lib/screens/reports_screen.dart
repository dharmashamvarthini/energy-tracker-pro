import 'package:flutter/material.dart';
import 'package:printing/printing.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import '../utils/database_helper.dart';
import '../models/bill_model.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  List<BillModel> _bills = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    _bills = await DatabaseHelper.instance.getAllBills();
    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _generatePDF() async {
    final pdf = pw.Document();
    
    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build: (context) => [
          pw.Header(
            level: 0,
            child: pw.Text('Energy Tracker Pro - Bill Report', style: pw.TextStyle(fontSize: 24)),
          ),
          pw.SizedBox(height: 20),
          pw.Text('Generated on: ${DateTime.now().toString().split(' ')[0]}'),
          pw.SizedBox(height: 20),
          pw.Table(
            border: pw.TableBorder.all(),
            children: [
              pw.TableRow(
                children: [
                  pw.Padding(padding: const pw.EdgeInsets.all(8), child: pw.Text('Month', style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
                  pw.Padding(padding: const pw.EdgeInsets.all(8), child: pw.Text('Amount (₹)', style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
                  pw.Padding(padding: const pw.EdgeInsets.all(8), child: pw.Text('Units (kWh)', style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
                  pw.Padding(padding: const pw.EdgeInsets.all(8), child: pw.Text('Stress %', style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
                ],
              ),
              for (var bill in _bills)
                pw.TableRow(
                  children: [
                    pw.Padding(padding: const pw.EdgeInsets.all(8), child: pw.Text(bill.month)),
                    pw.Padding(padding: const pw.EdgeInsets.all(8), child: pw.Text('₹${bill.amount.toStringAsFixed(2)}')),
                    pw.Padding(padding: const pw.EdgeInsets.all(8), child: pw.Text(bill.units.toStringAsFixed(0))),
                    pw.Padding(padding: const pw.EdgeInsets.all(8), child: pw.Text('${bill.stressLevel.toStringAsFixed(1)}%')),
                  ],
                ),
            ],
          ),
          pw.SizedBox(height: 30),
          pw.Text('Summary:', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 10),
          pw.Text('Total Bills: ${_bills.length}'),
          pw.Text('Average Bill: ₹${(_bills.map((b) => b.amount).reduce((a,b) => a+b) / _bills.length).toStringAsFixed(2)}'),
          pw.Text('Average Stress: ${(_bills.map((b) => b.stressLevel).reduce((a,b) => a+b) / _bills.length).toStringAsFixed(1)}%'),
        ],
      ),
    );
    
    await Printing.sharePdf(bytes: await pdf.save(), filename: 'energy_report.pdf');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Reports')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _bills.isEmpty
              ? const Center(child: Text('No data available. Add bills first.'))
              : Column(
                  children: [
                    Expanded(
                      child: ListView.builder(
                        itemCount: _bills.length,
                        itemBuilder: (context, index) {
                          final bill = _bills[index];
                          return Card(
                            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            child: ListTile(
                              title: Text(bill.month),
                              subtitle: Text('₹${bill.amount} | ${bill.units} kWh'),
                              trailing: Text('${bill.stressLevel.toStringAsFixed(1)}%'),
                            ),
                          );
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton.icon(
                          onPressed: _generatePDF,
                          icon: const Icon(Icons.picture_as_pdf),
                          label: const Text('Download PDF Report'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
    );
  }
}