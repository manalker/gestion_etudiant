import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:student_manager/Pages/etud_page.dart';
import 'package:student_manager/Pages/task_details_page.dart';
import 'package:student_manager/Pages/AgendaPage.dart';
import 'package:student_manager/Pages/add_note_page.dart';
import 'package:student_manager/Pages/view_notes_page.dart';
import 'package:student_manager/Pages/HistoryPage.dart';
import 'package:student_manager/Pages/view_tasks_page.dart';

class SearchPage extends StatefulWidget {
  final String userId;

  const SearchPage({Key? key, required this.userId}) : super(key: key);

  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _searchController =
      TextEditingController(); // Contrôleur pour gérer le champ de recherche
  List<Map<String, dynamic>> _allTasks = []; // Liste de toutes les tâches
  List<Map<String, dynamic>> _filteredTasks =
      []; // Liste des tâches filtrées selon la recherche
  int _selectedIndex = 2; // Onglet "Rechercher" par défaut

  @override
  void initState() {
    super.initState();
    _loadAllTasks(); // Charger toutes les tâches lors de l'initialisation
  }

  // Charger toutes les tâches de Firestore
  Future<void> _loadAllTasks() async {
    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('Tasks')
          .where('owner', isEqualTo: widget.userId)
          .get();

      final tasks = querySnapshot.docs.map((doc) {
        final data = doc.data();
        return {
          'id': doc.id,
          'title': data['titleTask'] ?? 'Sans titre',
          'desc': data['descTask'] ?? 'Pas de description',
          'priority': data['priorityTask'] ?? 'unknown',
          'datEchea': data['datEchea'] ?? null,
          'status': data['statut'] ?? 'En attente',
          'cathegTask': data['cathegTask'] ?? 'Sans catégorie',
          'datCreation': data['datCreation'] ?? 'Non défini',
          'datArchiv': data['datArchiv'] ?? 'Non défini',
        };
      }).toList();

      setState(() {
        _allTasks = tasks;
        _filteredTasks = tasks; // Initialiser avec toutes les tâches
      });
    } catch (e) {
      print("Erreur lors du chargement des tâches : $e");
    }
  }

  // Filtrer les tâches selon le texte de recherche
  void _filterTasks(String query) {
    setState(() {
      _filteredTasks = _allTasks.where((task) {
        final title = task['title'].toLowerCase();
        final desc = task['desc'].toLowerCase();
        final priority = task['priority'].toLowerCase();
        final status = task['status'].toLowerCase();

        return title.contains(query.toLowerCase()) ||
            desc.contains(query.toLowerCase()) ||
            priority.contains(query.toLowerCase()) ||
            status.contains(query.toLowerCase());
      }).toList();
    });
  }

  // Navigation entre les onglets
  void _onItemTapped(int index) {
    if (index == 0) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => EtudPage(userId: widget.userId),
        ),
      );
    } else if (index == 1) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => AgendaPage(
            userId: widget.userId,
            events: {},
          ),
        ),
      );
    } else if (index == 2) {
      setState(() {
        _selectedIndex = index;
      });
    }
  }

  @override
  void dispose() {
    _searchController.dispose(); // Libérer les ressources du contrôleur
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Rechercher'), // Titre de la page
        backgroundColor: Colors.teal,
        centerTitle: true,
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'tasks') {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ViewTasksPage(userId: widget.userId),
                  ),
                );
              } else if (value == 'history') {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => HistoryPage(userId: widget.userId),
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
          // Champ de recherche
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              onChanged: _filterTasks,
              decoration: InputDecoration(
                hintText:
                    'Rechercher par titre, description, priorité ou statut...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),
          // Liste des résultats de recherche
          Expanded(
            child: _filteredTasks.isNotEmpty
                ? ListView.builder(
                    itemCount: _filteredTasks.length,
                    itemBuilder: (context, index) {
                      final task = _filteredTasks[index];

                      // Déterminer l'icône en fonction de la priorité
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

                      return Card(
                        elevation: 3,
                        margin: const EdgeInsets.symmetric(
                            vertical: 8.0, horizontal: 16.0),
                        child: ListTile(
                          leading: priorityIcon,
                          title: Text(task['title']),
                          subtitle: Text('Description: ${task['desc']}'),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => TaskDetailsPage(
                                  taskData: {
                                    'titleTask': task['title'] ?? 'Sans titre',
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
                                    'heureTask': 'Non défini',
                                    'cathegTask':
                                        task['cathegTask'] ?? 'Sans catégorie',
                                  },
                                  taskId: task['id'],
                                ),
                              ),
                            );
                          },
                        ),
                      );
                    },
                  )
                : const Center(
                    child: Text(
                      'Aucun résultat trouvé.',
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  ),
          ),
        ],
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
