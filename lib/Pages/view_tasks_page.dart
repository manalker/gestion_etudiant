import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:student_manager/Pages/edit_task_page.dart';
import 'package:student_manager/Pages/task_details_page.dart'; // Import pour la page de détails

class ViewTasksPage extends StatefulWidget {
  final String userId; // L'ID de l'utilisateur

  const ViewTasksPage({super.key, required this.userId});

  @override
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

  // Fonction pour obtenir la couleur en fonction de la priorité
  Color getPriorityColor(String priority) {
    switch (priority.toLowerCase()) {
      case 'haute':
        return Colors.red; // Haute priorité - rouge
      case 'moyenne':
        return Colors.orange; // Priorité moyenne - orange
      case 'faible':
        return Colors.green; // Faible priorité - vert
      default:
        return Colors.grey; // Par défaut - gris
    }
  }

  // Fonction pour obtenir l'icône en fonction du statut de la tâche
  Icon getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'en cours':
        return Icon(Icons.timelapse,
            color: Colors.blue); // Icone pour "En cours"
      case 'terminé':
        return Icon(Icons.check_circle,
            color: Colors.green); // Icone pour "Terminé"
      case 'en retard':
        return Icon(Icons.error, color: Colors.red); // Icone pour "En retard"
      case 'en attente':
        return Icon(Icons.hourglass_empty,
            color: Colors.orange); // Icone pour "En attente"
      default:
        return Icon(Icons.help, color: Colors.grey); // Par défaut
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
        stream: _firestore
            .collection('Tasks')
            .where('owner',
                isEqualTo: widget.userId) // Filtrer les tâches par userId
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

          return ListView.builder(
            itemCount: tasks.length,
            itemBuilder: (context, index) {
              final task = tasks[index];
              final taskData = task.data() as Map<String, dynamic>;

              // Obtenir l'icône de statut pour la tâche actuelle
              final Icon statusIcon =
                  getStatusIcon(taskData['statut'] ?? 'unknown');

              return Card(
                margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                elevation: 3,
                child: ListTile(
                  title: Text(
                    taskData['titleTask'] ?? 'Pas de titre',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                          'Catégorie: ${taskData['cathegTask'] ?? 'Pas de catégorie'}'),
                      Text(
                          'Priorité: ${taskData['priorityTask'] ?? 'Pas de priorité'}'),
                    ],
                  ),
                  leading: CircleAvatar(
                    backgroundColor:
                        Colors.transparent, // Pas de couleur de fond
                    child: statusIcon, // Icône colorée selon le statut
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Icone d'édition
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blue),
                        onPressed: () {
                          // Navigation vers la page d'édition
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => EditTaskPage(
                                taskId: task.id,
                                taskData: taskData,
                              ),
                            ),
                          );
                        },
                      ),
                      // Icone de suppression
                      IconButton(
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
                                    onPressed: () =>
                                        Navigator.pop(context, false),
                                    child: const Text('Annuler'),
                                  ),
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.pop(context, true),
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
                    ],
                  ),
                  onTap: () {
                    // Naviguer vers la page des détails de la tâche
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => TaskDetailsPage(
                          taskData: taskData,
                          taskId: task
                              .id, // Pass the Firestore document ID as taskId
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
