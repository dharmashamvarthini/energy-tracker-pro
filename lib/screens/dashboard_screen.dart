import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'input_data_screen.dart';
import 'energy_usage_screen.dart';
import 'bills_history_screen.dart';
import 'alerts_screen.dart';
import 'recommendations_screen.dart';
import 'reports_screen.dart';
import 'profile_screen.dart';
import '../utils/database_helper.dart';
import '../models/bill_model.dart';

class DashboardScreen extends StatefulWidget {
  final String userName;
  const DashboardScreen({super.key, required this.userName});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  bool _isDarkMode = false;
  bool _notificationsEnabled = true;
  
  // Dashboard data
  double _monthlyIncome = 25000;
  double _energyCost = 70700;
  double _unitsConsumed = 7000;
  int _familyMembers = 4;
  double _stressPercentage = 0;
  List<BillModel> _bills = [];

  @override
  void initState() {
    super.initState();
    _loadSettings();
    _loadData();
    _calculateStress();
  }

  Future<void> _loadData() async {
    _bills = await DatabaseHelper.instance.getAllBills();
    _calculateStress();
    setState(() {});
  }

  void _calculateStress() {
    if (_monthlyIncome > 0) {
      _stressPercentage = (_energyCost / _monthlyIncome) * 100;
    } else {
      _stressPercentage = 0;
    }
  }

  void _updateIncome(double newIncome) async {
    setState(() {
      _monthlyIncome = newIncome;
      _calculateStress();
    });
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('monthlyIncome', newIncome);
  }

  void _updateFamily(int newCount) async {
    setState(() {
      _familyMembers = newCount;
    });
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('familyMembers', newCount);
  }

  void _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _isDarkMode = prefs.getBool('isDarkMode') ?? false;
      _notificationsEnabled = prefs.getBool('notificationsEnabled') ?? true;
      _monthlyIncome = prefs.getDouble('monthlyIncome') ?? 25000;
      _familyMembers = prefs.getInt('familyMembers') ?? 4;
    });
    _calculateStress();
  }

  void _toggleDarkMode(bool value) async {
    setState(() => _isDarkMode = value);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkMode', value);
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => DashboardScreen(userName: widget.userName)),
    );
  }

  void _toggleNotifications(bool value) async {
    setState(() => _notificationsEnabled = value);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notificationsEnabled', value);
  }

  void _logout() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () async {
              final prefs = await SharedPreferences.getInstance();
              await prefs.clear();
              Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
            },
            child: const Text('Logout', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Energy Tracker Pro'),
        actions: [
          // Dark mode toggle only - profile settings removed
          IconButton(
            icon: Icon(_isDarkMode ? Icons.dark_mode : Icons.light_mode),
            onPressed: () => _toggleDarkMode(!_isDarkMode),
          ),
          IconButton(
            icon: Icon(_notificationsEnabled ? Icons.notifications_active : Icons.notifications_off),
            onPressed: () => _toggleNotifications(!_notificationsEnabled),
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout,
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(color: Colors.green),
              child: Column(
                children: [
                  const CircleAvatar(
                    radius: 30,
                    backgroundColor: Colors.white,
                    child: Icon(Icons.person, size: 40, color: Colors.green),
                  ),
                  const SizedBox(height: 10),
                  Text(widget.userName, style: const TextStyle(color: Colors.white, fontSize: 18)),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.dashboard),
              title: const Text('Dashboard'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.input),
              title: const Text('Input Data'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (context) => const InputDataScreen()));
              },
            ),
            ListTile(
              leading: const Icon(Icons.bar_chart),
              title: const Text('Energy Usage'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (context) => const EnergyUsageScreen()));
              },
            ),
            ListTile(
              leading: const Icon(Icons.history),
              title: const Text('Bills History'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (context) => const BillsHistoryScreen()));
              },
            ),
            ListTile(
              leading: const Icon(Icons.notifications),
              title: const Text('Alerts'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (context) => const AlertsScreen()));
              },
            ),
            ListTile(
              leading: const Icon(Icons.lightbulb),
              title: const Text('Recommendations'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (context) => const RecommendationsScreen()));
              },
            ),
            ListTile(
              leading: const Icon(Icons.picture_as_pdf),
              title: const Text('Reports'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (context) => const ReportsScreen()));
              },
            ),
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text('Profile'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ProfileScreen(
                      onDarkModeToggle: _toggleDarkMode,
                      onNotificationToggle: _toggleNotifications,
                      isDarkMode: _isDarkMode,
                      notificationsEnabled: _notificationsEnabled,
                    ),
                  ),
                );
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text('Logout'),
              onTap: _logout,
            ),
          ],
        ),
      ),
      body: DashboardContent(
        userName: widget.userName,
        monthlyIncome: _monthlyIncome,
        energyCost: _energyCost,
        unitsConsumed: _unitsConsumed,
        familyMembers: _familyMembers,
        stressPercentage: _stressPercentage,
        onIncomeUpdate: _updateIncome,
        onFamilyUpdate: _updateFamily,
      ),
    );
  }
}

