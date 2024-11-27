import 'package:flutter/material.dart' show AppBar, BorderRadius, BoxDecoration, BoxShadow, BuildContext, CircleAvatar, Colors, Column, Container, CrossAxisAlignment, EdgeInsets, Expanded, FontWeight, Icon, IconData, Icons, InkWell, Navigator, Padding, Row, Scaffold, SizedBox, StatelessWidget, Text, TextAlign, TextStyle, VoidCallback, Widget;

class AdminPage extends StatelessWidget {
  const AdminPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Espace Admin'),
        backgroundColor: Colors.teal,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const SizedBox(height: 20),
            // Titre principal
            const Text(
              'Bienvenue dans l’espace Admin',
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

            // Bouton pour consulter les utilisateurs
            _buildActionCard(
              context,
              icon: Icons.group,
              title: 'Consulter les utilisateurs',
              description: 'Voir et gérer les utilisateurs existants.',
              onTap: () {
                Navigator.pushNamed(context, '/view_users');
              },
            ),
            const SizedBox(height: 20),

            // Bouton pour ajouter un utilisateur
            _buildActionCard(
              context,
              icon: Icons.person_add,
              title: 'Ajouter un utilisateur',
              description: 'Créer un nouveau compte utilisateur.',
              onTap: () {
                Navigator.pushNamed(context, '/add_user');
              },
            ),
            const SizedBox(height: 20),

            // Bouton pour consulter les tâches
            _buildActionCard(
              context,
              icon: Icons.task,
              title: 'Consulter les tâches',
              description: 'Voir et gérer vos tâches',
              onTap: () {
                Navigator.pushNamed(context, '/view_tasks');
              },
            ),
            const SizedBox(height: 20),
 
            // Bouton pour ajouter une tâche
             _buildActionCard(
              context,
              icon: Icons.add_task,
              title: 'Ajouter une tâche',
              description: 'Ajouter une nouvelle tâche .',
              onTap: () {
                Navigator.pushNamed(context, '/add_task');
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
