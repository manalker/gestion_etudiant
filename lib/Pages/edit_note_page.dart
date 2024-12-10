import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class EditNotePage extends StatefulWidget {
  final String noteId;
  final Map<String, dynamic> noteData;

  const EditNotePage({Key? key, required this.noteId, required this.noteData, required Map NoteData})
      : super(key: key);

  @override
  State<EditNotePage> createState() => _EditNotePageState();
}

class _EditNotePageState extends State<EditNotePage> {
  late TextEditingController _titleController;
  late TextEditingController _noteController;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();

    // Préremplir les champs avec les données existantes
    _titleController =
        TextEditingController(text: widget.noteData['titleNote'] ?? '');
    _noteController =
        TextEditingController(text: widget.noteData['note'] ?? '');
  }

  Future<void> updateNote() async {
    try {
      await _firestore.collection('Notes').doc(widget.noteId).update({
        'titleNote': _titleController.text,
        'note': _noteController.text,
        'datModification': DateTime.now().toIso8601String(),
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Note mise à jour avec succès !')),
      );
      Navigator.pop(context); // Retour à la page précédente
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur : ${e.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Modifier la note'),
        backgroundColor: Colors.teal,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Champ modifiable pour le titre
            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: TextFormField(
                  controller: _titleController,
                  decoration: const InputDecoration(
                    labelText: 'Titre',
                    border: InputBorder.none,
                  ),
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Champ modifiable pour la note
            Expanded(
              child: Card(
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: TextFormField(
                    controller: _noteController,
                    decoration: const InputDecoration(
                      labelText: 'Contenu de la note',
                      border: InputBorder.none,
                    ),
                    maxLines: null, // Permet d'ajouter autant de lignes que nécessaire
                    expands: true, // Remplit tout l'espace disponible
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Bouton pour enregistrer les modifications
            ElevatedButton(
              onPressed: updateNote,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
              ),
              child: const Text(
                'Enregistrer les modifications',
                style: TextStyle(fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
