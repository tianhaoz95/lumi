// Dashboard implementation for Phase 1 (upgraded to use live summary shim)
import 'package:flutter/material.dart';
import '../../core/theme.dart';
import '../../shared/widgets/lumi_card.dart';
import '../../widgets/floating_nav_bar.dart';
import '../../shared/bridge/summary_bridge.dart';
import '../../shared/models/financial_summary.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  FinancialSummary? _summary;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _fetchSummary();
  }

  Future<void> _fetchSummary() async {
    setState(() {
      _loading = true;
    });
    try {
      final map = await fetchMonthlySummary();
      setState(() {
        _summary = FinancialSummary.fromJson(map);
      });
    } catch (e) {
      // swallow — UI will show placeholders
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  Future<void> _onRefresh() => _fetchSummary();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('The Tundra'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      backgroundColor: LumiColors.surface,
      body: RefreshIndicator(
        onRefresh: _onRefresh,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Bento grid
                LayoutBuilder(
                  builder: (context, constraints) {
                    final width = constraints.maxWidth;
                    final isWide = width >= 800;
                    final crossAxisCount = isWide ? 3 : 1;
                    return GridView(
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
                          value: _summary != null ? '\$${_summary!.totalExpenses.toStringAsFixed(2)}' : '--',
                          subtitle: _summary != null ? '' : (_loading ? 'Loading...' : ''),
                        ),
                        _MetricCard(
                          key: const Key('metric_working_hours'),
                          title: 'Working Hours',
                          value: '--',
                          subtitle: 'This week',
                        ),
                        _MetricCard(
                          key: const Key('metric_mileage'),
                          title: 'Mileage Tracking',
                          value: _summary != null ? '${_summary!.totalMiles.toStringAsFixed(0)} mi' : '--',
                          subtitle: _summary != null ? 'Est. \$${_summary!.estimatedDeduction.toStringAsFixed(2)}' : '',
                        ),
                      ],
                    );
                  },
                ),

                const SizedBox(height: 18),

                const Text('Recent Activity', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),

                // Recent activity list (shrink-wrapped so the parent scroll view handles scrolling)
                ListView.separated(
                  key: const Key('recent_activity_list'),
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
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
              ],
            ),
          ),
        ),
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
