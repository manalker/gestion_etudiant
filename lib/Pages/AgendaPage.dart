import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:student_manager/Pages/SearchPage.dart';
import 'package:student_manager/Pages/etud_page.dart';
import 'package:student_manager/Pages/task_details_page.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:student_manager/Pages/HistoryPage.dart';
import 'package:student_manager/Pages/add_task_page.dart';
import 'package:student_manager/Pages/view_tasks_page.dart';
import 'package:student_manager/Pages/add_note_page.dart';
import 'package:student_manager/Pages/view_notes_page.dart';

class AgendaPage extends StatefulWidget {
  final String userId;

  const AgendaPage({super.key, required this.userId, required Map events});

  @override
  // ignore: library_private_types_in_public_api
  _AgendaPageState createState() => _AgendaPageState();
}

class _AgendaPageState extends State<AgendaPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late DateTime _focusedDay;
  DateTime? _selectedDay;
  Map<DateTime, List<Map<String, dynamic>>> _events = {};
  final int _selectedIndex = 1; // Default to the Agenda tab

  @override
  void initState() {
    super.initState();
    _focusedDay = DateTime.now();
    _loadAllTasks();
  }

  Future<void> _loadAllTasks() async {
    try {
      final querySnapshot = await _firestore
          .collection('Tasks')
          .where('owner', isEqualTo: widget.userId)
          .get();

      final tasks = <DateTime, List<Map<String, dynamic>>>{};

      for (var doc in querySnapshot.docs) {
        final data = doc.data();
        if (data['datEchea'] != null) {
          final dueDate = _convertToDateTime(data['datEchea']);
          final normalizedDate =
              DateTime(dueDate.year, dueDate.month, dueDate.day);

          final task = {
            'id': doc.id,
            'title': data['titleTask'] ?? 'Sans titre',
            'desc': data['descTask'] ?? 'Pas de description',
            'time': data['heureTask'] ?? '',
            'status': data['statut'] ?? 'En attente',
            'priority': data['priorityTask'] ?? 'unknown',
            'datEchea': data['datEchea'],
            'datCreation': data['datCreation'] ?? 'Non défini',
            'datArchiv': data['datArchiv'] ?? 'Non défini',
            'cathegTask': data['cathegTask'] ?? 'Sans catégorie',
          };

          if (tasks[normalizedDate] == null) {
            tasks[normalizedDate] = [task];
          } else {
            tasks[normalizedDate]!.add(task);
          }
        }
      }

      setState(() {
        _events = tasks;
      });
    } catch (e) {
      print("Erreur lors du chargement des tâches : $e");
    }
  }

  DateTime _convertToDateTime(dynamic date) {
    if (date is Timestamp) {
      return date.toDate();
    } else if (date is String) {
      return DateTime.parse(date);
    } else {
      throw Exception("Format de date invalide");
    }
  }

  void _onItemTapped(int index) {
    if (index == 0) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => EtudPage(
            userId: widget.userId,
          ),
        ),
      );
    } else if (index == 1) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => AgendaPage(
            userId: widget.userId,
            events: const {},
          ),
        ),
      );
    } else if (index == 2) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => SearchPage(userId: widget.userId),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Agenda', style: TextStyle(fontSize: 22)),
        backgroundColor: Colors.teal,
        centerTitle: true,
        elevation: 4.0,
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'tasks') {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ViewTasksPage(
                      userId: widget.userId,
                    ),
                  ),
                );
              } else if (value == 'history') {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => HistoryPage(
                      userId: widget.userId,
                    ),
                  ),
                );
              } else if (value == 'Note') {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AddNotePage(userId: widget.userId),
                  ),
                );
              } else if (value == 'Notes') {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ViewNotesPage(userId: widget.userId),
                  ),
                );
              } else if (value == 'logout') {
                Navigator.pushNamedAndRemoveUntil(
                    context, '/', (route) => false);
              }
            },
            itemBuilder: (BuildContext context) {
              return [
                const PopupMenuItem<String>(
                  value: 'tasks',
                  child: Text('Liste des tâches'),
                ),
                const PopupMenuItem<String>(
                  value: 'history',
                  child: Text('Historique'),
                ),
                const PopupMenuItem<String>(
                  value: 'Note',
                  child: Text('Ajouter une note'),
                ),
                const PopupMenuItem<String>(
                  value: 'Notes',
                  child: Text('Liste des notes'),
                ),
                const PopupMenuItem<String>(
                  value: 'logout',
                  child: Text('Déconnexion'),
                ),
              ];
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            margin: const EdgeInsets.all(10.0),
            decoration: BoxDecoration(
              color: Colors.teal[50],
              borderRadius: BorderRadius.circular(15),
              boxShadow: [
                BoxShadow(
                  color: Colors.teal.withOpacity(0.3),
                  blurRadius: 6,
                  offset: const Offset(0, 4),
                )
              ],
            ),
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
              eventLoader: (day) {
                final normalizedDay = DateTime(day.year, day.month, day.day);
                return _events[normalizedDay] ?? [];
              },
              calendarBuilders: CalendarBuilders(
                markerBuilder: (context, day, events) {
                  if (events.isNotEmpty) {
                    return Positioned(
                      bottom: 1,
                      child: Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: Colors.teal,
                          shape: BoxShape.circle,
                        ),
                      ),
                    );
                  }
                  return null;
                },
              ),
              calendarStyle: const CalendarStyle(
                todayDecoration: BoxDecoration(
                  color: Colors.blueAccent,
                  shape: BoxShape.circle,
                ),
                markersAlignment: Alignment.bottomCenter,
              ),
              headerStyle: const HeaderStyle(
                titleCentered: true,
                formatButtonVisible: false,
                titleTextStyle: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.teal,
                ),
                leftChevronIcon: Icon(Icons.chevron_left, color: Colors.teal),
                rightChevronIcon: Icon(Icons.chevron_right, color: Colors.teal),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: _selectedDay != null &&
                    _events[DateTime(_selectedDay!.year, _selectedDay!.month,
                            _selectedDay!.day)] !=
                        null
                ? ListView.builder(
                    itemCount: _events[DateTime(_selectedDay!.year,
                            _selectedDay!.month, _selectedDay!.day)]!
                        .length,
                    itemBuilder: (context, index) {
                      final task = _events[DateTime(_selectedDay!.year,
                          _selectedDay!.month, _selectedDay!.day)]![index];

                      Icon priorityIcon;
                      switch (task['priority'].toLowerCase()) {
                        case 'haute':
                          priorityIcon = const Icon(Icons.priority_high,
                              color: Colors.red);
                          break;
                        case 'moyenne':
                          priorityIcon =
                              const Icon(Icons.report, color: Colors.orange);
                          break;
                        case 'faible':
                          priorityIcon = const Icon(Icons.low_priority,
                              color: Colors.green);
                          break;
                        default:
                          priorityIcon = const Icon(Icons.help_outline,
                              color: Colors.grey);
                      }

                      bool isTaskLate = task['status'] != 'Terminé' &&
                          _convertToDateTime(task['datEchea'])
                              .isBefore(DateTime.now());

                      return Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16.0, vertical: 8.0),
                        child: Card(
                          elevation: 3,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: ListTile(
                            leading: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [priorityIcon],
                            ),
                            title: Text(
                              task['title'],
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: isTaskLate ? Colors.red : Colors.black,
                                decoration:
                                    isTaskLate || task['status'] == 'Terminé'
                                        ? TextDecoration.lineThrough
                                        : TextDecoration.none,
                              ),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 4),
                                Text(
                                  'Description: ${task['desc'] ?? "Aucune description"}',
                                  style: const TextStyle(
                                    color: Colors.grey,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Date d\'échéance: ${_convertToDateTime(task['datEchea']).toLocal().toString().split(' ')[0]}',
                                  style: const TextStyle(
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => TaskDetailsPage(
                                    taskData: {
                                      'titleTask':
                                          task['title'] ?? 'Sans titre',
                                      'descTask':
                                          task['desc'] ?? 'Pas de description',
                                      'priorityTask':
                                          task['priority'] ?? 'unknown',
                                      'datEchea':
                                          task['datEchea'] ?? 'Non défini',
                                      'datCreation':
                                          task['datCreation'] ?? 'Non défini',
                                      'datArchiv':
                                          task['datArchiv'] ?? 'Non défini',
                                      'statut': task['status'] ?? 'Non défini',
                                      'heureTask': task['time'] ?? 'Non défini',
                                      'cathegTask': task['cathegTask'] ??
                                          'Sans catégorie',
                                    },
                                    taskId: task['id'],
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      );
                    },
                  )
                : const Center(
                    child: Text(
                      'Aucune tâche pour cette date.',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
          )
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddTaskPage(userId: widget.userId),
            ),
          );
        },
        backgroundColor: Colors.teal,
        child: const Icon(Icons.add),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.list),
            label: 'Tâche',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today),
            label: 'Agenda',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: 'Rechercher',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.teal,
        onTap: _onItemTapped,
      ),
    );
  }
}
