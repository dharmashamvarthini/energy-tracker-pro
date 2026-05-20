import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:fl_chart/fl_chart.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Energy Tracker Pro',
      theme: ThemeData(
        brightness: Brightness.light,
        primaryColor: const Color(0xFF1A5F7A),
        scaffoldBackgroundColor: Colors.grey.shade50,
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: const Color(0xFF0D3B4F),
        scaffoldBackgroundColor: const Color(0xFF121212),
        useMaterial3: true,
      ),
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return const SplashScreen();
          } else {
            return const LoginScreen();
          }
        },
      ),
      debugShowCheckedModeBanner: false,
    );
  }
}

// ==================== SPLASH SCREEN (FLASH LOGO) ====================
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 2), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const MainDashboard()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF1A5F7A), Color(0xFF0D3B4F)],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TweenAnimationBuilder(
                tween: Tween<double>(begin: 0.5, end: 1.0),
                duration: const Duration(seconds: 2),
                builder: (context, double scale, child) {
                  return Transform.scale(
                    scale: scale,
                    child: Container(
                      width: 150,
                      height: 150,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(30),
                        boxShadow: const [
                          BoxShadow(color: Colors.black26, blurRadius: 20, offset: Offset(0, 10)),
                        ],
                      ),
                      child: const Icon(Icons.energy_savings_leaf, size: 80, color: Color(0xFF1A5F7A)),
                    ),
                  );
                },
              ),
              const SizedBox(height: 30),
              const Text(
                'Energy Tracker Pro',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white),
              ),
              const SizedBox(height: 10),
              const Text(
                'Monitor Your Electricity Stress',
                style: TextStyle(fontSize: 16, color: Colors.white70),
              ),
              const SizedBox(height: 50),
              const CircularProgressIndicator(color: Colors.white),
            ],
          ),
        ),
      ),
    );
  }
}

