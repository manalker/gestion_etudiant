import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:student_manager/Pages/AgendaPage.dart';
import 'package:student_manager/Pages/HistoryPage.dart';
import 'package:student_manager/Pages/SearchPage.dart';
import 'package:student_manager/Pages/add_task_page.dart';
import 'package:student_manager/Pages/view_tasks_page.dart';
import 'package:student_manager/Pages/add_note_page.dart';
import 'package:student_manager/Pages/view_notes_page.dart';

class EtudPage extends StatefulWidget {
  final String userId; // Identifiant unique de l'utilisateur connecté

  const EtudPage({super.key, required this.userId});

  @override
  // ignore: library_private_types_in_public_api
  _EtudPageState createState() => _EtudPageState();
}

class _EtudPageState extends State<EtudPage> {
  int _selectedIndex = 0; // Index de l'onglet sélectionné
// Tâches par date

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    _loadTasks();
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
          'status': data['statut'] ?? 'En attente',
          'priority': data['priorityTask'] ?? 'unknown'
        };
        if (tasks[date] == null) {
          tasks[date] = [task];
        } else {
          tasks[date]!.add(task);
        }
      }
    }

    setState(() {});
  }

  void _onItemTapped(int index) {
    if (index == 1) {
      // Naviguer vers la page "Agenda"
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => AgendaPage(
            userId: widget.userId,
            events: const {}, // Vous pouvez passer des événements réels ici
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
    } else {
      // Met à jour l'index sélectionné pour les autres onglets
      setState(() {
        _selectedIndex = index;
      });
    }
  }

  // Construire la liste des tâches triées par mois
  Widget _buildTasksByMonth() {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestore
          .collection('Tasks')
          .where('owner', isEqualTo: widget.userId)
          .where('statut', whereIn: ['En cours', 'En attente']).snapshots(),
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

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                      vertical: 10.0, horizontal: 16.0),
                  child: Text(
                    month,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.teal,
                    ),
                  ),
                ),
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

  // Conversion des dates pour le tri et la validation
  DateTime _convertToDateTime(dynamic date) {
    if (date is Timestamp) {
      return date.toDate();
    } else if (date is String) {
      return DateTime.parse(date);
    } else {
      throw Exception("Format de date invalide");
    }
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
      body: _buildTasksByMonth(),
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
        onTap: _onItemTapped, // Appelle la méthode _onItemTapped
      ),
    );
  }
}
