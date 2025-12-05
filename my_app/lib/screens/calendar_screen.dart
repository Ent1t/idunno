import 'package:table_calendar/table_calendar.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Payment Calendar')),
      body: Consumer<LoanProvider>(
        builder: (context, provider, child) {
          return Column(
            children: [
              TableCalendar(
                firstDay: DateTime.utc(2020, 1, 1),
                lastDay: DateTime.utc(2030, 12, 31),
                focusedDay: _focusedDay,
                selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                onDaySelected: (selectedDay, focusedDay) {
                  setState(() {
                    _selectedDay = selectedDay;
                    _focusedDay = focusedDay;
                  });
                },
                calendarStyle: const CalendarStyle(
                  todayDecoration: BoxDecoration(
                    color: Colors.blue,
                    shape: BoxShape.circle,
                  ),
                  selectedDecoration: BoxDecoration(
                    color: Colors.deepPurple,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
              const Divider(),
              Expanded(
                child: _buildPaymentList(provider),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildPaymentList(LoanProvider provider) {
    if (_selectedDay == null) {
      return const Center(child: Text('Select a date to view payments'));
    }

    final paymentsOnDay = provider.payments.where((p) {
      return isSameDay(p.paymentDate, _selectedDay);
    }).toList();

    if (paymentsOnDay.isEmpty) {
      return const Center(child: Text('No payments on this date'));
    }

    return ListView.builder(
      itemCount: paymentsOnDay.length,
      itemBuilder: (context, index) {
        final payment = paymentsOnDay[index];
        final member = provider.members
            .firstWhere((m) => m.id == payment.memberId);
        
        return ListTile(
          leading: CircleAvatar(child: Text(member.name[0])),
          title: Text(member.name),
          trailing: Text(
            NumberFormat.currency(symbol: '₱').format(payment.amount),
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        );
      },
    );
  }
}