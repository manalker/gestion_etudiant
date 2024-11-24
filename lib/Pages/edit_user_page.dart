import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class EditUserPage extends StatefulWidget {
  final DocumentSnapshot user;

  // Constructeur pour recevoir les données de l'utilisateur sélectionné
  const EditUserPage({super.key, required this.user});

  @override
  _EditUserPageState createState() => _EditUserPageState();
}

class _EditUserPageState extends State<EditUserPage> {
  final _formKey = GlobalKey<FormState>();

  // Variables pour stocker les données utilisateur
  late String email;
  late String nomUser;
  late String prenomUser;
  late String statut;

  @override
  void initState() {
    super.initState();
    // Initialiser les données utilisateur à partir du snapshot reçu
    final userData = widget.user.data() as Map<String, dynamic>;
    email = userData['email'];
    nomUser = userData['nomUser'];
    prenomUser = userData['prenomUser'];
    statut = userData['statut'] == true ? 'admin' : 'étudiant';
  }

  // Fonction pour mettre à jour les données de l'utilisateur dans Firestore
  Future<void> updateUser() async {
    if (_formKey.currentState!.validate()) {
      try {
        await FirebaseFirestore.instance
            .collection('User') // Collection contenant les utilisateurs
            .doc(widget.user.id) // Document correspondant à l'utilisateur
            .update({
          'email': email,
          'nomUser': nomUser,
          'prenomUser': prenomUser,
          'statut': statut == 'admin', // Convertir en booléen
        });

        // Afficher un message de succès
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Utilisateur modifié avec succès !')),
        );

        // Revenir à la page précédente après la mise à jour
        Navigator.pop(context);
      } catch (e) {
        // Afficher une erreur en cas de problème
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
        title: const Text('Modifier l’utilisateur'),
        backgroundColor: Colors.teal, // Couleur de l'AppBar
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0), // Espacement pour le contenu
        child: Form(
          key: _formKey, // Clé pour valider le formulaire
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Champ pour modifier l'email
              TextFormField(
                initialValue: email, // Valeur initiale
                decoration: const InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.email),
                ),
                keyboardType: TextInputType.emailAddress, // Clavier pour email
                validator: (value) {
                  // Validation du champ
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer un email';
                  }
                  if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                    return 'Veuillez entrer un email valide';
                  }
                  return null;
                },
                onChanged: (value) =>
                    email = value, // Mise à jour de la variable
              ),
              const SizedBox(height: 20),

              // Champ pour modifier le nom
              TextFormField(
                initialValue: nomUser,
                decoration: const InputDecoration(
                  labelText: 'Nom',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer un nom';
                  }
                  return null;
                },
                onChanged: (value) => nomUser = value,
              ),
              const SizedBox(height: 20),

              // Champ pour modifier le prénom
              TextFormField(
                initialValue: prenomUser,
                decoration: const InputDecoration(
                  labelText: 'Prénom',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer un prénom';
                  }
                  return null;
                },
                onChanged: (value) => prenomUser = value,
              ),
              const SizedBox(height: 20),

              // Sélecteur pour modifier le statut
              DropdownButtonFormField<String>(
                value: statut, // Valeur initiale
                decoration: const InputDecoration(
                  labelText: 'Statut',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.admin_panel_settings),
                ),
                items: const [
                  DropdownMenuItem(value: 'admin', child: Text('Admin')),
                  DropdownMenuItem(value: 'étudiant', child: Text('Étudiant')),
                ],
                onChanged: (value) {
                  setState(() {
                    statut = value!;
                  });
                },
              ),
              const SizedBox(height: 30),

              // Bouton pour soumettre les modifications
              Center(
                child: ElevatedButton(
                  onPressed: updateUser,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal, // Couleur du bouton
                    padding: const EdgeInsets.symmetric(
                      vertical: 15,
                      horizontal: 50,
                    ),
                  ),
                  child: const Text(
                    'Modifier',
                    style: TextStyle(fontSize: 16), // Style du texte du bouton
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
