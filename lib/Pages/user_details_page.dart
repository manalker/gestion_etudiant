import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UserDetailsPage extends StatelessWidget {
  final DocumentSnapshot user;

  // Le constructeur reçoit un document utilisateur depuis Firestore
  const UserDetailsPage({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    // Extraction des données utilisateur depuis le document Firestore
    final userData = user.data() as Map<String, dynamic>;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Détails de l’utilisateur'),
        backgroundColor: Colors.teal,
        centerTitle: true, // Centre le titre dans la barre d'applications
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Affichage de l'avatar de l'utilisateur
            CircleAvatar(
              radius: 50,
              backgroundColor: Colors.teal.withOpacity(0.2),
              child: Icon(
                // Icône différente en fonction du statut de l'utilisateur
                userData['statut'] == true
                    ? Icons.admin_panel_settings // Icône pour admin
                    : Icons.person, // Icône pour étudiant
                size: 50,
                color: Colors.teal,
              ),
            ),
            const SizedBox(height: 16),

            // Affichage du prénom et nom de l'utilisateur
            Text(
              '${userData['prenomUser']} ${userData['nomUser']}',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.teal,
              ),
            ),
            const SizedBox(height: 8),

            // Affichage du statut (admin ou étudiant)
            Text(
              userData['statut'] == true ? 'Admin' : 'Étudiant',
              style: const TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 30),

            // Tableau contenant les détails utilisateur
            Card(
              elevation: 4, // Ajoute une ombre pour un effet 3D
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12), // Coins arrondis
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Table(
                  columnWidths: const {
                    0: FlexColumnWidth(1), // Première colonne plus étroite
                    1: FlexColumnWidth(2), // Deuxième colonne plus large
                  },
                  border: TableBorder.all(
                    color: Colors.grey, // Couleur des bordures du tableau
                    width: 1,
                    borderRadius:
                        BorderRadius.circular(8), // Bordures arrondies
                  ),
                  children: [
                    // Ajout de chaque ligne avec les données utilisateur
                    _buildTableRow('Nom', userData['nomUser']),
                    _buildTableRow('Prénom', userData['prenomUser']),
                    _buildTableRow('Email', userData['email']),
                    _buildTableRow(
                      'Statut',
                      userData['statut'] == true ? 'Admin' : 'Étudiant',
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Méthode utilitaire pour créer une ligne dans le tableau
  TableRow _buildTableRow(String label, String value) {
    return TableRow(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            label, // Nom de l'attribut
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.teal,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            value, // Valeur de l'attribut
            style: const TextStyle(fontSize: 16, color: Colors.black),
          ),
        ),
      ],
    );
  }
}
