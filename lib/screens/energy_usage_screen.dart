import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../utils/database_helper.dart';
import '../models/bill_model.dart';

class EnergyUsageScreen extends StatefulWidget {
  const EnergyUsageScreen({super.key});

  @override
  State<EnergyUsageScreen> createState() => _EnergyUsageScreenState();
}

class _EnergyUsageScreenState extends State<EnergyUsageScreen> {
  List<BillModel> _bills = [];
  bool _isLoading = true;
  
  // Device-wise consumption data
  Map<String, double> _deviceConsumption = {
    'AC': 120.0,
    'TV': 50.0,
    'Fan': 40.0,
    'Fridge': 80.0,
    'Lights': 30.0,
    'Others': 30.0,
  };
  
  List<Color> _pieColors = [
    Colors.red,
    Colors.blue,
    Colors.green,
    Colors.orange,
    Colors.yellow,
    Colors.purple,
  ];

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Energy Usage'),
        backgroundColor: Colors.green,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Device-wise Consumption Section
                  const Text(
                    'Device-wise Consumption',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 15),
                  
                  // Device list with consumption
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: const [
                        BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, 5)),
                      ],
                    ),
                    child: Column(
                      children: [
                        // Device chips row
                        Wrap(
                          spacing: 10,
                          runSpacing: 10,
                          children: _deviceConsumption.keys.map((device) {
                            return Chip(
                              label: Text(device),
                              backgroundColor: Colors.grey.shade200,
                              labelStyle: const TextStyle(color: Colors.black),
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 20),
                        
                        // Device consumption list
                        ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: _deviceConsumption.length,
                          separatorBuilder: (context, index) => const Divider(),
                          itemBuilder: (context, index) {
                            String device = _deviceConsumption.keys.elementAt(index);
                            double consumption = _deviceConsumption[device]!;
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              child: Row(
                                children: [
                                  Container(
                                    width: 4,
                                    height: 30,
                                    color: _pieColors[index % _pieColors.length],
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    flex: 2,
                                    child: Text(
                                      device,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    flex: 1,
                                    child: Text(
                                      '${consumption.toStringAsFixed(1)} kWh',
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      textAlign: TextAlign.right,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 25),
                  
                  // Pie Chart Section
                  const Text(
                    'Usage Distribution',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 15),
                  
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: const [
                        BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, 5)),
                      ],
                    ),
                    child: Column(
                      children: [
                        SizedBox(
                          height: 250,
                          child: PieChart(
                            PieChartData(
                              sections: _getPieSections(),
                              centerSpaceRadius: 40,
                              sectionsSpace: 2,
                              pieTouchData: PieTouchData(enabled: false),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        
                        // Legend
                        Wrap(
                          spacing: 15,
                          runSpacing: 10,
                          alignment: WrapAlignment.center,
                          children: _getLegend(),
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 25),
                  
                  // Monthly Usage Trend Section
                  if (_bills.isNotEmpty)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Monthly Usage Trend',
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 15),
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(15),
                            boxShadow: const [
                              BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, 5)),
                            ],
                          ),
                          child: SizedBox(
                            height: 300,
                            child: BarChart(
                              BarChartData(
                                alignment: BarChartAlignment.spaceAround,
                                maxY: _getMaxUnits() + 100,
                                barGroups: _getBarGroups(),
                                titlesData: FlTitlesData(
                                  leftTitles: AxisTitles(
                                    sideTitles: SideTitles(
                                      showTitles: true,
                                      reservedSize: 40,
                                      getTitlesWidget: (value, meta) {
                                        return Text(
                                          value.toInt().toString(),
                                          style: const TextStyle(fontSize: 12),
                                        );
                                      },
                                    ),
                                  ),
                                  bottomTitles: AxisTitles(
                                    sideTitles: SideTitles(
                                      showTitles: true,
                                      getTitlesWidget: (value, meta) {
                                        if (value.toInt() >= 0 && value.toInt() < _bills.length) {
                                          return Padding(
                                            padding: const EdgeInsets.only(top: 8),
                                            child: Text(
                                              _bills[value.toInt()].month.split('/')[0],
                                              style: const TextStyle(fontSize: 12),
                                            ),
                                          );
                                        }
                                        return const Text('');
                                      },
                                      reservedSize: 40,
                                    ),
                                  ),
                                  rightTitles: AxisTitles(
                                    sideTitles: SideTitles(showTitles: false),
                                  ),
                                  topTitles: AxisTitles(
                                    sideTitles: SideTitles(showTitles: false),
                                  ),
                                ),
                                gridData: const FlGridData(show: true),
                                borderData: FlBorderData(show: false),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  
                  if (_bills.isEmpty)
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: const Center(
                        child: Text(
                          'No monthly data available. Add bills in Input Data page.',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.grey),
                        ),
                      ),
                    ),
                ],
              ),
            ),
    );
  }

  List<PieChartSectionData> _getPieSections() {
    List<PieChartSectionData> sections = [];
    double total = _deviceConsumption.values.reduce((a, b) => a + b);
    
    int index = 0;
    _deviceConsumption.forEach((device, consumption) {
      double percentage = (consumption / total) * 100;
      sections.add(
        PieChartSectionData(
          value: consumption,
          title: '${percentage.toStringAsFixed(1)}%',
          color: _pieColors[index % _pieColors.length],
          radius: 80,
          titleStyle: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      );
      index++;
    });
    return sections;
  }

  List<Widget> _getLegend() {
    List<Widget> legends = [];
    int index = 0;
    _deviceConsumption.forEach((device, consumption) {
      legends.add(
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 16,
              height: 16,
              decoration: BoxDecoration(
                color: _pieColors[index % _pieColors.length],
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 5),
            Text(
              device,
              style: const TextStyle(fontSize: 12),
            ),
          ],
        ),
      );
      index++;
    });
    return legends;
  }

  double _getMaxUnits() {
    if (_bills.isEmpty) return 500;
    double maxUnits = 0;
    for (var bill in _bills) {
      if (bill.units > maxUnits) maxUnits = bill.units;
    }
    return maxUnits + 100;
  }

  List<BarChartGroupData> _getBarGroups() {
    List<BarChartGroupData> groups = [];
    for (int i = 0; i < _bills.length && i < 12; i++) {
      groups.add(
        BarChartGroupData(
          x: i,
          barRods: [
            BarChartRodData(
              toY: _bills[i].units,
              color: Colors.green,
              width: 35,
              borderRadius: BorderRadius.circular(5),
            ),
          ],
        ),
      );
    }
    return groups;
  }
}