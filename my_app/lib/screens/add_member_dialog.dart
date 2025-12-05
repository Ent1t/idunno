import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/member.dart';
import '../providers/loan_provider.dart';

class AddMemberDialog extends StatefulWidget {
  final Member? member;

  const AddMemberDialog({super.key, this.member});

  @override
  State<AddMemberDialog> createState() => _AddMemberDialogState();
}

class _AddMemberDialogState extends State<AddMemberDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _contactController;
  late TextEditingController _principalController;
  late TextEditingController _interestController;
  late TextEditingController _termController;
  int _paymentDay = 1;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.member?.name ?? '');
    _contactController = TextEditingController(text: widget.member?.contact ?? '');
    _principalController = TextEditingController(
      text: widget.member?.principalAmount.toString() ?? '',
    );
    _interestController = TextEditingController(text: '10'); // Default 10% interest
    _termController = TextEditingController(
      text: widget.member?.loanTermMonths.toString() ?? '12',
    );
    _paymentDay = widget.member?.paymentDay ?? 1;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _contactController.dispose();
    _principalController.dispose();
    _interestController.dispose();
    _termController.dispose();
    super.dispose();
  }

  double _calculateTotalPayout() {
    final principal = double.tryParse(_principalController.text) ?? 0;
    final interestRate = double.tryParse(_interestController.text) ?? 0;
    return principal * (1 + (interestRate / 100));
  }

  double _calculateMonthlyPayment() {
    final totalPayout = _calculateTotalPayout();
    final term = int.tryParse(_termController.text) ?? 1;
    return totalPayout / term;
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 600),
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  widget.member == null ? 'Add New Member' : 'Edit Member',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 24),
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Name',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _contactController,
                  decoration: const InputDecoration(
                    labelText: 'Contact',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter contact information';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _principalController,
                  decoration: const InputDecoration(
                    labelText: 'Principal Amount',
                    prefixText: '₱ ',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter the principal amount';
                    }
                    if (double.tryParse(value) == null) {
                      return 'Please enter a valid number';
                    }
                    return null;
                  },
                  onChanged: (value) => setState(() {}),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _interestController,
                  decoration: const InputDecoration(
                    labelText: 'Interest Rate (%)',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter the interest rate';
                    }
                    if (double.tryParse(value) == null) {
                      return 'Please enter a valid number';
                    }
                    return null;
                  },
                  onChanged: (value) => setState(() {}),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _termController,
                  decoration: const InputDecoration(
                    labelText: 'Loan Term (months)',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter the loan term';
                    }
                    if (int.tryParse(value) == null) {
                      return 'Please enter a valid number';
                    }
                    return null;
                  },
                  onChanged: (value) => setState(() {}),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<int>(
                  value: _paymentDay,
                  decoration: const InputDecoration(
                    labelText: 'Payment Day of Month',
                    border: OutlineInputBorder(),
                  ),
                  items: List.generate(28, (index) => index + 1)
                      .map((day) => DropdownMenuItem(
                            value: day,
                            child: Text('Day $day'),
                          ))
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      _paymentDay = value ?? 1;
                    });
                  },
                ),
                const SizedBox(height: 24),
                Card(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Loan Summary',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const Divider(),
                        _buildSummaryRow('Total Payout', _calculateTotalPayout()),
                        _buildSummaryRow('Monthly Payment', _calculateMonthlyPayment()),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: _saveMember,
                      child: const Text('Save'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryRow(String label, double amount) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(
            '₱${amount.toStringAsFixed(2)}',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  void _saveMember() {
    if (_formKey.currentState!.validate()) {
      final principal = double.parse(_principalController.text);
      final totalPayout = _calculateTotalPayout();
      final monthlyPayment = _calculateMonthlyPayment();
      final term = int.parse(_termController.text);

      final member = Member(
        id: widget.member?.id,
        name: _nameController.text,
        contact: _contactController.text,
        principalAmount: principal,
        monthlyPayment: monthlyPayment,
        paymentDay: _paymentDay,
        loanTermMonths: term,
        totalPayoutAmount: totalPayout,
        startDate: widget.member?.startDate ?? DateTime.now(),
        totalPaid: widget.member?.totalPaid ?? 0,
      );

      final provider = Provider.of<LoanProvider>(context, listen: false);
      if (widget.member == null) {
        provider.addMember(member);
      } else {
        provider.updateMember(member);
      }

      Navigator.pop(context);
    }
  }
}