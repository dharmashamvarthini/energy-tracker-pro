import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../models/bill_model.dart';
import '../utils/database_helper.dart';

class InputDataScreen extends StatefulWidget {
  const InputDataScreen({super.key});

  @override
  State<InputDataScreen> createState() => _InputDataScreenState();
}

class _InputDataScreenState extends State<InputDataScreen> {
  final TextEditingController _incomeController = TextEditingController();
  final TextEditingController _unitsController = TextEditingController();
  final TextEditingController _tariffController = TextEditingController();
  final TextEditingController _fixedChargesController = TextEditingController();
  final TextEditingController _familyController = TextEditingController();
  
  bool _isSaving = false;
  
  final FlutterLocalNotificationsPlugin _notifications = FlutterLocalNotificationsPlugin();

  @override
  void initState() {
    super.initState();
    _initNotifications();
    _loadSavedData();
  }

  void _initNotifications() async {
    const AndroidInitializationSettings androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const DarwinInitializationSettings iosSettings = DarwinInitializationSettings();
    const InitializationSettings settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );
    await _notifications.initialize(settings);
  }

  Future<void> _loadSavedData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _incomeController.text = prefs.getDouble('monthlyIncome')?.toString() ?? '25000';
      _familyController.text = prefs.getInt('familyMembers')?.toString() ?? '4';
      _tariffController.text = prefs.getDouble('tariffPerUnit')?.toString() ?? '10';
      _fixedChargesController.text = prefs.getDouble('fixedCharges')?.toString() ?? '700';
      _unitsController.text = prefs.getDouble('lastUnits')?.toString() ?? '7000';
    });
  }

  Future<void> _saveData() async {
    if (_incomeController.text.isEmpty || _unitsController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter Income and Units')),
      );
      return;
    }

    setState(() {
      _isSaving = true;
    });

    double income = double.parse(_incomeController.text);
    double units = double.parse(_unitsController.text);
    double tariff = double.tryParse(_tariffController.text) ?? 10;
    double fixedCharges = double.tryParse(_fixedChargesController.text) ?? 0;
    int familyMembers = int.tryParse(_familyController.text) ?? 1;
    
    // Calculate total bill amount
    double energyCost = (units * tariff) + fixedCharges;
    double stressPercent = (energyCost / income) * 100;
    
    // Save to SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('monthlyIncome', income);
    await prefs.setInt('familyMembers', familyMembers);
    await prefs.setDouble('tariffPerUnit', tariff);
    await prefs.setDouble('fixedCharges', fixedCharges);
    await prefs.setDouble('lastUnits', units);
    await prefs.setDouble('lastEnergyCost', energyCost);
    await prefs.setDouble('lastStressPercent', stressPercent);
    
    // Save to database for history
    BillModel bill = BillModel(
      amount: energyCost,
      units: units,
      month: _getCurrentMonth(),
      stressLevel: stressPercent,
      date: DateTime.now().toString(),
    );
    await DatabaseHelper.instance.insertBill(bill);
    
    // Check for high stress notification (>22%)
    if (stressPercent > 22) {
      final notificationsEnabled = prefs.getBool('notificationsEnabled') ?? true;
      if (notificationsEnabled) {
        await _showNotification(
          '⚠️ High Stress Alert!',
          'Your energy stress is ${stressPercent.toStringAsFixed(1)}%. Please check your usage.',
        );
      }
    }

    setState(() {
      _isSaving = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Data saved successfully!')),
    );
    
    // Navigate back to dashboard
    Navigator.pop(context);
  }
  
  String _getCurrentMonth() {
    final now = DateTime.now();
    return '${now.month}/${now.year}';
  }

  Future<void> _showNotification(String title, String body) async {
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'stress_channel',
      'Stress Alerts',
      importance: Importance.high,
      priority: Priority.high,
    );
    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails();
    const NotificationDetails details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );
    await _notifications.show(0, title, body, details);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Input Data'),
        backgroundColor: Colors.green,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
                boxShadow: const [
                  BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, 5)),
                ],
              ),
              child: Column(
                children: [
                  // Monthly Income
                  _buildInputField(
                    label: 'Monthly Income (₹)',
                    controller: _incomeController,
                    icon: Icons.account_balance_wallet,
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 15),
                  
                  // Units Consumed
                  _buildInputField(
                    label: 'Units Consumed (kWh)',
                    controller: _unitsController,
                    icon: Icons.electric_bolt,
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 15),
                  
                  // Tariff per Unit
                  _buildInputField(
                    label: 'Tariff per Unit (₹)',
                    controller: _tariffController,
                    icon: Icons.currency_rupee,
                    keyboardType: TextInputType.number,
                    hintText: 'e.g., 10',
                  ),
                  const SizedBox(height: 15),
                  
                  // Fixed Charges
                  _buildInputField(
                    label: 'Fixed Charges (₹)',
                    controller: _fixedChargesController,
                    icon: Icons.receipt,
                    keyboardType: TextInputType.number,
                    hintText: 'e.g., 700',
                  ),
                  const SizedBox(height: 15),
                  
                  // Family Members
                  _buildInputField(
                    label: 'Family Members',
                    controller: _familyController,
                    icon: Icons.family_restroom,
                    keyboardType: TextInputType.number,
                  ),
                  
                  const SizedBox(height: 30),
                  
                  // Save Button
                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton(
                      onPressed: _isSaving ? null : _saveData,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: _isSaving
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text(
                              'Save & Update',
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 20),
            
            // Info Card
            Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info, color: Colors.blue),
                  const SizedBox(width: 10),
                  const Expanded(
                    child: Text(
                      'Stress > 22% will trigger instant notification',
                      style: TextStyle(fontSize: 14),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    required TextInputType keyboardType,
    String? hintText,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        hintText: hintText,
        prefixIcon: Icon(icon, color: Colors.green),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.green, width: 2),
        ),
      ),
    );
  }
}