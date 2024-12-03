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
  late TextEditingController _datCreationController;
  late TextEditingController _datEcheaController;
  late TextEditingController _datArchivController;

  DateTime? datCreation;
  DateTime? datEchea;
  DateTime? datArchiv;

  String? _selectedStatus;
  String? _selectedPriority;

  @override
  void initState() {
    super.initState();

    _titleController =
        TextEditingController(text: widget.taskData['titleTask'] ?? '');
    _categoryController =
        TextEditingController(text: widget.taskData['cathegTask'] ?? '');

    datCreation = _parseDate(widget.taskData['datCreation']);
    datEchea = _parseDate(widget.taskData['datEchea']);
    datArchiv = _parseDate(widget.taskData['datArchiv']);

    _datCreationController = TextEditingController(
      text: datCreation != null
          ? DateFormat('yyyy-MM-dd').format(datCreation!)
          : '',
    );
    _datEcheaController = TextEditingController(
      text: datEchea != null ? DateFormat('yyyy-MM-dd').format(datEchea!) : '',
    );
    _datArchivController = TextEditingController(
      text:
          datArchiv != null ? DateFormat('yyyy-MM-dd').format(datArchiv!) : '',
    );

    _selectedStatus = widget.taskData['statut'];
    _selectedPriority = widget.taskData['priorityTask'];
  }

  DateTime? _parseDate(dynamic date) {
    if (date == null) return null;
    if (date is String) return DateTime.tryParse(date);
    if (date is Timestamp) return date.toDate();
    return null;
  }

  Future<void> _updateTask() async {
    try {
      await _firestore.collection('Tasks').doc(widget.taskId).update({
        'titleTask': _titleController.text,
        'cathegTask': _categoryController.text,
        'priorityTask': _selectedPriority,
        'statut': _selectedStatus,
        'datCreation':
            datCreation != null ? Timestamp.fromDate(datCreation!) : null,
        'datEchea': datEchea != null ? Timestamp.fromDate(datEchea!) : null,
        'datArchiv': datArchiv != null ? Timestamp.fromDate(datArchiv!) : null,
      });

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

  Future<void> _selectDate(BuildContext context,
      {required String field}) async {
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
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTextField('Titre de la tâche', _titleController),
              const SizedBox(height: 10),
              _buildTextField('Catégorie', _categoryController),
              const SizedBox(height: 10),
              _buildDropdown(
                'Statut',
                _selectedStatus,
                (value) => setState(() => _selectedStatus = value),
                const [
                  DropdownMenuItem(value: 'En cours', child: Text('En cours')),
                  DropdownMenuItem(value: 'Terminé', child: Text('Terminé')),
                  DropdownMenuItem(
                      value: 'En retard', child: Text('En retard')),
                  DropdownMenuItem(
                      value: 'En attente', child: Text('En attente')),
                ],
              ),
              const SizedBox(height: 10),
              _buildDropdown(
                'Priorité',
                _selectedPriority,
                (value) => setState(() => _selectedPriority = value),
                const [
                  DropdownMenuItem(value: 'faible', child: Text('Faible')),
                  DropdownMenuItem(value: 'Moyenne', child: Text('Moyenne')),
                  DropdownMenuItem(value: 'Haute', child: Text('Haute')),
                ],
              ),
              const SizedBox(height: 20),
              _buildDateField(
                  'Date de création', _datCreationController, 'datCreation'),
              const SizedBox(height: 20),
              _buildDateField(
                  'Date d\'échéance', _datEcheaController, 'datEchea'),
              const SizedBox(height: 20),
              _buildDateField(
                  'Date d\'archivage', _datArchivController, 'datArchiv'),
              const SizedBox(height: 30),
              Center(
                child: ElevatedButton(
                  onPressed: _updateTask,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 12),
                  ),
                  child: const Text('Mettre à jour',
                      style: TextStyle(fontSize: 16)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
    );
  }

  Widget _buildDropdown(String label, String? selectedValue,
      ValueChanged<String?> onChanged, List<DropdownMenuItem<String>> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 5),
        DropdownButtonFormField<String>(
          value: selectedValue,
          onChanged: onChanged,
          items: items,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
          ),
        ),
      ],
    );
  }

  Widget _buildDateField(
      String label, TextEditingController controller, String field) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        suffixIcon: const Icon(Icons.calendar_today),
      ),
      onTap: () => _selectDate(context, field: field),
      readOnly: true,
    );
  }
}
