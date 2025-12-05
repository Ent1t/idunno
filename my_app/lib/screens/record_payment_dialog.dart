import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/payment.dart';
import '../models/member.dart';
import '../providers/loan_provider.dart';

class RecordPaymentDialog extends StatefulWidget {
  final Member? preselectedMember;

  const RecordPaymentDialog({super.key, this.preselectedMember});

  @override
  State<RecordPaymentDialog> createState() => _RecordPaymentDialogState();
}

class _RecordPaymentDialogState extends State<RecordPaymentDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _amountController;
  late TextEditingController _notesController;
  Member? _selectedMember;
  DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _selectedMember = widget.preselectedMember;
    _amountController = TextEditingController(
      text: widget.preselectedMember?.monthlyPayment.toStringAsFixed(2) ?? '',
    );
    _notesController = TextEditingController();
  }

  @override
  void dispose() {
    _amountController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 500),
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Record Payment',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 24),
                Consumer<LoanProvider>(
                  builder: (context, provider, child) {
                    final activeMembers = provider.activeMembers;

                    if (activeMembers.isEmpty) {
                      return const Text(
                        'No active members available',
                        style: TextStyle(color: Colors.red),
                      );
                    }

                    return DropdownButtonFormField<Member>(
                      value: _selectedMember,
                      decoration: const InputDecoration(
                        labelText: 'Select Member',
                        border: OutlineInputBorder(),
                      ),
                      items: activeMembers.map((member) {
                        return DropdownMenuItem(
                          value: member,
                          child: Text(member.name),
                        );
                      }).toList(),
                      onChanged: (Member? value) {
                        setState(() {
                          _selectedMember = value;
                          if (value != null) {
                            _amountController.text =
                                value.monthlyPayment.toStringAsFixed(2);
                          }
                        });
                      },
                      validator: (value) {
                        if (value == null) {
                          return 'Please select a member';
                        }
                        return null;
                      },
                    );
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _amountController,
                  decoration: const InputDecoration(
                    labelText: 'Amount',
                    prefixText: '₱ ',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter the amount';
                    }
                    if (double.tryParse(value) == null) {
                      return 'Please enter a valid number';
                    }
                    if (double.parse(value) <= 0) {
                      return 'Amount must be greater than 0';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                InkWell(
                  onTap: () async {
                    final DateTime? picked = await showDatePicker(
                      context: context,
                      initialDate: _selectedDate,
                      firstDate: DateTime(2020),
                      lastDate: DateTime.now(),
                    );
                    if (picked != null) {
                      setState(() {
                        _selectedDate = picked;
                      });
                    }
                  },
                  child: InputDecorator(
                    decoration: const InputDecoration(
                      labelText: 'Payment Date',
                      border: OutlineInputBorder(),
                      suffixIcon: Icon(Icons.calendar_today),
                    ),
                    child: Text(
                      DateFormat('MMM dd, yyyy').format(_selectedDate),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _notesController,
                  decoration: const InputDecoration(
                    labelText: 'Notes (optional)',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                ),
                if (_selectedMember != null) ...[
                  const SizedBox(height: 16),
                  Card(
                    color: Theme.of(context).colorScheme.secondaryContainer,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Member Info',
                            style: Theme.of(context).textTheme.titleSmall,
                          ),
                          const Divider(),
                          _buildInfoRow(
                            'Monthly Payment',
                            '₱${_selectedMember!.monthlyPayment.toStringAsFixed(2)}',
                          ),
                          _buildInfoRow(
                            'Remaining Balance',
                            '₱${_selectedMember!.remainingBalance.toStringAsFixed(2)}',
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
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
                      onPressed: _recordPayment,
                      child: const Text('Record Payment'),
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

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  void _recordPayment() {
    if (_formKey.currentState!.validate()) {
      final amount = double.parse(_amountController.text);

      final payment = Payment(
        memberId: _selectedMember!.id!,
        amount: amount,
        paymentDate: _selectedDate,
        notes: _notesController.text.isEmpty ? null : _notesController.text,
      );

      Provider.of<LoanProvider>(context, listen: false).recordPayment(payment);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Payment of ₱${amount.toStringAsFixed(2)} recorded'),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pop(context);
    }
  }
}