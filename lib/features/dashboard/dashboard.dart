// Dashboard implementation for Phase 1 (upgraded to use live summary shim)
import 'package:flutter/material.dart';
import '../../core/theme.dart';
import '../../shared/widgets/lumi_card.dart';
import '../../widgets/floating_nav_bar.dart';
import '../../shared/bridge/rig_bridge.dart';
import '../../shared/models/financial_summary.dart';
import '../../shared/models/transaction_summary.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  FinancialSummary? _summary;
  bool _loading = false;
  List<TransactionSummary>? _recentTransactions;

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
      final summary = await fetchMonthlySummary();
      final txs = await queryTransactions(limit: 5);
      setState(() {
        _summary = summary;
        _recentTransactions = txs;
      });
    } catch (e) {
      // swallow — UI will show placeholders
      setState(() {
        _recentTransactions = _recentTransactions ?? <TransactionSummary>[];
      });
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
                        childAspectRatio: isWide ? 3 : 2.2,
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
                if (_loading && _recentTransactions == null)
                  const Center(child: Padding(padding: EdgeInsets.symmetric(vertical: 16.0), child: CircularProgressIndicator()))
                else if ((_recentTransactions ?? []).isEmpty)
                  LumiCard(child: Padding(padding: const EdgeInsets.all(16.0), child: Text('No transactions yet', style: Theme.of(context).textTheme.bodyMedium)))
                else
                  ListView.separated(
                    key: const Key('recent_activity_list'),
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _recentTransactions!.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final t = _recentTransactions![index];
                      // Simple category -> icon mapping
                      IconData icon;
                      switch (t.category.toLowerCase()) {
                        case 'food':
                        case 'coffee':
                          icon = Icons.local_cafe;
                          break;
                        case 'mileage':
                          icon = Icons.directions_car;
                          break;
                        case 'utilities':
                          icon = Icons.flash_on;
                          break;
                        default:
                          icon = Icons.shopping_bag;
                      }

                      final amountText = (t.amount >= 0) ? '+\$${t.amount.toStringAsFixed(2)}' : '-\$${t.amount.abs().toStringAsFixed(2)}';

                      return LumiCard(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Row(
                                children: [
                                  CircleAvatar(child: Icon(icon, size: 20), radius: 20, backgroundColor: LumiColors.surfaceContainerHigh),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(t.vendor, style: const TextStyle(fontWeight: FontWeight.w600), overflow: TextOverflow.ellipsis),
                                        Text('${t.category} • ${t.date}', style: const TextStyle(color: Colors.grey, fontSize: 12), overflow: TextOverflow.ellipsis),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Text(amountText, style: const TextStyle(fontWeight: FontWeight.w600)),
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


