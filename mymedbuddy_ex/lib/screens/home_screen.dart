import 'package:flutter/material.dart';
import 'package:provider/provider.dart' as provider;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/user_provider.dart';
import '../providers/health_logs_provider.dart';
import '../services/api_service.dart';
import '../widgets/dashboard_card.dart';
import '../widgets/health_tip_card.dart';
import 'medication_schedule_screen.dart';
import 'health_logs_screen.dart';
import 'appointments_screen.dart';
import 'profile_screen.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  String _healthTip = '';
  bool _isLoadingTip = true;

  @override
  void initState() {
    super.initState();
    _loadHealthTip();
  }

  Future<void> _loadHealthTip() async {
    try {
      final tip = await ApiService.getHealthTip();
      setState(() {
        _healthTip = tip;
        _isLoadingTip = false;
      });
    } catch (e) {
      setState(() {
        _healthTip = 'Stay hydrated and get enough sleep!';
        _isLoadingTip = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = provider.Provider.of<UserProvider>(context).user;
    final recentLogs = ref.watch(recentHealthLogsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('MyMedBuddy'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () {
              // TODO: Show notifications
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome Section
            if (user != null) ...[
              Text(
                'Welcome back, ${user.name}!',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Let\'s take care of your health today',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 24),
            ],

            // Health Tip Card
            HealthTipCard(
              tip: _healthTip,
              isLoading: _isLoadingTip,
              onRefresh: _loadHealthTip,
            ),

            const SizedBox(height: 24),

            // Dashboard Grid
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 1.2,
              children: [
                DashboardCard(
                  title: 'Medications',
                  subtitle: '${recentLogs.length} active',
                  icon: Icons.medication,
                  color: Colors.blue,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const MedicationScheduleScreen(),
                      ),
                    );
                  },
                ),
                DashboardCard(
                  title: 'Health Logs',
                  subtitle: '${recentLogs.length} recent',
                  icon: Icons.health_and_safety,
                  color: Colors.green,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const HealthLogsScreen(),
                      ),
                    );
                  },
                ),
                DashboardCard(
                  title: 'Appointments',
                  subtitle: '2 this week',
                  icon: Icons.calendar_today,
                  color: Colors.orange,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const AppointmentsScreen(),
                      ),
                    );
                  },
                ),
                DashboardCard(
                  title: 'Profile',
                  subtitle: 'Settings & preferences',
                  icon: Icons.person,
                  color: Colors.purple,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ProfileScreen(),
                      ),
                    );
                  },
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Quick Actions
            Text(
              'Quick Actions',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const HealthLogsScreen(),
                        ),
                      );
                    },
                    icon: const Icon(Icons.add),
                    label: const Text('Add Health Log'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const MedicationScheduleScreen(),
                        ),
                      );
                    },
                    icon: const Icon(Icons.medication),
                    label: const Text('Add Medication'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}