// ==================== LOGIN SCREEN ====================
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _email = TextEditingController();
  final TextEditingController _password = TextEditingController();
  bool _isLoading = false;
  String _error = '';
  bool _isLogin = true;

  Future<void> _submit() async {
    setState(() {
      _error = '';
      _isLoading = true;
    });

    try {
      if (_isLogin) {
        await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: _email.text.trim(),
          password: _password.text.trim(),
        );
      } else {
        await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: _email.text.trim(),
          password: _password.text.trim(),
        );
      }
    } on FirebaseAuthException catch (e) {
      setState(() {
        _error = e.message ?? 'Authentication failed';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [const Color(0xFF1A5F7A), const Color(0xFF0D3B4F)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Card(
              elevation: 20,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.energy_savings_leaf, size: 70, color: Color(0xFF1A5F7A)),
                    const SizedBox(height: 16),
                    const Text('Energy Tracker Pro', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 32),
                    TextField(
                      controller: _email,
                      decoration: InputDecoration(
                        labelText: 'Email',
                        prefixIcon: const Icon(Icons.email),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _password,
                      obscureText: true,
                      decoration: InputDecoration(
                        labelText: 'Password',
                        prefixIcon: const Icon(Icons.lock),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                    if (_error.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      Text(_error, style: const TextStyle(color: Colors.red)),
                    ],
                    const SizedBox(height: 24),
                    if (_isLoading)
                      const CircularProgressIndicator()
                    else
                      ElevatedButton(
                        onPressed: _submit,
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size(double.infinity, 50),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: Text(_isLogin ? 'Sign In' : 'Create Account'),
                      ),
                    TextButton(
                      onPressed: () => setState(() => _isLogin = !_isLogin),
                      child: Text(_isLogin ? 'Create new account' : 'Already have an account? Sign In'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ==================== MAIN DASHBOARD ====================
class MainDashboard extends StatefulWidget {
  const MainDashboard({super.key});

  @override
  State<MainDashboard> createState() => _MainDashboardState();
}

class _MainDashboardState extends State<MainDashboard> {
  int _selectedIndex = 0;
  
  final TextEditingController _incomeController = TextEditingController(text: '25000');
  final TextEditingController _unitsController = TextEditingController(text: '350');
  final TextEditingController _tariffController = TextEditingController(text: '10');
  final TextEditingController _fixedController = TextEditingController(text: '0');
  final TextEditingController _membersController = TextEditingController(text: '4');
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _meterController = TextEditingController();
  final TextEditingController _mobileController = TextEditingController();
  final TextEditingController _alertLimitController = TextEditingController(text: '500');

  double _energyCost = 0;
  double _stressPercent = 0;
  double _remainingIncome = 0;
  String _stressLevel = '';
  String _advice = '';
  Color _stressColor = Colors.green;
  String _profileImagePath = '';
  bool _isDarkMode = false;
  bool _notificationsEnabled = true;
  double _alertLimit = 500;
  List<String> _activeAlerts = [];
  String _userName = 'User';
  String _userEmail = '';
  bool _notificationSent = false;
  
  // Bill History List
  List<Map<String, dynamic>> _billHistory = [];

  final List<String> _months = ['Dec 2024', 'Jan 2025', 'Feb 2025', 'Mar 2025', 'Apr 2025', 'May 2025'];
  final List<double> _usageData = [280, 320, 310, 400, 370, 350];
  final List<double> _costData = [2800, 3200, 3100, 4000, 3700, 3500];

  final Map<String, double> _deviceUsage = {
    'AC': 120, 'TV': 50, 'Fan': 40, 'Fridge': 80, 'Lights': 30, 'Others': 30,
  };

  @override
  void initState() {
    super.initState();
    _loadData();
    _loadBillHistory();
    _userEmail = FirebaseAuth.instance.currentUser?.email ?? 'user@energy.com';
  }

  // Load Bill History from SharedPreferences
  Future<void> _loadBillHistory() async {
    final prefs = await SharedPreferences.getInstance();
    List<String>? historyList = prefs.getStringList('billHistory');
    if (historyList != null) {
      setState(() {
        _billHistory = historyList.map((item) {
          List<String> parts = item.split('|');
          return {
            'date': parts[0],
            'amount': double.parse(parts[1]),
            'units': double.parse(parts[2]),
            'stress': double.parse(parts[3]),
          };
        }).toList();
      });
    }
  }

  // Save Current Bill to History
  Future<void> _saveCurrentBill() async {
    String now = DateTime.now().toString().substring(0, 10);
    Map<String, dynamic> newBill = {
      'date': now,
      'amount': _energyCost,
      'units': _unitsConsumed,
      'stress': _stressPercent,
    };
    
    setState(() {
      _billHistory.insert(0, newBill);
    });
    
    final prefs = await SharedPreferences.getInstance();
    List<String> historyList = _billHistory.map((bill) {
      return '${bill['date']}|${bill['amount']}|${bill['units']}|${bill['stress']}';
    }).toList();
    await prefs.setStringList('billHistory', historyList);
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('✅ Bill saved to history!')),
    );
  }

  // Delete Bill from History
  Future<void> _deleteBill(int index) async {
    setState(() {
      _billHistory.removeAt(index);
    });
    
    final prefs = await SharedPreferences.getInstance();
    List<String> historyList = _billHistory.map((bill) {
      return '${bill['date']}|${bill['amount']}|${bill['units']}|${bill['stress']}';
    }).toList();
    await prefs.setStringList('billHistory', historyList);
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('🗑️ Bill deleted from history!')),
    );
  }

  double get _unitsConsumed => double.tryParse(_unitsController.text) ?? 0;

  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _incomeController.text = prefs.getString('income') ?? '25000';
      _unitsController.text = prefs.getString('units') ?? '350';
      _tariffController.text = prefs.getString('tariff') ?? '10';
      _fixedController.text = prefs.getString('fixed') ?? '0';
      _membersController.text = prefs.getString('members') ?? '4';
      _nameController.text = prefs.getString('userName') ?? '';
      _meterController.text = prefs.getString('meterNumber') ?? '';
      _mobileController.text = prefs.getString('mobile') ?? '';
      _isDarkMode = prefs.getBool('darkMode') ?? false;
      _notificationsEnabled = prefs.getBool('notificationsEnabled') ?? true;
      _profileImagePath = prefs.getString('profileImage') ?? '';
      _alertLimit = prefs.getDouble('alertLimit') ?? 500;
      _alertLimitController.text = _alertLimit.toString();
      _userName = prefs.getString('userName') ?? 'User';
    });
    _calculate();
  }

  Future<void> _saveData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('income', _incomeController.text);
    await prefs.setString('units', _unitsController.text);
    await prefs.setString('tariff', _tariffController.text);
    await prefs.setString('fixed', _fixedController.text);
    await prefs.setString('members', _membersController.text);
    await prefs.setString('userName', _nameController.text);
    await prefs.setString('meterNumber', _meterController.text);
    await prefs.setString('mobile', _mobileController.text);
    await prefs.setBool('darkMode', _isDarkMode);
    await prefs.setBool('notificationsEnabled', _notificationsEnabled);
    await prefs.setDouble('alertLimit', _alertLimit);
    setState(() {
      _userName = _nameController.text.isEmpty ? 'User' : _nameController.text;
    });
  }

  void _calculate() {
    double income = double.tryParse(_incomeController.text) ?? 0;
    double units = double.tryParse(_unitsController.text) ?? 0;
    double tariff = double.tryParse(_tariffController.text) ?? 10;
    double fixed = double.tryParse(_fixedController.text) ?? 0;

    _energyCost = (units * tariff) + fixed;
    _stressPercent = income > 0 ? (_energyCost / income) * 100 : 0;
    _remainingIncome = income - _energyCost;
    if (_remainingIncome < 0) _remainingIncome = 0;

    if (_stressPercent < 5) {
      _stressLevel = 'Low Stress';
      _advice = 'Great job! Your energy cost is very affordable.';
      _stressColor = Colors.green;
    } else if (_stressPercent < 12) {
      _stressLevel = 'Moderate Stress';
      _advice = 'Manageable. Try to reduce usage by 10%.';
      _stressColor = Colors.orange;
    } else if (_stressPercent < 22) {
      _stressLevel = 'High Stress';
      _advice = 'More than 10% of income is spent on energy.';
      _stressColor = Colors.deepOrange;
    } else {
      _stressLevel = 'Severe Stress';
      _advice = 'Critical! Apply for energy assistance immediately.';
      _stressColor = Colors.red;
    }

    _checkAlerts();
    _saveData();
    setState(() {});
  }

  void _checkAlerts() {
    _activeAlerts.clear();
    double units = double.tryParse(_unitsController.text) ?? 0;
    if (_stressPercent > 10) {
      _activeAlerts.add('⚠️ High energy stress! Your energy cost is more than 10% of income.');
    }
    if (units > _alertLimit) {
      _activeAlerts.add('⚠️ Energy usage exceeds limit! Current: ${units.toStringAsFixed(0)} kWh, Limit: ${_alertLimit.toStringAsFixed(0)} kWh');
    }
    if (_activeAlerts.isEmpty) {
      _activeAlerts.add('✅ No active alerts. Good job!');
    }
  }

  void _saveAlertLimit() async {
    double newLimit = double.tryParse(_alertLimitController.text) ?? 500;
    setState(() => _alertLimit = newLimit);
    await _saveData();
    _checkAlerts();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Alert limit set to ${_alertLimit.toStringAsFixed(0)} kWh')),
    );
  }

  void _toggleDarkMode() async {
    setState(() => _isDarkMode = !_isDarkMode);
    await _saveData();
  }

  void _toggleNotifications() async {
    setState(() => _notificationsEnabled = !_notificationsEnabled);
    await _saveData();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(_notificationsEnabled ? '🔔 Notifications ON' : '🔕 Notifications OFF')),
    );
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      final prefs = await SharedPreferences.getInstance();
      setState(() => _profileImagePath = picked.path);
      await prefs.setString('profileImage', picked.path);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile photo updated!')),
      );
    }
  }

  void _saveProfile() {
    _saveData();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Profile saved successfully!')),
    );
  }

  void _logout() {
    FirebaseAuth.instance.signOut();
  }

  List<Widget> get _pages => [
    _buildDashboard(),
    _buildInputDataPage(),
    _buildEnergyUsagePage(),
    _buildBillsHistoryPage(),  // History Page
    _buildAlertsPage(),
    _buildRecommendationsPage(),
    _buildReportsPage(),
    _buildProfilePage(),
    _buildSettingsPage(),
  ];

  List<String> get _pageTitles => [
    'Dashboard', 'Input Data', 'Energy Usage', 'Bills History',
    'Alerts', 'Recommendations', 'Reports', 'Profile', 'Settings'
  ];

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: _isDarkMode ? ThemeData.dark(useMaterial3: true) : ThemeData.light(useMaterial3: true),
      child: Scaffold(
        appBar: AppBar(
          title: Text(_pageTitles[_selectedIndex]),
          backgroundColor: const Color(0xFF1A5F7A),
          foregroundColor: Colors.white,
          actions: [
            IconButton(icon: Icon(_isDarkMode ? Icons.light_mode : Icons.dark_mode), onPressed: _toggleDarkMode),
            IconButton(icon: const Icon(Icons.logout), onPressed: _logout),
          ],
        ),
        drawer: _buildDrawer(),
        body: _pages[_selectedIndex],
      ),
    );
  }

  Widget _buildDrawer() {
    return Drawer(
      child: Container(
        color: const Color(0xFF1A5F7A),
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(color: Color(0xFF0D3B4F)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  GestureDetector(
                    onTap: _pickImage,
                    child: CircleAvatar(
                      radius: 35,
                      backgroundImage: _profileImagePath.isNotEmpty ? FileImage(File(_profileImagePath)) : null,
                      child: _profileImagePath.isEmpty ? const Icon(Icons.person, size: 35, color: Colors.white) : null,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(_userName, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                  Text(_userEmail, style: const TextStyle(color: Colors.white70, fontSize: 12)),
                ],
              ),
            ),
            _drawerMenuItem(Icons.dashboard, 'Dashboard', 0),
            _drawerMenuItem(Icons.edit_note, 'Input Data', 1),
            _drawerMenuItem(Icons.energy_savings_leaf, 'Energy Usage', 2),
            _drawerMenuItem(Icons.history, 'Bills History', 3),
            _drawerMenuItem(Icons.warning, 'Alerts', 4),
            _drawerMenuItem(Icons.lightbulb, 'Recommendations', 5),
            _drawerMenuItem(Icons.assessment, 'Reports', 6),
            _drawerMenuItem(Icons.person, 'Profile', 7),
            _drawerMenuItem(Icons.settings, 'Settings', 8),
            const Divider(color: Colors.white24),
            _drawerMenuItem(Icons.logout, 'Logout', -1, isLogout: true),
          ],
        ),
      ),
    );
  }

  Widget _drawerMenuItem(IconData icon, String title, int index, {bool isLogout = false}) {
    return ListTile(
      leading: Icon(icon, color: Colors.white),
      title: Text(title, style: const TextStyle(color: Colors.white)),
      onTap: () {
        Navigator.pop(context);
        if (isLogout) {
          _logout();
        } else {
          setState(() => _selectedIndex = index);
        }
      },
    );
  }

  // ==================== BILLS HISTORY PAGE ====================
  Widget _buildBillsHistoryPage() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: ElevatedButton.icon(
            onPressed: _saveCurrentBill,
            icon: const Icon(Icons.save),
            label: const Text('Save Current Bill to History'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              minimumSize: const Size(double.infinity, 50),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ),
        Expanded(
          child: _billHistory.isEmpty
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.history, size: 80, color: Colors.grey),
                      SizedBox(height: 16),
                      Text('No Bill History', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      SizedBox(height: 8),
                      Text('Save your first bill!', style: TextStyle(color: Colors.grey)),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _billHistory.length,
                  itemBuilder: (_, i) {
                    final bill = _billHistory[i];
                    Color stressColor = (bill['stress'] as double) > 22 ? Colors.red : Colors.green;
                    return Dismissible(
                      key: Key(bill['date'].toString()),
                      direction: DismissDirection.endToStart,
                      onDismissed: (_) => _deleteBill(i),
                      background: Container(
                        color: Colors.red,
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(right: 20),
                        child: const Icon(Icons.delete, color: Colors.white),
                      ),
                      child: Card(
                        margin: const EdgeInsets.only(bottom: 10),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: stressColor,
                            child: Text((bill['date'] as String).substring(8, 10), style: const TextStyle(color: Colors.white)),
                          ),
                          title: Text('₹${(bill['amount'] as double).toStringAsFixed(0)} - ${(bill['units'] as double).toStringAsFixed(0)} kWh'),
                          subtitle: Text('Date: ${bill['date']}'),
                          trailing: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                '${(bill['stress'] as double).toStringAsFixed(1)}%',
                                style: TextStyle(color: stressColor, fontWeight: FontWeight.bold),
                              ),
                              const Text('Stress', style: TextStyle(fontSize: 10)),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildSettingsPage() {
    return ListView(
      children: [
        SwitchListTile(
          title: const Text('Dark Mode'),
          subtitle: const Text('Switch between light and dark theme'),
          value: _isDarkMode,
          onChanged: (_) => _toggleDarkMode(),
          secondary: const Icon(Icons.dark_mode),
        ),
        const Divider(),
        SwitchListTile(
          title: const Text('🔔 Notifications'),
          subtitle: Text(_notificationsEnabled ? 'Email alerts when stress > 22%' : 'Email notifications are disabled'),
          value: _notificationsEnabled,
          onChanged: (_) => _toggleNotifications(),
          secondary: Icon(_notificationsEnabled ? Icons.notifications_active : Icons.notifications_off, color: _notificationsEnabled ? Colors.green : Colors.red),
        ),
        const Divider(),
        ListTile(leading: const Icon(Icons.info), title: const Text('App Version'), subtitle: const Text('2.0.0')),
        const Divider(),
        ListTile(leading: const Icon(Icons.email), title: const Text('Alert Email'), subtitle: Text(_userEmail)),
        const Divider(),
        ListTile(leading: const Icon(Icons.help), title: const Text('About'), subtitle: const Text('Energy Tracker Pro - Monitor your energy usage')),
      ],
    );
  }

  Widget _buildDashboard() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [Color(0xFF1A5F7A), Color(0xFF0D3B4F)]),
              borderRadius: BorderRadius.circular(25),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Hello, $_userName!', style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
                const SizedBox(height: 5),
                const Text('Welcome to Energy Tracker Pro', style: TextStyle(color: Colors.white70)),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Row(children: [
            Expanded(child: _statCard('Monthly Income', '₹${_incomeController.text}', Icons.currency_rupee, Colors.green, 'This Month')),
            const SizedBox(width: 12),
            Expanded(child: _statCard('Energy Cost', '₹${_energyCost.toStringAsFixed(0)}', Icons.electric_bolt, Colors.orange, 'This Month')),
          ]),
          const SizedBox(height: 12),
          Row(children: [
            Expanded(child: _statCard('Energy Stress', '${_stressPercent.toStringAsFixed(1)}%', Icons.warning, _stressColor, _stressLevel)),
            const SizedBox(width: 12),
            Expanded(child: _statCard('Units Consumed', '${_unitsController.text} kWh', Icons.flash_on, Colors.blue, 'This Month')),
          ]),
          const SizedBox(height: 12),
          Row(children: [
            Expanded(child: _statCard('Family Members', '${_membersController.text}', Icons.people, Colors.purple, 'In Household')),
            Expanded(child: _statCard('Notifications', _notificationsEnabled ? 'ON' : 'OFF', Icons.notifications, _notificationsEnabled ? Colors.green : Colors.red, 'Stress > 22%')),
          ]),
          const SizedBox(height: 20),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  const Text('📊 Energy Stress Meter', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  LinearProgressIndicator(value: _stressPercent / 100, backgroundColor: Colors.grey.shade300, color: _stressColor, minHeight: 20, borderRadius: BorderRadius.circular(10)),
                  const SizedBox(height: 8),
                  Text('${_stressPercent.toStringAsFixed(1)}%', style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(color: _stressColor.withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
                    child: Text(_stressLevel, style: TextStyle(color: _stressColor, fontWeight: FontWeight.bold)),
                  ),
                  const SizedBox(height: 8),
                  Text(_advice, textAlign: TextAlign.center),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputDataPage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              const Icon(Icons.edit_note, size: 50, color: Color(0xFF1A5F7A)),
              const SizedBox(height: 10),
              const Text('Input Details', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),
              TextField(controller: _incomeController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Monthly Income (₹)', border: OutlineInputBorder(), prefixIcon: Icon(Icons.currency_rupee)), onChanged: (_) => _calculate()),
              const SizedBox(height: 15),
              TextField(controller: _unitsController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Units Consumed (kWh)', border: OutlineInputBorder(), prefixIcon: Icon(Icons.electric_bolt)), onChanged: (_) => _calculate()),
              const SizedBox(height: 15),
              TextField(controller: _tariffController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Tariff per Unit (₹)', border: OutlineInputBorder(), prefixIcon: Icon(Icons.calculate)), onChanged: (_) => _calculate()),
              const SizedBox(height: 15),
              TextField(controller: _fixedController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Fixed Charges (₹)', border: OutlineInputBorder(), prefixIcon: Icon(Icons.note_add)), onChanged: (_) => _calculate()),
              const SizedBox(height: 15),
              TextField(controller: _membersController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Family Members', border: OutlineInputBorder(), prefixIcon: Icon(Icons.people)), onChanged: (_) => _calculate()),
              const SizedBox(height: 25),
              ElevatedButton.icon(onPressed: _calculate, icon: const Icon(Icons.save), label: const Text('Save & Update'), style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 50))),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEnergyUsagePage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  const Text('Device-wise Consumption', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 20),
                  SizedBox(
                    height: 250,
                    child: PieChart(
                      PieChartData(
                        sections: _deviceUsage.entries.map((e) => PieChartSectionData(
                          value: e.value, title: e.key, color: _getPieColor(e.key), radius: 100,
                          titleStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
                        )).toList(),
                        sectionsSpace: 2,
                        centerSpaceRadius: 40,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Wrap(
                    spacing: 12, runSpacing: 8,
                    children: _deviceUsage.entries.map((e) => Chip(
                      label: Text('${e.key}: ${e.value} kWh'),
                      backgroundColor: _getPieColor(e.key).withOpacity(0.2),
                    )).toList(),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  const Text('📈 Monthly Usage Trend', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 20),
                  SizedBox(
                    height: 200,
                    child: BarChart(
                      BarChartData(
                        alignment: BarChartAlignment.spaceAround,
                        maxY: 500,
                        barGroups: _usageData.asMap().entries.map((entry) => BarChartGroupData(
                          x: entry.key,
                          barRods: [BarChartRodData(toY: entry.value, color: const Color(0xFF1A5F7A), width: 30, borderRadius: BorderRadius.circular(6))],
                        )).toList(),
                        titlesData: FlTitlesData(
                          bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, getTitlesWidget: (value, _) => Text(_months[value.toInt()]), reservedSize: 40)),
                          leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 40)),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAlertsPage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Card(
            color: Colors.red.shade50,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(children: [Icon(Icons.warning, color: Colors.red, size: 28), SizedBox(width: 8), Text('Active Alerts', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.red))]),
                  const SizedBox(height: 12),
                  ..._activeAlerts.map((alert) => Padding(padding: const EdgeInsets.only(bottom: 8), child: Text(alert))),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  const Text('Set Usage Alert Limit', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _alertLimitController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(labelText: 'Usage Limit (kWh)', border: OutlineInputBorder(), prefixIcon: const Icon(Icons.speed), suffixText: 'kWh'),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(onPressed: _saveAlertLimit, icon: const Icon(Icons.save), label: const Text('Save Limit'), style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 45))),
                  const SizedBox(height: 8),
                  Text('Current Limit: ${_alertLimit.toStringAsFixed(0)} kWh', style: TextStyle(color: Colors.grey.shade600)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecommendationsPage() {
    final List<Map<String, dynamic>> tips = [
      {'icon': Icons.ac_unit, 'title': 'Reduce AC usage by 1 hour per day', 'saving': 'Save ~30 kWh/month'},
      {'icon': Icons.lightbulb, 'title': 'Use LED bulbs instead of normal bulbs', 'saving': 'Save ~20 kWh/month'},
      {'icon': Icons.power, 'title': 'Unplug devices when not in use', 'saving': 'Save ~15 kWh/month'},
      {'icon': Icons.devices, 'title': 'Consider energy efficient appliances', 'saving': 'Save ~50 kWh/month'},
      {'icon': Icons.thermostat, 'title': 'Set AC temperature to 24°C', 'saving': 'Save ~25 kWh/month'},
      {'icon': Icons.wb_sunny, 'title': 'Use natural light during daytime', 'saving': 'Save ~10 kWh/month'},
    ];
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: tips.length,
      itemBuilder: (_, i) => Card(
        margin: const EdgeInsets.only(bottom: 10),
        child: ListTile(
          leading: Icon(tips[i]['icon'] as IconData, color: Colors.amber),
          title: Text(tips[i]['title'] as String),
          subtitle: Text(tips[i]['saving'] as String, style: const TextStyle(color: Colors.green)),
        ),
      ),
    );
  }

  Widget _buildReportsPage() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.picture_as_pdf, size: 80, color: Colors.red),
            const SizedBox(height: 20),
            const Text('Energy Report', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(15)),
              child: Column(
                children: [
                  _reportRow('User Name', _userName),
                  _reportRow('Monthly Income', '₹${_incomeController.text}'),
                  _reportRow('Units Consumed', '${_unitsController.text} kWh'),
                  _reportRow('Energy Cost', '₹${_energyCost.toStringAsFixed(0)}'),
                  _reportRow('Stress Level', _stressLevel),
                  _reportRow('Stress Percentage', '${_stressPercent.toStringAsFixed(1)}%'),
                ],
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('PDF Report Downloaded!'))),
              icon: const Icon(Icons.download),
              label: const Text('Download PDF Report'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _reportRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(label), Text(value)]),
    );
  }

  Widget _buildProfilePage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          GestureDetector(
            onTap: _pickImage,
            child: CircleAvatar(
              radius: 60,
              backgroundImage: _profileImagePath.isNotEmpty ? FileImage(File(_profileImagePath)) : null,
              child: _profileImagePath.isEmpty ? const Icon(Icons.camera_alt, size: 50, color: Colors.grey) : null,
            ),
          ),
          const SizedBox(height: 10),
          const Text('Tap to change profile photo', style: TextStyle(color: Colors.grey)),
          const SizedBox(height: 20),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  TextField(controller: _nameController, decoration: const InputDecoration(labelText: 'Full Name', border: OutlineInputBorder())),
                  const SizedBox(height: 15),
                  TextField(controller: _meterController, decoration: const InputDecoration(labelText: 'Meter Number', border: OutlineInputBorder())),
                  const SizedBox(height: 15),
                  TextField(controller: _mobileController, keyboardType: TextInputType.phone, decoration: const InputDecoration(labelText: 'Mobile Number', border: OutlineInputBorder())),
                  const SizedBox(height: 25),
                  ElevatedButton.icon(onPressed: _saveProfile, icon: const Icon(Icons.save), label: const Text('Save Profile')),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _statCard(String title, String value, IconData icon, Color color, String subtitle) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 5),
            Text(title, style: const TextStyle(fontSize: 12)),
            Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            Text(subtitle, style: const TextStyle(fontSize: 10, color: Colors.grey)),
          ],
        ),
      ),
    );
  }

  Color _getPieColor(String device) {
    switch (device) {
      case 'AC': return Colors.blue;
      case 'TV': return Colors.green;
      case 'Fan': return Colors.orange;
      case 'Fridge': return Colors.purple;
      case 'Lights': return Colors.amber;
      default: return Colors.grey;
    }
  }
}