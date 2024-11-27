import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class EditTaskPage extends StatefulWidget {
  final Map<String, dynamic> taskData;

  const EditTaskPage({Key? key, required this.taskData}) : super(key: key);

  @override
  _EditTaskPageState createState() => _EditTaskPageState();
}

class _EditTaskPageState extends State<EditTaskPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  late TextEditingController _titleController;
  late TextEditingController _categoryController;
  late TextEditingController _priorityController;
  late TextEditingController _statusController;

  DateTime? datCreation;
  DateTime? datEchea;
  DateTime? datArchiv;

  @override
  void initState() {
    super.initState();

    _titleController = TextEditingController(text: widget.taskData['titleTask']);
    _categoryController = TextEditingController(text: widget.taskData['cathegTask']);
    _priorityController = TextEditingController(text: widget.taskData['priorityTask']);
    _statusController = TextEditingController(text: widget.taskData['statut']);

    // Safely convert Firestore timestamps to DateTime
    datCreation = (widget.taskData['datCreation'] as Timestamp?)?.toDate();
    datEchea = (widget.taskData['datEchea'] as Timestamp?)?.toDate();
    datArchiv = (widget.taskData['datArchiv'] as Timestamp?)?.toDate();
  }

  Future<void> _updateTask() async {
    try {
      await _firestore.collection('Tasks').doc(widget.taskData['id']).update({
        'titleTask': _titleController.text,
        'cathegTask': _categoryController.text,
        'priorityTask': _priorityController.text,
        'statut': _statusController.text,
        'datCreation': datCreation?.toIso8601String(),
        'datEchea': datEchea?.toIso8601String(),
        'datArchiv': datArchiv?.toIso8601String(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tâche mise à jour avec succès !')),
      );
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur lors de la mise à jour : ${e.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Modifier la Tâche'),
        backgroundColor: Colors.teal,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: 'Titre de la tâche'),
            ),
            TextField(
              controller: _categoryController,
              decoration: const InputDecoration(labelText: 'Catégorie'),
            ),
            TextField(
              controller: _priorityController,
              decoration: const InputDecoration(labelText: 'Priorité'),
            ),
            TextField(
              controller: _statusController,
              decoration: const InputDecoration(labelText: 'Statut'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _updateTask,
              child: const Text('Mettre à jour'),
            ),
          ],
        ),
      ),
    );
  }
}
