import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:student_manager/Pages/HistoryPage.dart';
import 'package:student_manager/Pages/add_task_page.dart';
import 'package:student_manager/Pages/view_tasks_page.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:student_manager/Pages/add_note_page.dart';
import 'package:student_manager/Pages/view_notes_page.dart';

class EtudPage extends StatefulWidget {
  final String userId; // Identifiant unique de l'utilisateur connecté

  const EtudPage({Key? key, required this.userId}) : super(key: key);

  @override
  _EtudPageState createState() => _EtudPageState();
}

class _EtudPageState extends State<EtudPage> {
  int _selectedIndex = 0; // Index de l'onglet sélectionné
  DateTime _focusedDay =
      DateTime.now(); // Jour actuellement focalisé dans le calendrier
  DateTime? _selectedDay; // Jour sélectionné par l'utilisateur

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Gérer le changement d'onglet dans la barre de navigation inférieure
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  // Vérifier si une tâche est en retard
  bool isTaskLate(Map<String, dynamic> taskData) {
    if (taskData['datEchea'] != null && taskData['statut'] != 'Terminé') {
      final dueDate = _convertToDateTime(taskData['datEchea']);
      return dueDate.isBefore(DateTime.now());
    }
    return false;
  }

  // Vérifier si une tâche est due dans la semaine actuelle
  bool isDueThisWeek(DateTime dueDate) {
    final now = DateTime.now();
    final startOfWeek =
        now.subtract(Duration(days: now.weekday - 1)); // Début de la semaine
    final endOfWeek =
        startOfWeek.add(const Duration(days: 6)); // Fin de la semaine
    return dueDate.isAfter(startOfWeek) && dueDate.isBefore(endOfWeek);
  }

  // Récupérer une icône correspondant à la priorité de la tâche
  Icon getPriorityIcon(String priority) {
    switch (priority.toLowerCase()) {
      case 'haute':
        return const Icon(Icons.priority_high, color: Colors.red);
      case 'moyenne':
        return const Icon(Icons.report, color: Colors.orange);
      case 'faible':
        return const Icon(Icons.low_priority, color: Colors.green);
      default:
        return const Icon(Icons.help_outline, color: Colors.grey);
    }
  }

