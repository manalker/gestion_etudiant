import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:student_manager/Pages/edit_note_page.dart';
import 'package:student_manager/Pages/note_details_page.dart';// Import pour la page de détails

class ViewNotesPage extends StatefulWidget {
  final String userId; // L'ID de l'utilisateur

  const ViewNotesPage({super.key, required this.userId});

  @override
  _ViewNotesPageState createState() => _ViewNotesPageState();
}

class _ViewNotesPageState extends State<ViewNotesPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Supprimer une tâche
  Future<void> deleteNote(String noteId) async {
    try {
      await _firestore.collection('Notes').doc(noteId).delete();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Notes supprimée avec succès !')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur lors de la suppression : ${e.toString()}'),
        ),
      );
    }
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Liste des Notes'),
        backgroundColor: Colors.teal,
        centerTitle: true,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore
            .collection('Notes')
            .where('owner', isEqualTo: widget.userId) // Filtrer les tâches par userId
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

          final Notes = snapshot.data!.docs;

          return ListView.builder(
            itemCount: Notes.length,
            itemBuilder: (context, index) {
              final note = Notes[index];
              final noteData = note.data() as Map<String, dynamic>;
            

              return Card(
                margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                elevation: 3,
                child: ListTile(
                  title: Text(
                    noteData['titleNote'] ?? 'Pas de titre',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
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
                              builder: (context) => EditNotePage(
                                   noteId: note.id ,noteData: noteData, NoteData: const {},
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
                                    'Voulez-vous vraiment supprimer cette note ?'),
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
                            deleteNote(note.id);
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
                        builder: (context) => NoteDetailsPage(
                          noteData: noteData,
                          noteId: note.id, NoteData: {}, // Pass the Firestore document ID as taskId
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
