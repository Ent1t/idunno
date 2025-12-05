class Payment {
  final int? id;
  final int memberId;
  final double amount;
  final DateTime paymentDate;
  final String? notes;

  Payment({
    this.id,
    required this.memberId,
    required this.amount,
    required this.paymentDate,
    this.notes,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'memberId': memberId,
      'amount': amount,
      'paymentDate': paymentDate.toIso8601String(),
      'notes': notes,
    };
  }

  factory Payment.fromMap(Map<String, dynamic> map) {
    return Payment(
      id: map['id'],
      memberId: map['memberId'],
      amount: map['amount'],
      paymentDate: DateTime.parse(map['paymentDate']),
      notes: map['notes'],
    );
  }
}