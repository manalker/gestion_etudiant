import 'package:flutter/material.dart';
import 'package:student_manager/Pages/add_task_page.dart';
import 'package:student_manager/Pages/view_tasks_page.dart';

class EtudPage extends StatelessWidget {
  final String userId; // Paramètre pour stocker l'ID utilisateur

  const EtudPage({Key? key, required this.userId}) : super(key: key);

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
                // Rediriger vers la liste des tâches
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ViewTasksPage(userId: userId),
                  ),
                );
              } else if (value == 'logout') {
                // Déconnexion
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  '/',
                  (route) => false,
                );
              }
            },
            itemBuilder: (BuildContext context) {
              return [
                const PopupMenuItem<String>(
                  value: 'tasks',
                  child: Text('Liste des tâches'),
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const SizedBox(height: 20),
            // Titre principal
            const Text(
              'Bienvenue dans l’espace Étudiant : ',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.teal,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            const Text(
              'Choisissez une action à effectuer.',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 40),

            // Bouton pour ajouter une tâche
            _buildActionCard(
              context,
              icon: Icons.task,
              title: 'Ajouter une tâche',
              description: 'Créer une nouvelle tâche.',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AddTaskPage(userId: userId),
                  ),
                );
              },
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // Widget personnalisé pour les actions
  Widget _buildActionCard(BuildContext context,
      {required IconData icon,
      required String title,
      required String description,
      required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              blurRadius: 10,
              spreadRadius: 5,
            ),
          ],
        ),
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            // Icône principale
            CircleAvatar(
              radius: 30,
              backgroundColor: Colors.teal.withOpacity(0.1),
              child: Icon(icon, color: Colors.teal, size: 30),
            ),
            const SizedBox(width: 20),

            // Texte descriptif
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, color: Colors.grey, size: 20),
          ],
        ),
      ),
    );
  }
}
