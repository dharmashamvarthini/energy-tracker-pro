import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dashboard_page.dart';
import 'input_data_screen.dart';
import 'energy_usage_page.dart';
import 'history_page.dart';
import 'alerts_page.dart';
import 'tips_page.dart';
import 'reports_page.dart';
import 'profile_page.dart';
import 'settings_page.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  bool _isDarkMode = false;

  final List<Widget> _pages = [
    const DashboardPage(),
    const InputDataPage(),
    const EnergyUsagePage(),
    const HistoryPage(),
    const AlertsPage(),
    const TipsPage(),
    const ReportsPage(),
    const ProfilePage(),
    const SettingsPage(),
  ];

  final List<String> _pageTitles = ['Home', 'Input', 'Usage', 'History', 'Alerts', 'Tips', 'Reports', 'Profile', 'Settings'];

  @override
  void initState() {
    super.initState();
    _loadTheme();
  }

  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _isDarkMode = prefs.getBool('darkMode') ?? false;
    });
  }

  void _toggleDarkMode() async {
    setState(() => _isDarkMode = !_isDarkMode);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('darkMode', _isDarkMode);
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: _isDarkMode ? ThemeData.dark() : ThemeData.light(),
      child: Scaffold(
        appBar: AppBar(
          title: Text(_pageTitles[_selectedIndex]),
          backgroundColor: Colors.blue.shade800,
          foregroundColor: Colors.white,
          actions: [
            IconButton(icon: Icon(_isDarkMode ? Icons.light_mode : Icons.dark_mode), onPressed: _toggleDarkMode),
            IconButton(icon: const Icon(Icons.logout), onPressed: () => FirebaseAuth.instance.signOut()),
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
        color: Colors.blue.shade800,
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(color: Colors.blue.shade900),
              child: const Column(
                children: [
                  Icon(Icons.energy_savings_leaf, size: 50, color: Colors.white),
                  SizedBox(height: 10),
                  Text('Energy Tracker Pro', style: TextStyle(color: Colors.white, fontSize: 22)),
                  Text('Monitor Your Usage', style: TextStyle(color: Colors.white70)),
                ],
              ),
            ),
            _drawerItem(Icons.home, 'Home', 0),
            _drawerItem(Icons.edit, 'Input Data', 1),
            _drawerItem(Icons.bar_chart, 'Energy Usage', 2),
            _drawerItem(Icons.history, 'History', 3),
            _drawerItem(Icons.warning, 'Alerts', 4),
            _drawerItem(Icons.lightbulb, 'Tips', 5),
            _drawerItem(Icons.picture_as_pdf, 'Reports', 6),
            _drawerItem(Icons.person, 'Profile', 7),
            _drawerItem(Icons.settings, 'Settings', 8),
            const Divider(),
            _drawerItem(Icons.logout, 'Logout', -1, isLogout: true),
          ],
        ),
      ),
    );
  }

  Widget _drawerItem(IconData icon, String title, int index, {bool isLogout = false}) {
    return ListTile(
      leading: Icon(icon, color: Colors.white),
      title: Text(title, style: const TextStyle(color: Colors.white)),
      onTap: () {
        Navigator.pop(context);
        if (isLogout) FirebaseAuth.instance.signOut();
        else setState(() => _selectedIndex = index);
      },
    );
  }
}