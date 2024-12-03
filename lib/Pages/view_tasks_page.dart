import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ViewTasksPage extends StatefulWidget {
  const ViewTasksPage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _ViewTasksPageState createState() => _ViewTasksPageState();
}

class _ViewTasksPageState extends State<ViewTasksPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Supprimer une tâche
  Future<void> deleteTask(String taskId) async {
    try {
      await _firestore.collection('Tasks').doc(taskId).delete();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tâche supprimée avec succès !')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur lors de la suppression : ${e.toString()}'),
        ),
      );
    }
  }

  // Function to get color based on priority
  Color getPriorityColor(String priority) {
    switch (priority.toLowerCase()) {
      case 'haute':
        return Colors.red; // High priority - red
      case 'moyenne':
        return Colors.orange; // Medium priority - orange
      case 'faible':
        return Colors.green; // Low priority - green
      default:
        return Colors.grey; // Default - grey
    }
  }

  // Function to get icon based on task status
  Icon getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'en cours': // In progress
        return const Icon(Icons.timelapse,
            color: Colors.blue); // Icon color for "En cours"
      case 'terminé': // Completed
        return const Icon(Icons.check_circle,
            color: Colors.green); // Icon color for "Terminé"
      case 'en retard': // Late
        return const Icon(Icons.error,
            color: Colors.red); // Icon color for "En retard"
      case 'en attente': // Pending
        return const Icon(Icons.hourglass_empty,
            color: Colors.orange); // Icon color for "En attente"
      default:
        return const Icon(Icons.help,
            color: Colors.grey); // Default: Unknown status
    }
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
        stream: _firestore.collection('Tasks').snapshots(),
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

          return ListView.builder(
            itemCount: tasks.length,
            itemBuilder: (context, index) {
              final task = tasks[index];
              final taskData = task.data() as Map<String, dynamic>;

              // Get priority color for the current task
              // ignore: unused_local_variable
              final Color priorityColor =
                  getPriorityColor(taskData['priorityTask'] ?? 'low');

              // Get the status icon for the current task
              final Icon statusIcon =
                  getStatusIcon(taskData['statut'] ?? 'unknown');

              return Card(
                margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                elevation: 3,
                child: ListTile(
                  title: Text(
                    taskData['titleTask'] ?? 'No title',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                          'Catégorie: ${taskData['cathegTask'] ?? 'No category'}'),
                      Text(
                          'Priorité: ${taskData['priorityTask'] ?? 'No priority'}'),
                    ],
                  ),
                  leading: CircleAvatar(
                    backgroundColor: Colors.transparent, // No background color
                    child: statusIcon, // Colored icon based on status
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () async {
                      final confirm = await showDialog<bool>(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            title: const Text('Confirmation'),
                            content: const Text(
                                'Voulez-vous vraiment supprimer cette tâche ?'),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context, false),
                                child: const Text('Annuler'),
                              ),
                              TextButton(
                                onPressed: () => Navigator.pop(context, true),
                                child: const Text('Supprimer'),
                              ),
                            ],
                          );
                        },
                      );

                      if (confirm == true) {
                        deleteTask(task.id);
                      }
                    },
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
