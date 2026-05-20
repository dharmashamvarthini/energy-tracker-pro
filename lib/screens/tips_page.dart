import 'package:flutter/material.dart';

class TipsPage extends StatelessWidget {
  const TipsPage({super.key});

  final List<String> tips = const [
    '💡 Reduce AC usage by 1 hour - Save ~30 kWh',
    '💡 Use LED bulbs - Save ~20 kWh',
    '💡 Unplug idle devices - Save ~15 kWh',
    '💡 Set AC to 24°C - Save ~25 kWh',
    '💡 Use natural light - Save ~10 kWh',
    '💡 Clean AC filters - Save ~15 kWh',
  ];

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: tips.length,
      itemBuilder: (_, i) => Card(
        margin: const EdgeInsets.all(8),
        child: ListTile(leading: const Icon(Icons.lightbulb, color: Colors.amber), title: Text(tips[i])),
      ),
    );
  }
}