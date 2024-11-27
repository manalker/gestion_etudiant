import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AddTaskPage extends StatefulWidget {
  const AddTaskPage({super.key});

  @override
  _AddTaskPageState createState() => _AddTaskPageState();
}

class _AddTaskPageState extends State<AddTaskPage> {
  final _formKey = GlobalKey<FormState>();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String titleTask = '';
  String descTask = '';
  String cathegTask = '';
  String statut = 'En cours'; // Valeur par défaut pour le menu déroulant
  String priorityTask = 'Moyenne'; // Priorité par défaut
  DateTime? datCreation;
  DateTime? datEchea;
  DateTime? datArchiv;
  String? timeDisplay;

  // Fonction pour ajouter une tâche à la base de données
  Future<void> addTask() async {
    if (_formKey.currentState!.validate()) {
      try {
        // Si la date de création n'est pas déjà définie, on l'initialise avec la date actuelle
        if (datCreation == null) {
          datCreation = DateTime.now();
        }

        // Vérification des dates (date d'échéance et date d'archivage)
        if (datEchea != null && datEchea!.isBefore(datCreation!)) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("La date d'échéance doit être après la date de création.")),
          );
          return;
        }

        if (datArchiv != null && datArchiv!.isBefore(datCreation!)) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("La date d'archivage doit être après la date de création.")),
          );
          return;
        }

        // Ajout de la tâche dans Firestore
        await _firestore.collection('Tasks').add({
          'titleTask': titleTask,
          'descTask': descTask,
          'cathegTask': cathegTask,
          'statut': statut,
          'priorityTask': priorityTask,
          'datCreation': datCreation?.toIso8601String(),
          'datEchea': datEchea?.toIso8601String(),
          'datArchiv': datArchiv?.toIso8601String(),
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Tâche ajoutée avec succès !')),
        );

        _formKey.currentState!.reset();
        setState(() {
          statut = 'En cours';
          priorityTask = 'Moyenne';
          datCreation = null;
          datEchea = null;
          datArchiv = null;
          timeDisplay = null;
        });
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur : ${e.toString()}')),
        );
      }
    }
  }

  // Fonction pour sélectionner la date et l'heure de création
  Future<void> _selectDateTime(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (pickedDate != null) {
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(pickedDate),
      );

      if (pickedTime != null) {
        setState(() {
          datCreation = DateTime(
            pickedDate.year,
            pickedDate.month,
            pickedDate.day,
            pickedTime.hour,
            pickedTime.minute,
          );
          timeDisplay = '${pickedTime.format(context)} ${pickedDate.toLocal()}';
        });
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
                    labelText: 'Titre de la tâche',
                    prefixIcon: Icon(Icons.title),
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Veuillez entrer un titre';
                    }
                    return null;
                  },
                  onChanged: (value) => titleTask = value,
                ),
                const SizedBox(height: 20),

                // Champ Description
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Description',
                    prefixIcon: Icon(Icons.description),
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                  onChanged: (value) => descTask = value,
                ),
                const SizedBox(height: 20),

                // Champ Catégorie
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Catégorie',
                    prefixIcon: Icon(Icons.category),
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (value) => cathegTask = value,
                ),
                const SizedBox(height: 20),

                // Sélecteur pour le statut
                DropdownButtonFormField<String>(
                  value: statut,
                  decoration: const InputDecoration(
                    labelText: 'Statut',
                    border: OutlineInputBorder(),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'En cours', child: Text('En cours')),
                    DropdownMenuItem(value: 'Terminé', child: Text('Terminé')),
                    DropdownMenuItem(value: 'En retard', child: Text('En retard')),
                    DropdownMenuItem(value: 'En attente', child: Text('En attente')),
                  ],
                  onChanged: (value) => setState(() {
                    statut = value!;
                  }),
                ),
                const SizedBox(height: 20),

                // Sélecteur pour la priorité
                DropdownButtonFormField<String>(
                  value: priorityTask,
                  decoration: const InputDecoration(
                    labelText: 'Priorité',
                    border: OutlineInputBorder(),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'faible', child: Text('faible')),
                    DropdownMenuItem(value: 'Moyenne', child: Text('Moyenne')),
                    DropdownMenuItem(value: 'Haute', child: Text('Haute')),
                  ],
                  onChanged: (value) => setState(() {
                    priorityTask = value!;
                  }),
                ),
                const SizedBox(height: 20),

                // Sélecteur pour la date et l'heure de création
                ElevatedButton(
                  onPressed: () => _selectDateTime(context),
                  child: Text(datCreation == null
                      ? 'Sélectionnez la date et l\'heure'
                      : 'Date et Heure de création : $timeDisplay'),
                ),
                const SizedBox(height: 20),

                // Date d’échéance
                ElevatedButton(
                  onPressed: () async {
                    datEchea = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2100),
                    );
                  },
                  child: Text(datEchea == null
                      ? 'Sélectionnez la date d’échéance'
                      : 'Date d’échéance : ${datEchea?.toLocal()}'),
                ),
                const SizedBox(height: 20),

                // Date d'archivage
                ElevatedButton(
                  onPressed: () async {
                    datArchiv = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2100),
                    );
                  },
                  child: Text(datArchiv == null
                      ? 'Sélectionnez la date d\'archivage'
                      : 'Date d\'archivage : ${datArchiv?.toLocal()}'),
                ),
                const SizedBox(height: 20),

                // Bouton Ajouter
                Center(
                  child: ElevatedButton(
                    onPressed: addTask,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.teal,
                      padding: const EdgeInsets.symmetric(
                        vertical: 15,
                        horizontal: 50,
                      ),
                    ),
                    child: const Text(
                      'Ajouter la tâche',
                      style: TextStyle(fontSize: 16),
                    ),
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
