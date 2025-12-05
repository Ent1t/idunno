class Member {
  final int? id;
  final String name;
  final String contact;
  final String? photoPath;
  final double principalAmount;
  final double monthlyPayment;
  final int paymentDay;
  final int loanTermMonths;
  final double totalPayoutAmount;
  final DateTime startDate;
  final String status;
  final double totalPaid;

  Member({
    this.id,
    required this.name,
    required this.contact,
    this.photoPath,
    required this.principalAmount,
    required this.monthlyPayment,
    required this.paymentDay,
    required this.loanTermMonths,
    required this.totalPayoutAmount,
    required this.startDate,
    this.status = 'Active',
    this.totalPaid = 0.0,
  });

  double get remainingBalance => totalPayoutAmount - totalPaid;
  double get profitAmount => totalPayoutAmount - principalAmount;
  int get monthsPaid => (totalPaid / monthlyPayment).floor();
  int get monthsRemaining => loanTermMonths - monthsPaid;
  
  DateTime get expectedCompletionDate {
    return DateTime(
      startDate.year,
      startDate.month + loanTermMonths,
      paymentDay,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'contact': contact,
      'photoPath': photoPath,
      'principalAmount': principalAmount,
      'monthlyPayment': monthlyPayment,
      'paymentDay': paymentDay,
      'loanTermMonths': loanTermMonths,
      'totalPayoutAmount': totalPayoutAmount,
      'startDate': startDate.toIso8601String(),
      'status': status,
      'totalPaid': totalPaid,
    };
  }

  factory Member.fromMap(Map<String, dynamic> map) {
    return Member(
      id: map['id'],
      name: map['name'],
      contact: map['contact'],
      photoPath: map['photoPath'],
      principalAmount: map['principalAmount'],
      monthlyPayment: map['monthlyPayment'],
      paymentDay: map['paymentDay'],
      loanTermMonths: map['loanTermMonths'],
      totalPayoutAmount: map['totalPayoutAmount'],
      startDate: DateTime.parse(map['startDate']),
      status: map['status'],
      totalPaid: map['totalPaid'],
    );
  }

  Member copyWith({
    int? id,
    String? name,
    String? contact,
    String? photoPath,
    double? principalAmount,
    double? monthlyPayment,
    int? paymentDay,
    int? loanTermMonths,
    double? totalPayoutAmount,
    DateTime? startDate,
    String? status,
    double? totalPaid,
  }) {
    return Member(
      id: id ?? this.id,
      name: name ?? this.name,
      contact: contact ?? this.contact,
      photoPath: photoPath ?? this.photoPath,
      principalAmount: principalAmount ?? this.principalAmount,
      monthlyPayment: monthlyPayment ?? this.monthlyPayment,
      paymentDay: paymentDay ?? this.paymentDay,
      loanTermMonths: loanTermMonths ?? this.loanTermMonths,
      totalPayoutAmount: totalPayoutAmount ?? this.totalPayoutAmount,
      startDate: startDate ?? this.startDate,
      status: status ?? this.status,
      totalPaid: totalPaid ?? this.totalPaid,
    );
  }
}