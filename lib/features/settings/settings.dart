import 'package:flutter/foundation.dart';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme.dart';
import '../../core/widgets/lumi_top_app_bar.dart';
import '../../shared/widgets/lumi_card.dart';
import '../../shared/widgets/atmospheric_background.dart';
import '../../features/sentinel/known_locations.dart';
import '../../features/auth/auth_notifier.dart';
import '../../shared/bridge/sentinel.dart';

Future<SentinelHealth?> _safeGetSentinelHealth() async {
  try {
    return await getSentinelHealth();
  } catch (_) {
    return null;
  }
}

/// Settings screen implemented to match design/ui_design/settings/code.html
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  void _onLogout(BuildContext context, WidgetRef ref) async {
    // Attempt to logout via AuthNotifier.
    await ref.read(authNotifierProvider.notifier).logout();
    // GoRouter will handle redirection via auth state change.
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: LumiColors.surface,
      body: Stack(
        children: [
          const AtmosphericBackground(),
          SafeArea(
            child: Column(
              children: [
                // Top app bar (glassmorphism)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16.0),
                    child: SizedBox(
                      height: kToolbarHeight + 24.0,
                      child: LumiTopAppBar(
                        leading: IconButton(
                          icon: const Icon(Icons.arrow_back),
                          onPressed: () => context.pop(),
                          tooltip: 'Back',
                        ),
                        title: Text('The Cabin', style: Theme.of(context).textTheme.titleLarge),
                        actions: [
                          const SizedBox(width: 12.0),
                          // Circular gradient profile placeholder matching design
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: const LinearGradient(
                                colors: [LumiColors.primary, LumiColors.primaryContainer],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              boxShadow: [
                                BoxShadow(color: const Color(0x14F5FAFC), blurRadius: 1.0, spreadRadius: 0),
                              ],
                            ),
                            child: const Icon(Icons.person, color: Colors.white, size: 20),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const SizedBox(height: 8.0),
                        // Profile section
                        Center(
                          child: Column(
                            children: [
                              Stack(
                                alignment: Alignment.bottomRight,
                                children: [
                                  Container(
                                    width: 96,
                                    height: 96,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      gradient: const LinearGradient(
                                        colors: [LumiColors.primary, LumiColors.primaryContainer],
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                      ),
                                    ),
                                    padding: const EdgeInsets.all(4.0),
                                    child: ClipOval(
                                      child: Image.network(
                                        'https://lh3.googleusercontent.com/aida-public/AB6AXuDnpmVAxvqLGbhMLNtj8Y5InvPsMLq_3qryQBspuNd1zjDtcrwB_0PSxcX--W2Y-Ig-JvClOsorwmKGm41tYWM03AAidJcF-JxZYtnVU_IfJMdOgan-rXWwyoivgZesLGJHCxWd0UGBiW-VBT5Wm3Z5srDE1ukLZjN5GfhjjwXB7vB6W7VOFPbQPnHz4EuWQkcojxQ_ksoI6cTOFOiLiTHoLgS_lcUjSZmLwY5eWUns4i0ZUQqBL2prQrfBmUWH7O8MQecP_9TTuWlv',
                                        width: 88,
                                        height: 88,
                                        fit: BoxFit.cover,
                                        errorBuilder: (context, error, stackTrace) {
                                          return Container(
                                            width: 88,
                                            height: 88,
                                            color: Colors.grey.shade200,
                                            child: Icon(Icons.person, color: Colors.grey[600]),
                                          );
                                        },
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    right: 0,
                                    bottom: 0,
                                    child: Container(
                                      width: 28,
                                      height: 28,
                                      decoration: BoxDecoration(
                                        color: LumiColors.primaryContainer,
                                        shape: BoxShape.circle,
                                        boxShadow: [
                                          BoxShadow(color: LumiColors.surface, blurRadius: 2.0, spreadRadius: 0),
                                        ],
                                      ),
                                      child: const Icon(Icons.edit, size: 16, color: Colors.white),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12.0),
                              Text('Erik Sondergaard', style: Theme.of(context).textTheme.headlineLarge),
                              const SizedBox(height: 4.0),
                              Text('erik.sondergaard@cabin.co', style: Theme.of(context).textTheme.bodyMedium),
                            ],
                          ),
                        ),

                        const SizedBox(height: 24.0),

                        // Workspace items
                        LumiCard(
                          padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
                          child: Column(
                            children: [
                              _SettingsRow(
                                icon: Icons.settings,
                                label: 'Account Preferences',
                                onTap: () {},
                              ),
                              const SizedBox(height: 8),
                              _SettingsRow(
                                icon: Icons.verified_user,
                                label: 'Security',
                                onTap: () {},
                              ),
                              const SizedBox(height: 8),
                              _SettingsRow(
                                icon: Icons.notifications,
                                label: 'Notifications',
                                trailing: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: LumiColors.primaryContainer,
                                    borderRadius: BorderRadius.circular(9999),
                                  ),
                                  child: const Text('3 New', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
                                ),
                                onTap: () {},
                              ),
                              const SizedBox(height: 8),
                              _SettingsRow(
                                icon: Icons.location_on,
                                label: 'Known Locations',
                                onTap: () {
                                  Navigator.of(context).push(MaterialPageRoute(builder: (_) => const KnownLocationsScreen()));
                                },
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 20.0),

                        // Logout / Delete buttons
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: () => _onLogout(context, ref),
                                icon: const Icon(Icons.logout),
                                label: const Text('Log Out'),
                                style: OutlinedButton.styleFrom(
                                  side: BorderSide.none,
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                  textStyle: const TextStyle(fontWeight: FontWeight.w600),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12.0),
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: () {},
                                icon: const Icon(Icons.delete_forever, color: Colors.red),
                                label: const Text('Delete Account', style: TextStyle(color: Colors.red)),
                                style: OutlinedButton.styleFrom(
                                  side: BorderSide.none,
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 40.0),

                        // Sentinel Health (dev mode only)
                        if (kDebugMode)
                          LumiCard(
                            padding: const EdgeInsets.all(12.0),
                            child: FutureBuilder<SentinelHealth?>(
                              future: kDebugMode ? _safeGetSentinelHealth() : Future<SentinelHealth?>.value(null),
                              builder: (context, snapshot) {
                                if (snapshot.connectionState == ConnectionState.waiting) return const Text('Loading Sentinel health...');
                                if (snapshot.hasError) return Text('Sentinel health error: ${snapshot.error}');
                                final health = snapshot.data;
                                final lastScan = (health != null && health.lastScanTs != null) ? DateTime.fromMillisecondsSinceEpoch(health.lastScanTs! * 1000).toLocal().toString() : 'N/A';
                                final avgBattery = (health != null && health.avgBatteryDelta != null) ? '${health.avgBatteryDelta!.toStringAsFixed(2)}' : 'N/A';
                                final scans24 = (health?.scansLast24H ?? 0);
                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Sentinel Health (dev)', style: Theme.of(context).textTheme.titleMedium),
                                    const SizedBox(height: 8),
                                    Text('Last scan: $lastScan'),
                                    Text('Avg battery delta per scan: $avgBattery%'),
                                    Text('Scans in last 24h: $scans24'),
                                  ],
                                );
                              },
                            ),
                          ),

                        // Decorative ghost icon
                        Opacity(
                          opacity: 0.08,
                          child: Center(child: Icon(Icons.eco, size: 80, color: LumiColors.primary)),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SettingsRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final Widget? trailing;
  final VoidCallback? onTap;

  const _SettingsRow({required this.icon, required this.label, this.trailing, this.onTap, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 12.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: LumiColors.primaryContainer.withAlpha(31),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(icon, color: LumiColors.primary),
                ),
                const SizedBox(width: 12),
                Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
              ],
            ),
            Row(children: [
              if (trailing != null) trailing!,
              const SizedBox(width: 8),
              const Icon(Icons.chevron_right, color: Color(0xFF6F7979)),
            ])
          ],
        ),
      ),
    );
  }
}
