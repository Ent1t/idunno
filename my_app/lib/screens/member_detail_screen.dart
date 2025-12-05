import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/member.dart';
import '../models/payment.dart';
import '../providers/loan_provider.dart';
import 'add_member_dialog.dart';

class MemberDetailScreen extends StatelessWidget {
  final Member member;

  const MemberDetailScreen({super.key, required this.member});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(member.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AddMemberDialog(member: member),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () => _deleteMember(context),
          ),
        ],
      ),
      body: Consumer<LoanProvider>(
        builder: (context, provider, child) {
          final payments = provider.payments
              .where((p) => p.memberId == member.id)
              .toList();

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildInfoCard(context),
                const SizedBox(height: 16),
                _buildProgressCard(context),
                const SizedBox(height: 16),
                _buildPaymentHistory(context, payments),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _recordPayment(context),
        icon: const Icon(Icons.payment),
        label: const Text('Record Payment'),
      ),
    );
  }

  Widget _buildInfoCard(BuildContext context) {
    final currencyFormat = NumberFormat.currency(symbol: '₱');

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Loan Information',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const Divider(),
            _buildInfoRow('Contact', member.contact),
            _buildInfoRow('Principal', currencyFormat.format(member.principalAmount)),
            _buildInfoRow('Total Payout', currencyFormat.format(member.totalPayoutAmount)),
            _buildInfoRow('Monthly Payment', currencyFormat.format(member.monthlyPayment)),
            _buildInfoRow('Payment Day', 'Day ${member.paymentDay}'),
            _buildInfoRow('Loan Term', '${member.loanTermMonths} months'),
            _buildInfoRow('Start Date', DateFormat('MMM dd, yyyy').format(member.startDate)),
            _buildInfoRow('Expected End', DateFormat('MMM dd, yyyy').format(member.expectedCompletionDate)),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressCard(BuildContext context) {
    final currencyFormat = NumberFormat.currency(symbol: '₱');
    final progress = member.totalPaid / member.totalPayoutAmount;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Payment Progress',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            LinearProgressIndicator(
              value: progress,
              minHeight: 10,
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Paid',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    Text(
                      currencyFormat.format(member.totalPaid),
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: Colors.green,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'Remaining',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    Text(
                      currencyFormat.format(member.remainingBalance),
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: Colors.orange,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              '${member.monthsPaid} of ${member.loanTermMonths} payments completed',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentHistory(BuildContext context, List<Payment> payments) {
    final currencyFormat = NumberFormat.currency(symbol: '₱');

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Payment History',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const Divider(),
            if (payments.isEmpty)
              const Padding(
                padding: EdgeInsets.all(16),
                child: Center(child: Text('No payments recorded yet')),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: payments.length,
                itemBuilder: (context, index) {
                  final payment = payments[index];
                  return ListTile(
                    leading: const CircleAvatar(
                      child: Icon(Icons.payment),
                    ),
                    title: Text(currencyFormat.format(payment.amount)),
                    subtitle: Text(
                      DateFormat('MMM dd, yyyy').format(payment.paymentDate),
                    ),
                    trailing: payment.notes != null
                        ? IconButton(
                            icon: const Icon(Icons.note),
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: const Text('Payment Notes'),
                                  content: Text(payment.notes!),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(context),
                                      child: const Text('Close'),
                                    ),
                                  ],
                                ),
                              );
                            },
                          )
                        : null,
                  );
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  void _recordPayment(BuildContext context) {
    final amountController = TextEditingController(
      text: member.monthlyPayment.toStringAsFixed(2),
    );
    final notesController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Record Payment'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: amountController,
              decoration: const InputDecoration(
                labelText: 'Amount',
                prefixText: '₱ ',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: notesController,
              decoration: const InputDecoration(
                labelText: 'Notes (optional)',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final amount = double.tryParse(amountController.text);
              if (amount != null && amount > 0) {
                final payment = Payment(
                  memberId: member.id!,
                  amount: amount,
                  paymentDate: DateTime.now(),
                  notes: notesController.text.isEmpty ? null : notesController.text,
                );

                Provider.of<LoanProvider>(context, listen: false)
                    .recordPayment(payment);
                Navigator.pop(context);
              }
            },
            child: const Text('Record'),
          ),
        ],
      ),
    );
  }

  void _deleteMember(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Member'),
        content: Text('Are you sure you want to delete ${member.name}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              Provider.of<LoanProvider>(context, listen: false)
                  .deleteMember(member.id!);
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}