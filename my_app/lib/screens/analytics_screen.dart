import 'package:fl_chart/fl_chart.dart';

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  int _selectedPeriod = 0; // 0: Daily, 1: Weekly, 2: Monthly, 3: Yearly

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Analytics')),
      body: Consumer<LoanProvider>(
        builder: (context, provider, child) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                SegmentedButton<int>(
                  segments: const [
                    ButtonSegment(value: 0, label: Text('Daily')),
                    ButtonSegment(value: 1, label: Text('Weekly')),
                    ButtonSegment(value: 2, label: Text('Monthly')),
                    ButtonSegment(value: 3, label: Text('Yearly')),
                  ],
                  selected: {_selectedPeriod},
                  onSelectionChanged: (Set<int> selection) {
                    setState(() => _selectedPeriod = selection.first);
                  },
                ),
                const SizedBox(height: 24),
                _buildStatCards(provider),
                const SizedBox(height: 24),
                _buildChart(provider),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatCards(LoanProvider provider) {
    final currencyFormat = NumberFormat.currency(symbol: '₱');
    
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      const Text('Total Collected'),
                      Text(
                        currencyFormat.format(provider.totalProfit),
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      const Text('Outstanding'),
                      Text(
                        currencyFormat.format(provider.totalOutstanding),
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildChart(LoanProvider provider) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: SizedBox(
          height: 300,
          child: LineChart(
            LineChartData(
              gridData: const FlGridData(show: true),
              titlesData: const FlTitlesData(show: true),
              borderData: FlBorderData(show: true),
              lineBarsData: [
                LineChartBarData(
                  spots: _generateChartData(provider),
                  isCurved: true,
                  color: Colors.blue,
                  barWidth: 3,
                  dotData: const FlDotData(show: true),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  List<FlSpot> _generateChartData(LoanProvider provider) {
    // Sample data - implement actual calculation based on period
    return List.generate(7, (i) => FlSpot(i.toDouble(), (i * 1000).toDouble()));
  }
}