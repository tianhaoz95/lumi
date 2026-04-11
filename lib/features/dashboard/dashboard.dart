// Dashboard implementation for Phase 1
import 'package:flutter/material.dart';
import '../../core/theme.dart';
import '../../shared/widgets/lumi_card.dart';
import '../../widgets/floating_nav_bar.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('The Tundra'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      backgroundColor: LumiColors.surface,
      body: LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth;
          final isWide = width >= 800;
          final crossAxisCount = isWide ? 3 : 1;

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Bento grid
                GridView(
                  key: const Key('bento_grid'),
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: crossAxisCount,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: isWide ? 3 : 3,
                  ),
                  children: [
                    _MetricCard(
                      key: const Key('metric_current_expenses'),
                      title: 'Current Expenses',
                      value: '\$1,234.56',
                      subtitle: '+4.2% this month',
                    ),
                    _MetricCard(
                      key: const Key('metric_working_hours'),
                      title: 'Working Hours',
                      value: '38h',
                      subtitle: 'This week',
                    ),
                    _MetricCard(
                      key: const Key('metric_mileage'),
                      title: 'Mileage Tracking',
                      value: '120 mi',
                      subtitle: 'Est. \$80.40',
                    ),
                  ],
                ),

                const SizedBox(height: 18),

                const Text('Recent Activity', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),

                // Recent activity list
                Expanded(
                  child: ListView.separated(
                    key: const Key('recent_activity_list'),
                    itemCount: _mockTransactions.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final t = _mockTransactions[index];
                      return LumiCard(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                CircleAvatar(child: Icon(t.icon, size: 20), radius: 20, backgroundColor: LumiColors.surfaceContainerHigh),
                                const SizedBox(width: 12),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(t.name, style: const TextStyle(fontWeight: FontWeight.w600)),
                                    Text(t.subtitle, style: const TextStyle(color: Colors.grey, fontSize: 12)),
                                  ],
                                ),
                              ],
                            ),
                            Text(t.amount, style: const TextStyle(fontWeight: FontWeight.w600)),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.only(bottom: 12.0),
        child: FloatingNavBar(
          children: [
            IconButton(onPressed: () {}, icon: const Icon(Icons.home)),
            IconButton(onPressed: () {}, icon: const Icon(Icons.search)),
            IconButton(onPressed: () {}, icon: const Icon(Icons.add)),
            IconButton(onPressed: () {}, icon: const Icon(Icons.pie_chart)),
            IconButton(onPressed: () {}, icon: const Icon(Icons.settings)),
          ],
        ),
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  final String title;
  final String value;
  final String subtitle;

  const _MetricCard({Key? key, required this.title, required this.value, required this.subtitle}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LumiCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(title, style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(height: 8),
          Text(value, style: Theme.of(context).textTheme.headlineLarge),
          const SizedBox(height: 6),
          Text(subtitle, style: Theme.of(context).textTheme.bodySmall),
        ],
      ),
    );
  }
}

class _Transaction {
  final String name;
  final String subtitle;
  final String amount;
  final IconData icon;

  const _Transaction(this.name, this.subtitle, this.amount, this.icon);
}

const _mockTransactions = <_Transaction>[
  _Transaction('Coffee House', 'Latte & tip', '-\$6.75', Icons.local_cafe),
  _Transaction('Office Depot', 'Printer ink', '-\$45.12', Icons.shopping_bag),
  _Transaction('Mileage Reimbursement', 'Trip to client', '+\$80.40', Icons.directions_car),
  _Transaction('Electric', 'April bill', '-\$120.00', Icons.flash_on),
];