// Dashboard Content Widget
class DashboardContent extends StatefulWidget {
  final String userName;
  final double monthlyIncome;
  final double energyCost;
  final double unitsConsumed;
  final int familyMembers;
  final double stressPercentage;
  final Function(double) onIncomeUpdate;
  final Function(int) onFamilyUpdate;

  const DashboardContent({
    super.key,
    required this.userName,
    required this.monthlyIncome,
    required this.energyCost,
    required this.unitsConsumed,
    required this.familyMembers,
    required this.stressPercentage,
    required this.onIncomeUpdate,
    required this.onFamilyUpdate,
  });

  @override
  State<DashboardContent> createState() => _DashboardContentState();
}

class _DashboardContentState extends State<DashboardContent> {
  @override
  Widget build(BuildContext context) {
    // Get stress color and message
    Color stressColor;
    String stressLevel;
    String stressMessage;
    
    if (widget.stressPercentage > 200) {
      stressColor = Colors.red.shade900;
      stressLevel = "Severe Stress";
      stressMessage = "Critical! Apply for energy assistance immediately.";
    } else if (widget.stressPercentage > 100) {
      stressColor = Colors.red;
      stressLevel = "High Stress";
      stressMessage = "Your energy cost exceeds your income! Need immediate action.";
    } else if (widget.stressPercentage > 50) {
      stressColor = Colors.orange;
      stressLevel = "Moderate Stress";
      stressMessage = "Consider reducing energy consumption.";
    } else if (widget.stressPercentage > 22) {
      stressColor = Colors.yellow.shade800;
      stressLevel = "Mild Stress";
      stressMessage = "Stress level above 22%. Monitor your usage.";
    } else {
      stressColor = Colors.green;
      stressLevel = "Low Stress";
      stressMessage = "Good job! Your energy cost is under control.";
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Welcome Card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Colors.green, Colors.greenAccent],
              ),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Hello, ${widget.userName}!',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 5),
                const Text(
                  'Welcome to Energy Tracker Pro',
                  style: TextStyle(color: Colors.white70, fontSize: 14),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 20),
          
          // Stats Grid - 2x2 layout
          Row(
            children: [
              Expanded(child: _buildStatCard('Monthly Income', '₹${widget.monthlyIncome.toStringAsFixed(0)}', 'This Month', Icons.account_balance_wallet, Colors.green, () => _showIncomeDialog())),
              const SizedBox(width: 12),
              Expanded(child: _buildStatCard('Energy Cost', '₹${widget.energyCost.toStringAsFixed(0)}', 'This Month', Icons.electric_bolt, Colors.orange, null)),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: _buildStatCard('Energy Stress', '${widget.stressPercentage.toStringAsFixed(1)}%', stressLevel, Icons.warning, stressColor, null)),
              const SizedBox(width: 12),
              Expanded(child: _buildStatCard('Units Consumed', '${widget.unitsConsumed.toStringAsFixed(0)} kWh', 'This Month', Icons.speed, Colors.blue, null)),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: _buildStatCard('Family Members', '${widget.familyMembers}', 'In Household', Icons.family_restroom, Colors.purple, () => _showFamilyDialog())),
              const SizedBox(width: 12),
              Expanded(child: _buildEmptyCard()),
            ],
          ),
          
          const SizedBox(height: 24),
          
          // Energy Stress Meter
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
              boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, 5))],
            ),
            child: Column(
              children: [
                const Text(
                  'Energy Stress Meter',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 15),
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: LinearProgressIndicator(
                    value: (widget.stressPercentage / 300).clamp(0.0, 1.0),
                    minHeight: 20,
                    backgroundColor: Colors.grey.shade300,
                    color: stressColor,
                  ),
                ),
                const SizedBox(height: 15),
                Text(
                  '${widget.stressPercentage.toStringAsFixed(1)}%',
                  style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: stressColor),
                ),
                Text(
                  stressLevel,
                  style: TextStyle(fontSize: 16, color: stressColor, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 10),
                Text(
                  stressMessage,
                  style: const TextStyle(fontSize: 14, color: Colors.grey),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, String subtitle, IconData icon, Color color, VoidCallback? onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 5, offset: Offset(0, 2))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 20, color: color),
                const Spacer(),
                if (onTap != null)
                  const Icon(Icons.edit, size: 16, color: Colors.grey),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color),
            ),
            Text(title, style: const TextStyle(fontSize: 12, color: Colors.grey)),
            Text(subtitle, style: const TextStyle(fontSize: 10, color: Colors.grey)),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyCard() {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 5, offset: Offset(0, 2))],
      ),
      child: const SizedBox.shrink(),
    );
  }

  void _showIncomeDialog() {
    final TextEditingController controller = TextEditingController(text: widget.monthlyIncome.toString());
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Update Monthly Income'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: 'Monthly Income (₹)',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              double newIncome = double.tryParse(controller.text) ?? widget.monthlyIncome;
              widget.onIncomeUpdate(newIncome);
              Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showFamilyDialog() {
    final TextEditingController controller = TextEditingController(text: widget.familyMembers.toString());
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Update Family Members'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: 'Number of Family Members',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              int newCount = int.tryParse(controller.text) ?? widget.familyMembers;
              widget.onFamilyUpdate(newCount);
              Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}