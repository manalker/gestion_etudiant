import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

class AgendaPage extends StatefulWidget {
  final String userId; // Identifiant unique de l'utilisateur connecté

  const AgendaPage({Key? key, required this.userId}) : super(key: key);

  @override
  _AgendaPageState createState() => _AgendaPageState();
}

class _AgendaPageState extends State<AgendaPage> {
  DateTime _focusedDay = DateTime.now(); // Jour focalisé
  DateTime? _selectedDay; // Jour sélectionné
  Map<DateTime, List<Map<String, dynamic>>> _events = {}; // Tâches par date

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    _loadTasks(); // Charger les tâches
  }

  // Charger les tâches depuis Firestore
  Future<void> _loadTasks() async {
    final querySnapshot = await _firestore
        .collection('Tasks')
        .where('owner', isEqualTo: widget.userId)
        .get();

    final tasks = <DateTime, List<Map<String, dynamic>>>{};
    for (var doc in querySnapshot.docs) {
      final data = doc.data();
      if (data['datEchea'] != null) {
        final date = _convertToDateTime(data['datEchea']);
        final task = {
          'id': doc.id,
          'title': data['titleTask'] ?? 'Sans titre',
          'time': data['heureTask'] ?? '',
          'status': data['statut'] ?? 'En attente'
        };
        if (tasks[date] == null) {
          tasks[date] = [task];
        } else {
          tasks[date]!.add(task);
        }
      }
    }

    setState(() {
      _events = tasks;
    });
  }

  // Conversion des dates pour Firestore
  DateTime _convertToDateTime(dynamic date) {
    if (date is Timestamp) {
      return DateTime(
          date.toDate().year, date.toDate().month, date.toDate().day);
    } else if (date is String) {
      final parsedDate = DateTime.parse(date);
      return DateTime(parsedDate.year, parsedDate.month, parsedDate.day);
    } else {
      return DateTime(2100);
    }
  }

  // Construire l'agenda avec tâches
  Widget _buildAgenda() {
    return Column(
      children: [
        Expanded(
          child: TableCalendar(
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
            eventLoader: (day) => _events[day] ?? [],
            calendarStyle: const CalendarStyle(
              selectedDecoration: BoxDecoration(
                color: Colors.teal,
                shape: BoxShape.circle,
              ),
              todayDecoration: BoxDecoration(
                color: Colors.blue,
                shape: BoxShape.circle,
              ),
              markerDecoration: BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
              ),
              weekendTextStyle: TextStyle(color: Colors.red),
            ),
            headerStyle: const HeaderStyle(
              titleCentered: true,
              formatButtonVisible: false,
            ),
            daysOfWeekStyle: const DaysOfWeekStyle(
              weekendStyle: TextStyle(color: Colors.red),
            ),
          ),
        ),
        const SizedBox(height: 10),
        Expanded(
          child: _selectedDay != null && _events[_selectedDay] != null
              ? ListView.builder(
                  itemCount: _events[_selectedDay]!.length,
                  itemBuilder: (context, index) {
                    final task = _events[_selectedDay]![index];
                    return Card(
                      child: ListTile(
                        title: Text(
                          task['title'],
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            decoration: task['status'] == 'Terminé'
                                ? TextDecoration.lineThrough
                                : TextDecoration.none,
                          ),
                        ),
                        subtitle: Text(
                          'Heure: ${task['time']}',
                          style: const TextStyle(color: Colors.grey),
                        ),
                      ),
                    );
                  },
                )
              : const Center(
                  child: Text(
                    'Aucune tâche pour cette date.',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Agenda'),
        backgroundColor: Colors.teal,
        centerTitle: true,
      ),
      body: _buildAgenda(),
    );
  }
}
