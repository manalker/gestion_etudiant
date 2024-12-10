import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class NoteDetailsPage extends StatelessWidget {
  final Map<String, dynamic> noteData;
  final String noteId;

  const NoteDetailsPage({
    Key? key,
    required this.noteData,
    required this.noteId,
    required Map NoteData,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Détails de la note'),
        backgroundColor: Colors.indigo, // Nouvelle couleur de l'AppBar
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Carte pour le titre
              _buildCard(
                title: "Titre",
                content: noteData['titleNote'] ?? 'Titre non disponible',
                icon: Icons.title,
              ),
              const SizedBox(height: 16),

              // Carte pour la note (plus grande taille)
              Card(
                margin: const EdgeInsets.symmetric(vertical: 8.0),
                elevation: 2,
                child: ListTile(
                  title: const Text(
                    'Note :',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    noteData['note'], // La note, telle qu'elle est dans Firestore
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Carte pour la date
              _buildCard(
                title: "Date de création",
                content: _formatDate(noteData['datCreation']),
                icon: Icons.calendar_today,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Widget générique pour créer une carte
  Widget _buildCard({
    required String title,
    required String content,
    required IconData icon,
    bool isLarge = false, // Nouvelle propriété pour la taille de la carte
  }) {
    return Card(
      elevation: 4,
      color: Colors.white, // Nouvelle couleur de fond des cartes
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon,
                size: 32, color: Colors.indigo), // Icône avec couleur indigo
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.indigo, // Couleur indigo pour le texte
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    content,
                    style: TextStyle(
                      fontSize: 16,
                      height: isLarge
                          ? 1.5
                          : 1, // Plus de hauteur si c'est une carte grande
                    ),
                    overflow: TextOverflow
                        .ellipsis, // Pour limiter le texte si trop long
                    maxLines: isLarge
                        ? null
                        : 2, // Plus de lignes pour les notes longues
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Fonction pour formater la date
  String _formatDate(dynamic field) {
    if (field is Timestamp) {
      return field.toDate().toLocal().toString().split(' ')[0];
    } else if (field is String) {
      try {
        DateTime date = DateTime.parse(field);
        return date.toLocal().toString().split(' ')[0];
      } catch (e) {
        return 'Date non définie';
      }
    } else {
      return 'Date non définie';
    }
  }
}
