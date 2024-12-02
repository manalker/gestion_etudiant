import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart'; // For date formatting

class EditTaskPage extends StatefulWidget {
  final Map<String, dynamic> taskData;
  final String taskId;

  const EditTaskPage({Key? key, required this.taskId, required this.taskData})
      : super(key: key);

  @override
  _EditTaskPageState createState() => _EditTaskPageState();
}

class _EditTaskPageState extends State<EditTaskPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  late TextEditingController _titleController;
  late TextEditingController _categoryController;
  late TextEditingController _priorityController;
  late TextEditingController _statusController;
  late TextEditingController _datCreationController;
  late TextEditingController _datEcheaController;
  late TextEditingController _datArchivController;

  DateTime? datCreation;
  DateTime? datEchea;
  DateTime? datArchiv;

  @override
  void initState() {
    super.initState();

    // Initialize the controllers with the data passed to the widget
    _titleController = TextEditingController(text: widget.taskData['titleTask'] ?? '');
    _categoryController = TextEditingController(text: widget.taskData['cathegTask'] ?? '');
    _priorityController = TextEditingController(text: widget.taskData['priorityTask'] ?? '');
    _statusController = TextEditingController(text: widget.taskData['statut'] ?? '');

    // Handle both String and Timestamp for date fields
    datCreation = _parseDate(widget.taskData['datCreation']);
    datEchea = _parseDate(widget.taskData['datEchea']);
    datArchiv = _parseDate(widget.taskData['datArchiv']);

    _datCreationController = TextEditingController(
      text: datCreation != null ? DateFormat('yyyy-MM-dd').format(datCreation!) : '',
    );
    _datEcheaController = TextEditingController(
      text: datEchea != null ? DateFormat('yyyy-MM-dd').format(datEchea!) : '',
    );
    _datArchivController = TextEditingController(
      text: datArchiv != null ? DateFormat('yyyy-MM-dd').format(datArchiv!) : '',
    );
  }

  DateTime? _parseDate(dynamic date) {
    if (date == null) return null;

    // If the date is a String, try to parse it
    if (date is String) {
      return DateTime.tryParse(date);
    } else if (date is Timestamp) {
      // If the date is already a Timestamp, convert to DateTime
      return date.toDate();
    }
    return null;
  }

  Future<void> _updateTask() async {
    try {
      // Ensure we're sending the correct Timestamp type to Firestore
      await _firestore.collection('Tasks').doc(widget.taskId).update({
        'titleTask': _titleController.text,
        'cathegTask': _categoryController.text,
        'priorityTask': _priorityController.text,
        'statut': _statusController.text,
        'datCreation': datCreation != null ? Timestamp.fromDate(datCreation!) : null,
        'datEchea': datEchea != null ? Timestamp.fromDate(datEchea!) : null,
        'datArchiv': datArchiv != null ? Timestamp.fromDate(datArchiv!) : null,
      });

      // Show success message and pop the page
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tâche mise à jour avec succès !')),
      );
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur : ${e.toString()}')),
      );
    }
  }

  Future<void> _selectDate(BuildContext context, {required String field}) async {
    DateTime initialDate;
    if (field == 'datCreation') {
      initialDate = datCreation ?? DateTime.now();
    } else if (field == 'datEchea') {
      initialDate = datEchea ?? DateTime.now();
    } else {
      initialDate = datArchiv ?? DateTime.now();
    }

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );

    if (picked != null && picked != initialDate) {
      setState(() {
        if (field == 'datCreation') {
          datCreation = picked;
          _datCreationController.text = DateFormat('yyyy-MM-dd').format(picked);
        } else if (field == 'datEchea') {
          datEchea = picked;
          _datEcheaController.text = DateFormat('yyyy-MM-dd').format(picked);
        } else {
          datArchiv = picked;
          _datArchivController.text = DateFormat('yyyy-MM-dd').format(picked);
        }
      });
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
            const SizedBox(height: 10),
            TextField(
              controller: _datCreationController,
              decoration: const InputDecoration(labelText: 'Date de création'),
              onTap: () => _selectDate(context, field: 'datCreation'),
              readOnly: true,
            ),
            TextField(
              controller: _datEcheaController,
              decoration: const InputDecoration(labelText: 'Date d\'échéance'),
              onTap: () => _selectDate(context, field: 'datEchea'),
              readOnly: true,
            ),
            TextField(
              controller: _datArchivController,
              decoration: const InputDecoration(labelText: 'Date d\'archivage'),
              onTap: () => _selectDate(context, field: 'datArchiv'),
              readOnly: true,
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
