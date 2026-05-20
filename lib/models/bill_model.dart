class BillModel {
  int? id;
  double amount;
  double units;
  String month;
  double stressLevel;
  String date;

  BillModel({
    this.id,
    required this.amount,
    required this.units,
    required this.month,
    required this.stressLevel,
    required this.date,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'amount': amount,
      'units': units,
      'month': month,
      'stressLevel': stressLevel,
      'date': date,
    };
  }

  factory BillModel.fromMap(Map<String, dynamic> map) {
    return BillModel(
      id: map['id'],
      amount: map['amount'],
      units: map['units'],
      month: map['month'],
      stressLevel: map['stressLevel'],
      date: map['date'],
    );
  }
}