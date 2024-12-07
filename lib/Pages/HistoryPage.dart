import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class HistoryPage extends StatefulWidget {
  final String userId;

  const HistoryPage({super.key, required this.userId});

  @override
  // ignore: library_private_types_in_public_api
  _HistoryPageState createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Réactiver une tâche (mettre son statut à "En cours")
  Future<void> restartTask(String taskId) async {
    try {
      await _firestore.collection('Tasks').doc(taskId).update({
        'statut': 'En cours', // Modifier le statut à "En cours"
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tâche relancée avec succès !')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur : ${e.toString()}')),
      );
    }
  }

  // Supprimer une tâche de l'historique
  Future<void> deleteTask(String taskId) async {
    try {
      await _firestore.collection('Tasks').doc(taskId).delete();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tâche supprimée avec succès !')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur : ${e.toString()}')),
      );
    }
  }

  // Obtenir l'icône associée au statut d'une tâche
  Icon getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'en cours':
        return const Icon(Icons.timelapse, color: Colors.blue);
      case 'terminé':
        return const Icon(Icons.check_circle, color: Colors.green);
      case 'en retard':
        return const Icon(Icons.error, color: Colors.red);
      case 'en attente':
        return const Icon(Icons.hourglass_empty, color: Colors.orange);
      default:
        return const Icon(Icons.help, color: Colors.grey);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Historique des Tâches'), // Titre de la page
        backgroundColor: Colors.teal,
        centerTitle: true,
      ),
      body: StreamBuilder<QuerySnapshot>(
        // Charger uniquement les tâches terminées pour cet utilisateur
        stream: _firestore
            .collection('Tasks')
            .where('owner', isEqualTo: widget.userId) // Filtrer par utilisateur
            .where('statut', isEqualTo: 'Terminé') // Filtrer par statut
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
                child: CircularProgressIndicator()); // Chargement
          }

          if (snapshot.hasError) {
            return Center(
                child: Text('Erreur : ${snapshot.error}')); // Afficher l'erreur
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text('Aucune tâche terminée trouvée.'), // Si aucune tâche
            );
          }

          final tasks = snapshot.data!.docs;

          return ListView.builder(
            itemCount: tasks.length,
            itemBuilder: (context, index) {
              final task = tasks[index];
              final taskData = task.data() as Map<String, dynamic>;

              // Récupérer l'icône du statut de la tâche
              final Icon statusIcon =
                  getStatusIcon(taskData['statut'] ?? 'unknown');

              return Card(
                margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                elevation: 3,
                child: ListTile(
                  // Titre de la tâche
                  title: Text(
                    taskData['titleTask'] ?? 'Pas de titre',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  // Catégorie et priorité dans les sous-titres
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                          'Catégorie: ${taskData['cathegTask'] ?? 'Pas de catégorie'}'),
                      Text(
                          'Priorité: ${taskData['priorityTask'] ?? 'Pas de priorité'}'),
                    ],
                  ),
                  // Icône indiquant le statut de la tâche
                  leading: CircleAvatar(
                    backgroundColor: Colors.transparent,
                    child: statusIcon, // Icône de statut
                  ),
                  // Actions pour chaque tâche
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Icône pour relancer une tâche
                      IconButton(
                        icon: const Icon(Icons.restart_alt, color: Colors.blue),
                        onPressed: () async {
                          final confirm = await showDialog<bool>(
                            context: context,
                            builder: (context) {
                              return AlertDialog(
                                title: const Text('Confirmation'),
                                content: const Text(
                                    'Voulez-vous vraiment relancer cette tâche ?'),
                                actions: [
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.pop(context, false),
                                    child: const Text('Annuler'),
                                  ),
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.pop(context, true),
                                    child: const Text('Relancer'),
                                  ),
                                ],
                              );
                            },
                          );

                          if (confirm == true) {
                            restartTask(
                                task.id); // Appel pour relancer la tâche
                          }
                        },
                      ),
                      // Icône pour supprimer une tâche
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
                            deleteTask(
                                task.id); // Appel pour supprimer la tâche
                          }
                        },
                      ),
                    ],
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
