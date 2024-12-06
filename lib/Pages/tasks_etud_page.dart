/*import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ViewEtuTasksPage extends StatefulWidget {
  final String userId;

  const ViewEtuTasksPage({Key? key, required this.userId}) : super(key: key);

  @override
  _ViewEtuTasksPageState createState() => _ViewEtuTasksPageState();
}

class _ViewEtuTasksPageState extends State<ViewEtuTasksPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final Map<String, bool> taskCompletion = {};

  // Fonction pour formater la date
  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')} ${_getMonthName(date.month)} ${date.year}';
  }

  // Fonction pour obtenir le nom du mois
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Liste des Tâches'),
        backgroundColor: Colors.teal,
        centerTitle: true,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore
            .collection('Tasks')
            .where('owner', isEqualTo: widget.userId) // Filtrer par utilisateur
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Erreur : ${snapshot.error}'));
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('Aucune tâche trouvée.'));
          }

          final tasks = snapshot.data!.docs;

          // Grouper les tâches par mois
          final Map<String, List<Map<String, dynamic>>> tasksByMonth = {};
          for (var task in tasks) {
            final taskData = task.data() as Map<String, dynamic>;

            // Vérification des champs nécessaires
            if (taskData.containsKey('dueDate') &&
                taskData['dueDate'] != null) {
              final dueDate = (taskData['dueDate'] as Timestamp).toDate();
              final monthKey =
                  '${dueDate.year}-${dueDate.month.toString().padLeft(2, '0')}';

              tasksByMonth.putIfAbsent(monthKey, () => []).add({
                'id': task.id,
                'title': taskData['titleTask'] ?? 'Tâche sans titre',
                'dueDate': dueDate,
                'completed': taskCompletion[task.id] ?? false,
              });
            }
          }

          return ListView(
            padding: const EdgeInsets.all(16.0),
            children: tasksByMonth.entries.map((entry) {
              final monthKey = entry.key;
              final taskList = entry.value;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // En-tête pour le mois
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Text(
                      '${_getMonthName(int.parse(monthKey.split('-')[1]))} ${monthKey.split('-')[0]}',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.teal,
                      ),
                    ),
                  ),
                  // Liste des tâches pour ce mois
                  ...taskList.map((task) {
                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 8.0),
                      elevation: 2,
                      child: ListTile(
                        leading: Checkbox(
                          value: task['completed'],
                          onChanged: (value) {
                            setState(() {
                              taskCompletion[task['id']] = value ?? false;
                            });
                          },
                        ),
                        title: Text(
                          task['title'],
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        subtitle: Text(
                          'Échéance : ${_formatDate(task['dueDate'])}',
                          style: const TextStyle(color: Colors.grey),
                        ),
                      ),
                    );
                  }).toList(),
                ],
              );
            }).toList(),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Action pour ajouter une tâche
          // Vous pouvez ajouter une navigation ici si nécessaire
        },
        backgroundColor: Colors.teal,
        child: const Icon(Icons.add),
      ),
    );
  }
}
*/