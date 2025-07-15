import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../models/medication.dart';
import '../services/shared_preferences_service.dart';
import '../services/api_service.dart';

class MedicationScheduleScreen extends ConsumerStatefulWidget {
  const MedicationScheduleScreen({super.key});

  @override
  ConsumerState<MedicationScheduleScreen> createState() => _MedicationScheduleScreenState();
}

class _MedicationScheduleScreenState extends ConsumerState<MedicationScheduleScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _dosageController = TextEditingController();
  final _instructionsController = TextEditingController();
  String _selectedFrequency = 'Daily';
  List<String> _selectedTimes = [];
  DateTime? _startDate;
  DateTime? _endDate;
  bool _isLoading = false;

  final List<String> _frequencyOptions = [
    'Daily',
    'Twice Daily',
    'Three Times Daily',
    'Weekly',
    'As Needed'
  ];

  final List<String> _timeOptions = [
    'Morning (8:00 AM)',
    'Afternoon (12:00 PM)',
    'Evening (6:00 PM)',
    'Night (10:00 PM)',
    'Before Meals',
    'After Meals'
  ];

  List<Medication> _medications = [];

  @override
  void initState() {
    super.initState();
    _loadMedications();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _dosageController.dispose();
    _instructionsController.dispose();
    super.dispose();
  }

  Future<void> _loadMedications() async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      final medications = await SharedPreferencesService.getMedications();
      setState(() {
        _medications = medications;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showAddMedicationDialog() {
    _startDate = DateTime.now();
    _endDate = null;
    _selectedTimes = [];

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Medication'),
        content: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Medication Name
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Medication Name',
                    prefixIcon: Icon(Icons.medication),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter medication name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Dosage
                TextFormField(
                  controller: _dosageController,
                  decoration: const InputDecoration(
                    labelText: 'Dosage',
                    prefixIcon: Icon(Icons.science),
                    hintText: 'e.g., 10mg, 1 tablet',
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter dosage';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Frequency
                DropdownButtonFormField<String>(
                  value: _selectedFrequency,
                  decoration: const InputDecoration(
                    labelText: 'Frequency',
                    prefixIcon: Icon(Icons.schedule),
                  ),
                  items: _frequencyOptions.map((frequency) {
                    return DropdownMenuItem(
                      value: frequency,
                      child: Text(frequency),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedFrequency = value!;
                    });
                  },
                ),
                const SizedBox(height: 16),

                // Times
                Text(
                  'Times',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: _timeOptions.map((time) {
                    final isSelected = _selectedTimes.contains(time);
                    return FilterChip(
                      label: Text(time),
                      selected: isSelected,
                      onSelected: (selected) {
                        setState(() {
                          if (selected) {
                            _selectedTimes.add(time);
                          } else {
                            _selectedTimes.remove(time);
                          }
                        });
                      },
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),

                // Start Date
                ListTile(
                  leading: const Icon(Icons.calendar_today),
                  title: const Text('Start Date'),
                  subtitle: Text(_startDate != null 
                    ? DateFormat('MMM dd, yyyy').format(_startDate!)
                    : 'Select date'),
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: _startDate ?? DateTime.now(),
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 365)),
                    );
                    if (date != null) {
                      setState(() {
                        _startDate = date;
                      });
                    }
                  },
                ),

                // End Date (Optional)
                ListTile(
                  leading: const Icon(Icons.calendar_today),
                  title: const Text('End Date (Optional)'),
                  subtitle: Text(_endDate != null 
                    ? DateFormat('MMM dd, yyyy').format(_endDate!)
                    : 'No end date'),
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: _endDate ?? DateTime.now(),
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 365)),
                    );
                    if (date != null) {
                      setState(() {
                        _endDate = date;
                      });
                    }
                  },
                ),

                // Instructions
                TextFormField(
                  controller: _instructionsController,
                  decoration: const InputDecoration(
                    labelText: 'Instructions',
                    prefixIcon: Icon(Icons.info),
                    hintText: 'e.g., Take with food, Avoid alcohol',
                  ),
                  maxLines: 2,
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
            onPressed: _addMedication,
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _addMedication() {
    if (_formKey.currentState!.validate() && _selectedTimes.isNotEmpty) {
      final medication = Medication(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: _nameController.text.trim(),
        dosage: _dosageController.text.trim(),
        frequency: _selectedFrequency,
        times: _selectedTimes,
        instructions: _instructionsController.text.trim(),
        startDate: _startDate!,
        endDate: _endDate,
        isActive: true,
      );

      setState(() {
        _medications.add(medication);
      });

      // Save to SharedPreferences
      SharedPreferencesService.saveMedications(_medications).then((_) {
        // Successfully saved
      }).catchError((error) {
        // Handle error silently
      });

      // Reset form
      _nameController.clear();
      _dosageController.clear();
      _instructionsController.clear();
      _selectedFrequency = 'Daily';
      _selectedTimes = [];
      _startDate = null;
      _endDate = null;

      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Medication added successfully!')),
      );
    } else if (_selectedTimes.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select at least one time')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all required fields')),
      );
    }
  }

  void _showMedicationInfo(String medicationName) async {
    try {
      final info = await ApiService.getMedicationInfo(medicationName);
      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
          title: Text(info['name']),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Description: ${info['description']}'),
                const SizedBox(height: 8),
                Text('Dosage: ${info['dosage']}'),
                const SizedBox(height: 8),
                Text('Storage: ${info['storage']}'),
                const SizedBox(height: 16),
                const Text('Side Effects:', style: TextStyle(fontWeight: FontWeight.bold)),
                ...(info['sideEffects'] as List).map((effect) => Text('• $effect')),
                const SizedBox(height: 16),
                const Text('Interactions:', style: TextStyle(fontWeight: FontWeight.bold)),
                ...(info['interactions'] as List).map((interaction) => Text('• $interaction')),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
          ],
        ),
      );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to load medication information')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Medication Schedule'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _medications.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.medication,
                        size: 80,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No medications yet',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Tap the + button to add your first medication',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey[500],
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _medications.length,
                  itemBuilder: (context, index) {
                    final medication = _medications[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: medication.isActive 
                              ? Colors.blue 
                              : Colors.grey,
                          child: Icon(
                            Icons.medication,
                            color: Colors.white,
                          ),
                        ),
                        title: Text(
                          medication.name,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Dosage: ${medication.dosage}'),
                            Text('Frequency: ${medication.frequency}'),
                            Text('Times: ${medication.times.join(', ')}'),
                            if (medication.instructions.isNotEmpty)
                              Text('Instructions: ${medication.instructions}'),
                          ],
                        ),
                        trailing: PopupMenuButton(
                          itemBuilder: (context) => [
                            const PopupMenuItem(
                              value: 'info',
                              child: Row(
                                children: [
                                  Icon(Icons.info),
                                  SizedBox(width: 8),
                                  Text('Info'),
                                ],
                              ),
                            ),
                            PopupMenuItem(
                              value: 'toggle',
                              child: Row(
                                children: [
                                  Icon(medication.isActive ? Icons.pause : Icons.play_arrow),
                                  const SizedBox(width: 8),
                                  Text(medication.isActive ? 'Pause' : 'Activate'),
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
                            if (value == 'info') {
                              _showMedicationInfo(medication.name);
                            } else if (value == 'toggle') {
                              setState(() {
                                medication.isActive = !medication.isActive;
                              });
                              SharedPreferencesService.saveMedications(_medications);
                            } else if (value == 'delete') {
                              setState(() {
                                _medications.removeAt(index);
                              });
                              SharedPreferencesService.saveMedications(_medications);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Medication deleted')),
                              );
                            }
                          },
                        ),
                      ),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddMedicationDialog,
        child: const Icon(Icons.add),
      ),
    );
  }
} 