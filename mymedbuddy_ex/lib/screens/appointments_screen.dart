import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../models/appointment.dart';
import '../services/shared_preferences_service.dart';

class AppointmentsScreen extends ConsumerStatefulWidget {
  const AppointmentsScreen({super.key});

  @override
  ConsumerState<AppointmentsScreen> createState() => _AppointmentsScreenState();
}

class _AppointmentsScreenState extends ConsumerState<AppointmentsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _doctorNameController = TextEditingController();
  final _specialtyController = TextEditingController();
  final _locationController = TextEditingController();
  final _notesController = TextEditingController();
  DateTime? _selectedDateTime;
  bool _isConfirmed = false;
  List<Appointment> _appointments = [];

  @override
  void initState() {
    super.initState();
    _loadAppointments();
  }

  @override
  void dispose() {
    _doctorNameController.dispose();
    _specialtyController.dispose();
    _locationController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _loadAppointments() async {
    try {
      final appointments = await SharedPreferencesService.getAppointments();
      setState(() {
        _appointments = appointments;
      });
    } catch (e) {
      // Handle error
    }
  }

  void _showAddAppointmentDialog() {
    _selectedDateTime = DateTime.now().add(const Duration(days: 1));
    _isConfirmed = false;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Appointment'),
        content: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Doctor Name
                TextFormField(
                  controller: _doctorNameController,
                  decoration: const InputDecoration(
                    labelText: 'Doctor Name',
                    prefixIcon: Icon(Icons.person),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter doctor name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Specialty
                TextFormField(
                  controller: _specialtyController,
                  decoration: const InputDecoration(
                    labelText: 'Specialty',
                    prefixIcon: Icon(Icons.medical_services),
                    hintText: 'e.g., Cardiology, Dermatology',
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter specialty';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Date & Time
                ListTile(
                  leading: const Icon(Icons.calendar_today),
                  title: const Text('Date & Time'),
                  subtitle: Text(_selectedDateTime != null 
                    ? DateFormat('MMM dd, yyyy - HH:mm').format(_selectedDateTime!)
                    : 'Select date and time'),
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: _selectedDateTime ?? DateTime.now(),
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 365)),
                    );
                    if (date != null && mounted) {
                      final time = await showTimePicker(
                        context: context,
                        initialTime: TimeOfDay.fromDateTime(_selectedDateTime ?? DateTime.now()),
                      );
                      if (time != null && mounted) {
                        setState(() {
                          _selectedDateTime = DateTime(
                            date.year,
                            date.month,
                            date.day,
                            time.hour,
                            time.minute,
                          );
                        });
                      }
                    }
                  },
                ),
                const SizedBox(height: 16),

                // Location
                TextFormField(
                  controller: _locationController,
                  decoration: const InputDecoration(
                    labelText: 'Location',
                    prefixIcon: Icon(Icons.location_on),
                    hintText: 'e.g., City Hospital, Medical Center',
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter location';
                    }
                    return null;
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
                const SizedBox(height: 16),

                // Confirmed Status
                SwitchListTile(
                  title: const Text('Confirmed'),
                  subtitle: const Text('Appointment is confirmed'),
                  value: _isConfirmed,
                  onChanged: (value) {
                    setState(() {
                      _isConfirmed = value;
                    });
                  },
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
            onPressed: _addAppointment,
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _addAppointment() {
    if (_formKey.currentState!.validate() && _selectedDateTime != null) {
      final appointment = Appointment(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        doctorName: _doctorNameController.text.trim(),
        specialty: _specialtyController.text.trim(),
        dateTime: _selectedDateTime!,
        location: _locationController.text.trim(),
        notes: _notesController.text.trim(),
        isConfirmed: _isConfirmed,
      );

      setState(() {
        _appointments.add(appointment);
      });

      // Save to SharedPreferences
      SharedPreferencesService.saveAppointments(_appointments).then((_) {
        // Successfully saved
      }).catchError((error) {
        // Handle error silently
      });

      // Reset form
      _doctorNameController.clear();
      _specialtyController.clear();
      _locationController.clear();
      _notesController.clear();
      _selectedDateTime = null;
      _isConfirmed = false;

      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Appointment added successfully!')),
      );
    } else if (_selectedDateTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select date and time')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all required fields')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Sort appointments by date
    _appointments.sort((a, b) => a.dateTime.compareTo(b.dateTime));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Appointments'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
      ),
      body: _appointments.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.calendar_today,
                    size: 80,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No appointments yet',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Tap the + button to add your first appointment',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey[500],
                    ),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _appointments.length,
              itemBuilder: (context, index) {
                final appointment = _appointments[index];
                final isToday = appointment.dateTime.day == DateTime.now().day &&
                               appointment.dateTime.month == DateTime.now().month &&
                               appointment.dateTime.year == DateTime.now().year;
                final isPast = appointment.dateTime.isBefore(DateTime.now());

                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  color: isPast ? Colors.grey[100] : null,
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: appointment.isConfirmed 
                          ? Colors.green 
                          : Colors.orange,
                      child: Icon(
                        appointment.isConfirmed ? Icons.check : Icons.schedule,
                        color: Colors.white,
                      ),
                    ),
                    title: Text(
                      appointment.doctorName,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Specialty: ${appointment.specialty}'),
                        Text('Location: ${appointment.location}'),
                        Text(
                          DateFormat('MMM dd, yyyy - HH:mm').format(appointment.dateTime),
                          style: TextStyle(
                            color: isToday ? Colors.blue : null,
                            fontWeight: isToday ? FontWeight.bold : null,
                          ),
                        ),
                        if (appointment.notes.isNotEmpty)
                          Text('Notes: ${appointment.notes}'),
                        if (isPast)
                          const Text(
                            'Past appointment',
                            style: TextStyle(color: Colors.grey, fontStyle: FontStyle.italic),
                          ),
                      ],
                    ),
                    trailing: PopupMenuButton(
                      itemBuilder: (context) => [
                        PopupMenuItem(
                          value: 'toggle',
                          child: Row(
                            children: [
                              Icon(appointment.isConfirmed ? Icons.schedule : Icons.check),
                              const SizedBox(width: 8),
                              Text(appointment.isConfirmed ? 'Mark Unconfirmed' : 'Mark Confirmed'),
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
                        if (value == 'toggle') {
                          setState(() {
                            appointment.isConfirmed = !appointment.isConfirmed;
                          });
                          SharedPreferencesService.saveAppointments(_appointments);
                        } else if (value == 'delete') {
                          setState(() {
                            _appointments.removeAt(index);
                          });
                          SharedPreferencesService.saveAppointments(_appointments);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Appointment deleted')),
                          );
                        }
                      },
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddAppointmentDialog,
        child: const Icon(Icons.add),
      ),
    );
  }
}