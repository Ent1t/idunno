import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/loan_provider.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Loan Manager'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {},
          ),
        ],
      ),
      body: Consumer<LoanProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSummaryCards(provider, context),
                const SizedBox(height: 24),
                _buildQuickActions(context),
                const SizedBox(height: 24),
                _buildRecentActivity(provider, context),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSummaryCards(LoanProvider provider, BuildContext context) {
    final currencyFormat = NumberFormat.currency(symbol: '₱');
    
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 1.5,
      children: [
        _SummaryCard(
          title: 'Total Active Loans',
          value: currencyFormat.format(provider.totalActiveLoans),
          icon: Icons.account_balance_wallet,
          color: Colors.blue,
        ),
        _SummaryCard(
          title: 'Total Members',
          value: provider.activeMembers.length.toString(),
          icon: Icons.people,
          color: Colors.green,
        ),
        _SummaryCard(
          title: 'Today\'s Collection',
          value: currencyFormat.format(provider.getTodaysCollection()),
          icon: Icons.payments,
          color: Colors.orange,
        ),
        _SummaryCard(
          title: 'Outstanding',
          value: currencyFormat.format(provider.totalOutstanding),
          icon: Icons.trending_up,
          color: Colors.red,
        ),
      ],
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Actions',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _ActionButton(
                label: 'Add Member',
                icon: Icons.person_add,
                onPressed: () {},
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _ActionButton(
                label: 'Record Payment',
                icon: Icons.payment,
                onPressed: () {},
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildRecentActivity(LoanProvider provider, BuildContext context) {
    final recentPayments = provider.payments.take(5).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Recent Activity',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 12),
        if (recentPayments.isEmpty)
          const Center(child: Text('No recent activity'))
        else
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: recentPayments.length,
            itemBuilder: (context, index) {
              final payment = recentPayments[index];
              final member = provider.members
                  .firstWhere((m) => m.id == payment.memberId);
              
              return ListTile(
                leading: CircleAvatar(
                  child: Text(member.name[0]),
                ),
                title: Text(member.name),
                subtitle: Text(
                  DateFormat('MMM dd, yyyy').format(payment.paymentDate),
                ),
                trailing: Text(
                  NumberFormat.currency(symbol: '₱').format(payment.amount),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
              );
            },
          ),
      ],
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _SummaryCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Icon(icon, color: color, size: 32),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                Text(
                  title,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onPressed;

  const _ActionButton({
    required this.label,
    required this.icon,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.all(16),
      ),
    );
  }
}
