import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:student_manager/Pages/edit_task_page.dart';
import 'package:student_manager/Pages/task_details_page.dart'; // Import pour la page de détails

class ViewTasksPage extends StatefulWidget {
  final String userId; // L'ID de l'utilisateur
  final bool
      showCompleted; // Indique si on affiche uniquement les tâches terminées

  const ViewTasksPage(
      {super.key, required this.userId, this.showCompleted = false});

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
  Future<bool> taskHasNotification(String taskId) async {
    final querySnapshot = await _firestore
        .collection('Notifs')
        .where('id_tache', isEqualTo: taskId)
        .get();

    return querySnapshot.docs.isNotEmpty;
  }
  Future<void> addNotification({
  required String idTache,
  required String owner,
  required DateTime dateNotif,
  required bool is_read,
}) async {
  final notifsCollection = FirebaseFirestore.instance.collection('Notifs');
  await notifsCollection.add({
    'id_tache': idTache,
    'owner': owner,
    'date_notif': Timestamp.fromDate(dateNotif),
    'is_read': is_read,
  });
}
  // Sélecteurs pour la date et l'heure
  DateTime selectedDate = DateTime.now();
  TimeOfDay selectedTime = TimeOfDay.now();
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (pickedDate != null && pickedDate != selectedDate) {
      setState(() {
        selectedDate = pickedDate;
      });
    }
  }
  Future<void> _selectTime(BuildContext context) async {
    final pickedTime = await showTimePicker(
      context: context,
      initialTime: selectedTime,
    );
    if (pickedTime != null) {
      setState(() {
        selectedTime = pickedTime;
      });
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
        return const Icon(Icons.timelapse,
            color: Colors.blue); // Icone pour "En cours"
      case 'terminé':
        return const Icon(Icons.check_circle,
            color: Colors.green); // Icone pour "Terminé"
      case 'en retard':
        return const Icon(Icons.error,
            color: Colors.red); // Icone pour "En retard"
      case 'en attente':
        return const Icon(Icons.hourglass_empty,
            color: Colors.orange); // Icone pour "En attente"
      default:
        return const Icon(Icons.help, color: Colors.grey); // Par défaut
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.showCompleted
            ? 'Historique des Tâches'
            : 'Liste des Tâches'),
        backgroundColor: Colors.teal,
        centerTitle: true,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore
            .collection('Tasks')
            .where('owner',
                isEqualTo: widget.userId) // Filtrer les tâches par userId
            .where('statut',
                isEqualTo: widget.showCompleted
                    ? 'Terminé'
                    : null) // Filtrer selon le statut
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Erreur : ${snapshot.error}'));
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Text(
                widget.showCompleted
                    ? 'Aucune tâche terminée.'
                    : 'Aucune tâche trouvée.',
                style: const TextStyle(fontSize: 16, color: Colors.grey),
              ),
            );
          }

          final tasks = snapshot.data!.docs;

          return ListView.builder(
            itemCount: tasks.length,
            itemBuilder: (context, index) {
              final task = tasks[index];
              final taskData = task.data() as Map<String, dynamic>;
return FutureBuilder<bool>(
                future: taskHasNotification(task.id),
                builder: (context, notificationSnapshot) {
                  if (!notificationSnapshot.hasData) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }
final hasNotification = notificationSnapshot.data!;
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
                       IconButton(
                            icon: Icon(hasNotification
                                  ? Icons.notifications_active
                                  : Icons.notifications,
                              color: hasNotification ? Colors.green : Colors.grey,
                            ),
                            onPressed: hasNotification
                                ? null
                                : () async {
                                    await _selectDate(context);
                                    await _selectTime(context);

                                    final notificationDateTime = DateTime(
                                      selectedDate.year,
                                      selectedDate.month,
                                      selectedDate.day,
                                      selectedTime.hour,
                                      selectedTime.minute,
                                    );

                                    await addNotification(
                                      idTache: task.id,
                                      owner: widget.userId,
                                      dateNotif: notificationDateTime,
                                      is_read: false,
                                    );

                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('Notification ajoutée !'),
                                      ),
                                    );
                                    setState(() {});
                                  },
                          ),
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
        );
      },
    ),
  );
}
}