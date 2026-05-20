import 'package:flutter/material.dart';

class RecommendationsScreen extends StatelessWidget {
  const RecommendationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Energy Saving Tips')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildTipCard(
            '💡 Use LED Bulbs',
            'Replace old bulbs with LED to save up to 75% energy.',
            Icons.lightbulb,
            Colors.amber,
          ),
          _buildTipCard(
            '❄️ AC Temperature',
            'Set AC at 24°C to save electricity and still feel comfortable.',
            Icons.ac_unit,
            Colors.blue,
          ),
          _buildTipCard(
            '🔄 Unplug Idle Devices',
            'Even on standby, devices consume power. Unplug when not in use.',
            Icons.power_settings_new,
            Colors.orange,
          ),
          _buildTipCard(
            '📱 5-Star Appliances',
            'Buy 5-star rated appliances for better energy efficiency.',
            Icons.star,
            Colors.green,
          ),
          _buildTipCard(
            '⏰ Peak Hours',
            'Avoid heavy usage during peak hours (6 PM - 9 PM) if you have time-of-day tariff.',
            Icons.timer,
            Colors.purple,
          ),
          _buildTipCard(
            '🌞 Natural Light',
            'Use natural light during daytime instead of artificial lights.',
            Icons.wb_sunny,
            Colors.yellow,
          ),
        ],
      ),
    );
  }

  Widget _buildTipCard(String title, String subtitle, IconData icon, Color color) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withOpacity(0.2),
          child: Icon(icon, color: color),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle),
        contentPadding: const EdgeInsets.all(12),
      ),
    );
  }
}