import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AddNotePage extends StatefulWidget {
  final String userId; // userId est passé ici par le parent
  const AddNotePage({Key? key, required this.userId}) : super(key: key);

  @override
  _AddNotePageState createState() => _AddNotePageState();
}

class _AddNotePageState extends State<AddNotePage> {
  final _formKey = GlobalKey<FormState>();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String titleNote = '';
  String note = '';
  DateTime? datCreation;

  // Fonction pour ajouter une tâche à la base de données
  Future<void> addNote() async {
    if (_formKey.currentState!.validate()) {
      try {
        // Ajout de la tâche avec la date de création actuelle
        await _firestore.collection('Notes').add({
          'owner': widget
              .userId, // Utilisation correcte de l'ID de l'utilisateur connecté
          'titleNote': titleNote,
          'note': note,
          'datCreation':
              DateTime.now().toIso8601String(), // Date et heure actuelles
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Note ajoutée avec succès !')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur : ${e.toString()}')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ajouter une tâche'),
        backgroundColor: Colors.teal,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Remplissez les informations de la tâche :',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),

                // Champ Titre
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Titre de la note',
                    prefixIcon: Icon(Icons.title),
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Veuillez entrer un titre';
                    }
                    return null;
                  },
                  onChanged: (value) => titleNote = value,
                ),
                const SizedBox(height: 20),

                TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Note',
                    prefixIcon: Icon(Icons.description),
                    border: OutlineInputBorder(),
                  ),
                  maxLines: null, // Permet un champ multi-lignes illimité
                  keyboardType: TextInputType.multiline,
                  onChanged: (value) => note = value,
                ),

                const SizedBox(height: 20),

                // Bouton pour ajouter la note
                Center(
                  child: ElevatedButton(
                    onPressed: addNote,
                    child: const Text('Ajouter la note'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
