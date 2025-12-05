import 'package:flutter/foundation.dart';
import '../models/member.dart';
import '../models/payment.dart';
import '../services/database_service.dart';

class LoanProvider extends ChangeNotifier {
  List<Member> _members = [];
  List<Payment> _payments = [];
  bool _isLoading = false;

  List<Member> get members => _members;
  List<Payment> get payments => _payments;
  bool get isLoading => _isLoading;

  LoanProvider() {
    loadData();
  }

  Future<void> loadData() async {
    _isLoading = true;
    notifyListeners();

    _members = await DatabaseService.instance.getAllMembers();
    _payments = await DatabaseService.instance.getAllPayments();

    _isLoading = false;
    notifyListeners();
  }

  Future<void> addMember(Member member) async {
    await DatabaseService.instance.insertMember(member);
    await loadData();
  }

  Future<void> updateMember(Member member) async {
    await DatabaseService.instance.updateMember(member);
    await loadData();
  }

  Future<void> deleteMember(int id) async {
    await DatabaseService.instance.deleteMember(id);
    await loadData();
  }

  Future<void> recordPayment(Payment payment) async {
    await DatabaseService.instance.insertPayment(payment);
    
    final member = await DatabaseService.instance.getMember(payment.memberId);
    if (member != null) {
      final updatedMember = member.copyWith(
        totalPaid: member.totalPaid + payment.amount,
      );
      await DatabaseService.instance.updateMember(updatedMember);
    }
    
    await loadData();
  }

  List<Member> get activeMembers =>
      _members.where((m) => m.status == 'Active').toList();

  double get totalActiveLoans =>
      activeMembers.fold(0.0, (sum, m) => sum + m.principalAmount);

  double get totalOutstanding =>
      activeMembers.fold(0.0, (sum, m) => sum + m.remainingBalance);

  double get totalProfit =>
      _members.fold(0.0, (sum, m) => sum + (m.totalPaid - m.principalAmount));

  List<Payment> getTodaysPayments() {
    final today = DateTime.now();
    return _payments.where((p) {
      return p.paymentDate.year == today.year &&
          p.paymentDate.month == today.month &&
          p.paymentDate.day == today.day;
    }).toList();
  }

  double getTodaysCollection() {
    return getTodaysPayments().fold(0.0, (sum, p) => sum + p.amount);
  }
}