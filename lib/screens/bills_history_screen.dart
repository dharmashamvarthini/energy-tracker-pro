import 'package:flutter/material.dart';
import '../utils/database_helper.dart';
import '../models/bill_model.dart';

class BillsHistoryScreen extends StatefulWidget {
  const BillsHistoryScreen({super.key});

  @override
  State<BillsHistoryScreen> createState() => _BillsHistoryScreenState();
}

class _BillsHistoryScreenState extends State<BillsHistoryScreen> {
  List<BillModel> _bills = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    _bills = await DatabaseHelper.instance.getAllBills();
    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _deleteBill(int id, int index) async {
    // Show confirmation dialog
    bool? confirm = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Bill'),
        content: const Text('Are you sure you want to delete this bill?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    
    if (confirm == true) {
      await DatabaseHelper.instance.deleteBill(id);
      setState(() {
        _bills.removeAt(index);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Bill deleted successfully')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bills History'),
        backgroundColor: Colors.green,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _bills.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.history, size: 80, color: Colors.grey),
                      const SizedBox(height: 20),
                      const Text(
                        'No Bill History',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Add your first bill in Input Data page',
                        style: TextStyle(color: Colors.grey.shade600),
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton.icon(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        icon: const Icon(Icons.add),
                        label: const Text('Go to Input Data'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _bills.length,
                  itemBuilder: (context, index) {
                    final bill = _bills[index];
                    
                    // Get stress color based on stress level
                    Color stressColor;
                    if (bill.stressLevel > 200) {
                      stressColor = Colors.red.shade900;
                    } else if (bill.stressLevel > 100) {
                      stressColor = Colors.red;
                    } else if (bill.stressLevel > 50) {
                      stressColor = Colors.orange;
                    } else if (bill.stressLevel > 22) {
                      stressColor = Colors.yellow.shade800;
                    } else {
                      stressColor = Colors.green;
                    }
                    
                    String stressLevel;
                    if (bill.stressLevel > 200) {
                      stressLevel = "Severe Stress";
                    } else if (bill.stressLevel > 100) {
                      stressLevel = "High Stress";
                    } else if (bill.stressLevel > 50) {
                      stressLevel = "Moderate Stress";
                    } else if (bill.stressLevel > 22) {
                      stressLevel = "Mild Stress";
                    } else {
                      stressLevel = "Low Stress";
                    }
                    
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 5,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onLongPress: () => _deleteBill(bill.id!, index),
                          borderRadius: BorderRadius.circular(15),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              children: [
                                // Month Circle Avatar
                                Container(
                                  width: 60,
                                  height: 60,
                                  decoration: BoxDecoration(
                                    color: stressColor.withOpacity(0.15),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Center(
                                    child: Text(
                                      bill.month.split('/')[0],
                                      style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: stressColor,
                                      ),
                                    ),
                                  ),
                                ),
                                
                                const SizedBox(width: 15),
                                
                                // Details
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Month: ${bill.month}',
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'Bill Amount: ₹${bill.amount.toStringAsFixed(2)}',
                                        style: const TextStyle(fontSize: 14),
                                      ),
                                      Text(
                                        'Units Consumed: ${bill.units.toStringAsFixed(0)} kWh',
                                        style: const TextStyle(fontSize: 14),
                                      ),
                                      const SizedBox(height: 4),
                                      Row(
                                        children: [
                                          Container(
                                            width: 10,
                                            height: 10,
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              color: stressColor,
                                            ),
                                          ),
                                          const SizedBox(width: 6),
                                          Text(
                                            'Stress: ${bill.stressLevel.toStringAsFixed(1)}% ($stressLevel)',
                                            style: TextStyle(
                                              fontSize: 13,
                                              color: stressColor,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                
                                // Delete icon
                                IconButton(
                                  icon: const Icon(Icons.delete_outline, color: Colors.red),
                                  onPressed: () => _deleteBill(bill.id!, index),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}