  // Construire la liste des tâches triées par mois
  Widget _buildTasksByMonth() {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestore
          .collection('Tasks')
          .where('owner', isEqualTo: widget.userId)
          .where('statut',
              whereIn: ['En cours', 'En attente']) // Tâches actives uniquement
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(
            child: Text(
              'Erreur : ${snapshot.error}',
              style: const TextStyle(fontSize: 16, color: Colors.red),
            ),
          );
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(
            child: Text(
              'Aucune tâche trouvée.',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          );
        }

        final tasks = snapshot.data!.docs;

        // Trier les tâches par date d'échéance
        tasks.sort((a, b) {
          final aDate = _convertToDateTime(
              (a.data() as Map<String, dynamic>)['datEchea']);
          final bDate = _convertToDateTime(
              (b.data() as Map<String, dynamic>)['datEchea']);
          return aDate.compareTo(bDate);
        });

        // Regrouper les tâches par mois
        final tasksByMonth = <String, List<QueryDocumentSnapshot>>{};
        for (var task in tasks) {
          final taskData = task.data() as Map<String, dynamic>;
          if (taskData['datEchea'] != null) {
            final dueDate = _convertToDateTime(taskData['datEchea']);
            final monthKey = '${dueDate.year}-${dueDate.month}';
            tasksByMonth.putIfAbsent(monthKey, () => []).add(task);
          }
        }

        return ListView(
          children: tasksByMonth.entries.map((entry) {
            final month = entry.key;
            final taskList = entry.value;

            final DateTime monthDate = DateTime(
              int.parse(month.split('-')[0]),
              int.parse(month.split('-')[1]),
            );
            final String formattedMonth =
                '${_getMonthName(monthDate.month)} ${monthDate.year}';

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // En-tête du mois
                Padding(
                  padding: const EdgeInsets.symmetric(
                      vertical: 10.0, horizontal: 16.0),
                  child: Text(
                    formattedMonth,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.teal,
                    ),
                  ),
                ),
                // Liste des tâches pour le mois courant
                ...taskList.map((task) {
                  final taskData = task.data() as Map<String, dynamic>;
                  final title = taskData['titleTask'] ?? 'Sans titre';
                  final dueDate = _convertToDateTime(taskData['datEchea']);
                  final isLate = isTaskLate(taskData);
                  final isThisWeek = isDueThisWeek(dueDate);
                  final priorityIcon =
                      getPriorityIcon(taskData['priorityTask'] ?? 'unknown');

                  return Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16.0, vertical: 4.0),
                    child: Card(
                      elevation: isThisWeek ? 5 : 3,
                      color: isThisWeek ? Colors.blue[50] : Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: ListTile(
                        // Icône de priorité
                        leading: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [priorityIcon],
                        ),
                        // Titre de la tâche
                        title: Text(
                          title,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: isLate ? Colors.red : Colors.black,
                            decoration: isLate
                                ? TextDecoration.lineThrough
                                : TextDecoration.none,
                          ),
                        ),
                        // Date d'échéance
                        subtitle: Text(
                          'Échéance: ${_formatDate(dueDate)}',
                          style: const TextStyle(color: Colors.grey),
                        ),
                        // Case à cocher pour terminer une tâche
                        trailing: Checkbox(
                          value: taskData['statut'] == 'Terminé',
                          onChanged: (value) {
                            if (value == true) {
                              _firestore
                                  .collection('Tasks')
                                  .doc(task.id)
                                  .update({'statut': 'Terminé'}).then((_) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                        'Tâche archivée dans l\'historique.'),
                                  ),
                                );
                              });
                            }
                          },
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ],
            );
          }).toList(),
        );
      },
    );
  }

  // Construire l'agenda avec TableCalendar
  Widget _buildAgenda() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          const Text(
            'Mon Agenda',
            style: TextStyle(
              fontSize: 24.0,
              fontWeight: FontWeight.bold,
              color: Colors.teal,
            ),
          ),
          const SizedBox(height: 16.0),
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
              calendarStyle: const CalendarStyle(
                selectedDecoration: BoxDecoration(
                  color: Colors.teal,
                  shape: BoxShape.circle,
                ),
                todayDecoration: BoxDecoration(
                  color: Colors.blue,
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
        ],
      ),
    );
  }

  // Gestion du corps de la page selon l'onglet actif
  Widget _getBody() {
    switch (_selectedIndex) {
      case 1:
        return _buildAgenda();
      case 0:
      default:
        return _buildTasksByMonth();
    }
  }

  // Conversion des dates pour le tri et la validation
  DateTime _convertToDateTime(dynamic date) {
    if (date is Timestamp) {
      return date.toDate();
    } else if (date is String) {
      return DateTime.parse(date);
    } else {
      return DateTime(2100);
    }
  }

  // Récupérer le nom d'un mois
  String _getMonthName(int month) {
    const months = [
      'Janvier',
      'Février',
      'Mars',
      'Avril',
      'Mai',
      'Juin',
      'Juillet',
      'Août',
      'Septembre',
      'Octobre',
      'Novembre',
      'Décembre'
    ];
    return months[month - 1];
  }

  // Formater une date en chaîne lisible
  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Page Étudiant'),
        backgroundColor: Colors.teal,
        centerTitle: true,
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
              }  else if (value == 'Note') {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AddNotePage(
                        userId: widget.userId), 
                  ),
                );
              }else if (value == 'Notes') {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ViewNotesPage(
                        userId: widget.userId), 
                  ),
                );
              }else if (value == 'logout') {
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
      body: _getBody(),
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
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.list),
            label: 'Tâches',
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
