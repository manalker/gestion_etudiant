import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AddTaskPage extends StatefulWidget {
  final String userId; // userId est passé ici par le parent
  const AddTaskPage({Key? key, required this.userId}) : super(key: key);

  @override
  _AddTaskPageState createState() => _AddTaskPageState();
}

class _AddTaskPageState extends State<AddTaskPage> {
  final _formKey = GlobalKey<FormState>();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String titleTask = '';
  String descTask = '';
  String cathegTask = '';
  String statut = 'En cours';
  String priorityTask = 'Moyenne';
  DateTime? datEchea;
  DateTime? datArchiv;

  // Fonction pour ajouter une tâche à la base de données
  Future<void> addTask() async {
    if (_formKey.currentState!.validate()) {
      try {
        // Validation des dates
        if (datEchea != null && datEchea!.isBefore(DateTime.now())) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("La date d'échéance doit être future."),
            ),
          );
          return;
        }

        if (datArchiv != null && datArchiv!.isBefore(DateTime.now())) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("La date d'archivage doit être future."),
            ),
          );
          return;
        }

        // Ajout de la tâche avec la date de création actuelle
        await _firestore.collection('Tasks').add({
          'owner': widget
              .userId, // Utilisation correcte de l'ID de l'utilisateur connecté
          'titleTask': titleTask,
          'descTask': descTask,
          'cathegTask': cathegTask,
          'statut': statut,
          'priorityTask': priorityTask,
          'datCreation':
              DateTime.now().toIso8601String(), // Date et heure actuelles
          'datEchea': datEchea?.toIso8601String(),
          'datArchiv': datArchiv?.toIso8601String(),
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Tâche ajoutée avec succès !')),
        );

        // Réinitialisation du formulaire
        _formKey.currentState!.reset();
        setState(() {
          statut = 'En cours';
          priorityTask = 'Moyenne';
          datEchea = null;
          datArchiv = null;
        });
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
                    DropdownMenuItem(
                        value: 'En cours', child: Text('En cours')),
                    DropdownMenuItem(value: 'Terminé', child: Text('Terminé')),
                    DropdownMenuItem(
                        value: 'En retard', child: Text('En retard')),
                    DropdownMenuItem(
                        value: 'En attente', child: Text('En attente')),
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
                    DropdownMenuItem(value: 'Faible', child: Text('Faible')),
                    DropdownMenuItem(value: 'Moyenne', child: Text('Moyenne')),
                    DropdownMenuItem(value: 'Haute', child: Text('Haute')),
                  ],
                  onChanged: (value) => setState(() {
                    priorityTask = value!;
                  }),
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

                // Bouton pour ajouter la tâche
                Center(
                  child: ElevatedButton(
                    onPressed: addTask,
                    child: const Text('Ajouter la tâche'),
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
