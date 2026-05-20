import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  List<Map<String, dynamic>> _history = [];

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    final prefs = await SharedPreferences.getInstance();
    List<String>? saved = prefs.getStringList('history');
    if (saved != null) {
      setState(() {
        _history = saved.map((e) {
          List<String> parts = e.split(',');
          return {'date': parts[0], 'income': parts[1], 'units': parts[2], 'stress': parts[3]};
        }).toList();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_history.isEmpty) {
      return const Center(child: Text('No history yet. Save data in Input page.'));
    }
    return ListView.builder(
      itemCount: _history.length,
      itemBuilder: (_, i) => Card(
        margin: const EdgeInsets.all(8),
        child: ListTile(
          title: Text(_history[i]['date']),
          subtitle: Text('Income: ₹${_history[i]['income']} | Units: ${_history[i]['units']}'),
          trailing: Text('${_history[i]['stress']}%', style: TextStyle(color: double.parse(_history[i]['stress']) > 22 ? Colors.red : Colors.green)),
        ),
      ),
    );
  }
}