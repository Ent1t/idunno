class MembersScreen extends StatelessWidget {
  const MembersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Members'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              // Implement search
            },
          ),
        ],
      ),
      body: Consumer<LoanProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.members.isEmpty) {
            return const Center(
              child: Text('No members yet. Add your first member!'),
            );
          }

          return ListView.builder(
            itemCount: provider.members.length,
            itemBuilder: (context, index) {
              final member = provider.members[index];
              return _MemberListTile(member: member);
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Navigate to add member screen
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _MemberListTile extends StatelessWidget {
  final Member member;

  const _MemberListTile({required this.member});

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(symbol: '₱');
    final progress = member.totalPaid / member.totalPayoutAmount;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: _getStatusColor(member.status),
          child: Text(
            member.name[0],
            style: const TextStyle(color: Colors.white),
          ),
        ),
        title: Text(member.name),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${member.monthsPaid}/${member.loanTermMonths} months'),
            LinearProgressIndicator(value: progress),
            Text(
              'Balance: ${currencyFormat.format(member.remainingBalance)}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        trailing: Chip(
          label: Text(member.status),
          backgroundColor: _getStatusColor(member.status).withOpacity(0.2),
        ),
        onTap: () {
          // Navigate to member detail screen
        },
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Active':
        return Colors.green;
      case 'Completed':
        return Colors.blue;
      case 'Defaulted':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}