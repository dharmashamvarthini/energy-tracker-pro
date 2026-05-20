import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/database_helper.dart';
import '../models/bill_model.dart';

class AlertsScreen extends StatefulWidget {
  const AlertsScreen({super.key});

  @override
  State<AlertsScreen> createState() => _AlertsScreenState();
}

class _AlertsScreenState extends State<AlertsScreen> {
  List<BillModel> _bills = [];
  bool _isLoading = true;
  double _usageLimit = 200;
  double _currentUnits = 7000;
  double _currentStress = 0;
  double _currentIncome = 25000;
  double _currentEnergyCost = 70700;
  
  final TextEditingController _limitController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadData();
    _loadSettings();
  }

  Future<void> _loadData() async {
    _bills = await DatabaseHelper.instance.getAllBills();
    
    // Get latest bill data
    if (_bills.isNotEmpty) {
      _currentUnits = _bills.first.units;
    }
    
    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _usageLimit = prefs.getDouble('usageLimit') ?? 200;
      _currentIncome = prefs.getDouble('monthlyIncome') ?? 25000;
      _currentEnergyCost = prefs.getDouble('lastEnergyCost') ?? 70700;
      _limitController.text = _usageLimit.toString();
    });
    _calculateStress();
  }

  void _calculateStress() {
    if (_currentIncome > 0) {
      _currentStress = (_currentEnergyCost / _currentIncome) * 100;
    }
  }

  Future<void> _saveLimit() async {
    double newLimit = double.tryParse(_limitController.text) ?? _usageLimit;
    if (newLimit <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid limit')),
      );
      return;
    }
    
    setState(() {
      _usageLimit = newLimit;
    });
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('usageLimit', newLimit);
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Usage limit set to ${_usageLimit.toStringAsFixed(0)} kWh')),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Check for active alerts
    List<String> activeAlerts = [];
    
    // Alert 1: Energy stress > 10%
    if (_currentStress > 10) {
      activeAlerts.add('High energy stress! Your energy cost is more than 10% of income.');
    }
    
    // Alert 2: Usage exceeds limit
    if (_currentUnits > _usageLimit) {
      activeAlerts.add('Energy usage exceeds limit! Current: ${_currentUnits.toStringAsFixed(0)} kWh. Limit: ${_usageLimit.toStringAsFixed(0)} kWh.');
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Alerts'),
        backgroundColor: Colors.green,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Active Alerts Section
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
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Active Alerts',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.red,
                          ),
                        ),
                        const SizedBox(height: 15),
                        
                        if (activeAlerts.isEmpty)
                          Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: Colors.green.shade50,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Row(
                              children: [
                                Icon(Icons.check_circle, color: Colors.green),
                                SizedBox(width: 10),
                                Text('No active alerts. Everything looks good!'),
                              ],
                            ),
                          )
                        else
                          ...activeAlerts.map((alert) => Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.red.shade50,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: Colors.red.shade200),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.warning, color: Colors.red),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    alert,
                                    style: const TextStyle(fontSize: 14),
                                  ),
                                ),
                              ],
                            ),
                          )).toList(),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // Set Usage Alert Limit Section
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
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Set Usage Alert Limit',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 15),
                        
                        // Usage Limit Input
                        TextField(
                          controller: _limitController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            labelText: 'Usage Limit (kWh)',
                            prefixIcon: const Icon(Icons.speed, color: Colors.green),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: Colors.green, width: 2),
                            ),
                            suffixText: 'kWh',
                          ),
                        ),
                        const SizedBox(height: 15),
                        
                        // Save Limit Button
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            onPressed: _saveLimit,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: const Text(
                              'Save Limit',
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                        
                        const SizedBox(height: 15),
                        
                        // Current Limit Display
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text(
                                'Current Limit: ',
                                style: TextStyle(fontSize: 14),
                              ),
                              Text(
                                '${_usageLimit.toStringAsFixed(0)} kWh',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // Info Card
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.info, color: Colors.blue),
                        SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'You will receive alerts when:',
                            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Column(
                      children: [
                        Row(
                          children: [
                            Icon(Icons.circle, size: 8, color: Colors.red),
                            SizedBox(width: 8),
                            Text('Energy stress exceeds 10% of income'),
                          ],
                        ),
                        SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(Icons.circle, size: 8, color: Colors.red),
                            SizedBox(width: 8),
                            Text('Energy usage exceeds your set limit'),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}