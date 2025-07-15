import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../models/health_log.dart';
import '../providers/health_logs_provider.dart';

class HealthLogsScreen extends ConsumerStatefulWidget {
  const HealthLogsScreen({super.key});

  @override
  ConsumerState<HealthLogsScreen> createState() => _HealthLogsScreenState();
}

class _HealthLogsScreenState extends ConsumerState<HealthLogsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _symptomsController = TextEditingController();
  final _notesController = TextEditingController();
  String _selectedMood = 'Good';
  double _weight = 0.0;
  int _bloodPressureSystolic = 0;
  int _bloodPressureDiastolic = 0;
  int _heartRate = 0;

  final List<String> _moodOptions = [
    'Excellent',
    'Good',
    'Fair',
    'Poor',
    'Terrible'
  ];

  @override
  void dispose() {
    _symptomsController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _showAddLogDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Health Log'),
        content: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Date
                TextFormField(
                  initialValue: DateFormat('yyyy-MM-dd').format(DateTime.now()),
                  decoration: const InputDecoration(
                    labelText: 'Date',
                    prefixIcon: Icon(Icons.calendar_today),
                  ),
                  readOnly: true,
                ),
                const SizedBox(height: 16),

                // Mood
                DropdownButtonFormField<String>(
                  value: _selectedMood,
                  decoration: const InputDecoration(
                    labelText: 'Mood',
                    prefixIcon: Icon(Icons.sentiment_satisfied),
                  ),
                  items: _moodOptions.map((mood) {
                    return DropdownMenuItem(
                      value: mood,
                      child: Text(mood),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedMood = value!;
                    });
                  },
                ),
                const SizedBox(height: 16),

                // Symptoms
                TextFormField(
                  controller: _symptomsController,
                  decoration: const InputDecoration(
                    labelText: 'Symptoms',
                    prefixIcon: Icon(Icons.medical_services),
                    hintText: 'e.g., headache, fever, fatigue',
                  ),
                  maxLines: 2,
                ),
                const SizedBox(height: 16),

                // Weight
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Weight (kg)',
                    prefixIcon: Icon(Icons.monitor_weight),
                  ),
                  keyboardType: TextInputType.number,
                  onChanged: (value) {
                    _weight = double.tryParse(value) ?? 0.0;
                  },
                ),
                const SizedBox(height: 16),

                // Blood Pressure
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        decoration: const InputDecoration(
                          labelText: 'Systolic',
                          prefixIcon: Icon(Icons.favorite),
                        ),
                        keyboardType: TextInputType.number,
                        onChanged: (value) {
                          _bloodPressureSystolic = int.tryParse(value) ?? 0;
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextFormField(
                        decoration: const InputDecoration(
                          labelText: 'Diastolic',
                          prefixIcon: Icon(Icons.favorite),
                        ),
                        keyboardType: TextInputType.number,
                        onChanged: (value) {
                          _bloodPressureDiastolic = int.tryParse(value) ?? 0;
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Heart Rate
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Heart Rate (bpm)',
                    prefixIcon: Icon(Icons.favorite),
                  ),
                  keyboardType: TextInputType.number,
                  onChanged: (value) {
                    _heartRate = int.tryParse(value) ?? 0;
                  },
                ),
                const SizedBox(height: 16),

                // Notes
                TextFormField(
                  controller: _notesController,
                  decoration: const InputDecoration(
                    labelText: 'Notes',
                    prefixIcon: Icon(Icons.note),
                    hintText: 'Additional notes...',
                  ),
                  maxLines: 3,
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: _addHealthLog,
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _addHealthLog() {
    if (_formKey.currentState!.validate()) {
      final healthLog = HealthLog(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        date: DateTime.now(),
        symptoms: _symptomsController.text,
        mood: _selectedMood,
        notes: _notesController.text,
        weight: _weight,
        bloodPressureSystolic: _bloodPressureSystolic,
        bloodPressureDiastolic: _bloodPressureDiastolic,
        heartRate: _heartRate,
      );

      ref.read(healthLogsProvider.notifier).addHealthLog(healthLog);

      // Reset form
      _symptomsController.clear();
      _notesController.clear();
      _selectedMood = 'Good';
      _weight = 0.0;
      _bloodPressureSystolic = 0;
      _bloodPressureDiastolic = 0;
      _heartRate = 0;

      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Health log added successfully!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final healthLogs = ref.watch(healthLogsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Health Logs'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () {
              // TODO: Implement filtering
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Filtering coming soon!')),
              );
            },
          ),
        ],
      ),
      body: healthLogs.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.health_and_safety,
                    size: 80,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No health logs yet',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Tap the + button to add your first health log',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey[500],
                    ),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: healthLogs.length,
              itemBuilder: (context, index) {
                final log = healthLogs[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: _getMoodColor(log.mood),
                      child: Icon(
                        _getMoodIcon(log.mood),
                        color: Colors.white,
                      ),
                    ),
                    title: Text(
                      DateFormat('MMM dd, yyyy').format(log.date),
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (log.symptoms.isNotEmpty)
                          Text('Symptoms: ${log.symptoms}'),
                        if (log.weight > 0)
                          Text('Weight: ${log.weight} kg'),
                        if (log.bloodPressureSystolic > 0)
                          Text('BP: ${log.bloodPressureSystolic}/${log.bloodPressureDiastolic}'),
                        if (log.heartRate > 0)
                          Text('HR: ${log.heartRate} bpm'),
                        if (log.notes.isNotEmpty)
                          Text('Notes: ${log.notes}'),
                      ],
                    ),
                    trailing: PopupMenuButton(
                      itemBuilder: (context) => [
                        const PopupMenuItem(
                          value: 'edit',
                          child: Row(
                            children: [
                              Icon(Icons.edit),
                              SizedBox(width: 8),
                              Text('Edit'),
                            ],
                          ),
                        ),
                        const PopupMenuItem(
                          value: 'delete',
                          child: Row(
                            children: [
                              Icon(Icons.delete, color: Colors.red),
                              SizedBox(width: 8),
                              Text('Delete', style: TextStyle(color: Colors.red)),
                            ],
                          ),
                        ),
                      ],
                      onSelected: (value) {
                        if (value == 'delete') {
                          ref.read(healthLogsProvider.notifier).deleteHealthLog(log.id);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Health log deleted')),
                          );
                        }
                      },
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddLogDialog,
        child: const Icon(Icons.add),
      ),
    );
  }

  Color _getMoodColor(String mood) {
    switch (mood.toLowerCase()) {
      case 'excellent':
        return Colors.green;
      case 'good':
        return Colors.blue;
      case 'fair':
        return Colors.orange;
      case 'poor':
        return Colors.red;
      case 'terrible':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  IconData _getMoodIcon(String mood) {
    switch (mood.toLowerCase()) {
      case 'excellent':
        return Icons.sentiment_very_satisfied;
      case 'good':
        return Icons.sentiment_satisfied;
      case 'fair':
        return Icons.sentiment_neutral;
      case 'poor':
        return Icons.sentiment_dissatisfied;
      case 'terrible':
        return Icons.sentiment_very_dissatisfied;
      default:
        return Icons.sentiment_neutral;
    }
  }
} 