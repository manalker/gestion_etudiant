import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AddUserPage extends StatefulWidget {
  const AddUserPage({super.key});

  @override
  _AddUserPageState createState() => _AddUserPageState();
}

class _AddUserPageState extends State<AddUserPage> {
  // Clé pour gérer la validation du formulaire
  final _formKey = GlobalKey<FormState>();

  // Instance Firestore pour interagir avec la base de données
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Champs pour stocker les informations de l'utilisateur
  String email = '';
  String password = '';
  String nomUser = '';
  String prenomUser = '';
  String statut = 'admin'; // Valeur par défaut pour le menu déroulant

  // Fonction pour ajouter un utilisateur à la base de données
  Future<void> addUser() async {
    if (_formKey.currentState!.validate()) {
      // Vérifie si les champs sont valides
      try {
        // Ajoute un nouvel utilisateur dans la collection "User" de Firestore
        await _firestore.collection('User').add({
          'email': email,
          'mdp': password,
          'nomUser': nomUser,
          'prenomUser': prenomUser,
          'statut': statut == 'admin', // Convertit le statut en booléen
        });

        // Affiche un message de succès
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Utilisateur ajouté avec succès !')),
        );

        // Réinitialise le formulaire après l'ajout
        _formKey.currentState!.reset();
        setState(() {
          statut = 'admin'; // Réinitialise le statut à sa valeur par défaut
        });
      } catch (e) {
        // En cas d'erreur, affiche un message d'erreur
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
        // Barre d'application avec le titre de la page
        title: const Text('Ajouter un utilisateur'),
        backgroundColor: Colors.teal,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey, // Associe la clé du formulaire
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Titre d'instruction
                const Text(
                  'Remplissez les informations de l’utilisateur :',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),

                // Champ Email
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    prefixIcon: Icon(Icons.email),
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    // Validation : vérifier que l'email est valide
                    if (value == null || value.isEmpty) {
                      return 'Veuillez entrer un email';
                    }
                    if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                      return 'Veuillez entrer un email valide';
                    }
                    return null;
                  },
                  onChanged: (value) => email = value,
                ),
                const SizedBox(height: 20),

                // Champ Mot de passe
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Mot de passe',
                    prefixIcon: Icon(Icons.lock),
                    border: OutlineInputBorder(),
                  ),
                  obscureText: true, // Cache le mot de passe
                  validator: (value) {
                    // Validation : le mot de passe doit être d'au moins 6 caractères
                    if (value == null || value.isEmpty) {
                      return 'Veuillez entrer un mot de passe';
                    }
                    if (value.length < 6) {
                      return 'Le mot de passe doit contenir au moins 6 caractères';
                    }
                    return null;
                  },
                  onChanged: (value) => password = value,
                ),
                const SizedBox(height: 20),

                // Champ Nom
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Nom',
                    prefixIcon: Icon(Icons.person),
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    // Validation : le champ ne doit pas être vide
                    if (value == null || value.isEmpty) {
                      return 'Veuillez entrer un nom';
                    }
                    return null;
                  },
                  onChanged: (value) => nomUser = value,
                ),
                const SizedBox(height: 20),

                // Champ Prénom
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Prénom',
                    prefixIcon: Icon(Icons.person),
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    // Validation : le champ ne doit pas être vide
                    if (value == null || value.isEmpty) {
                      return 'Veuillez entrer un prénom';
                    }
                    return null;
                  },
                  onChanged: (value) => prenomUser = value,
                ),
                const SizedBox(height: 20),

                // Sélecteur pour le statut
                DropdownButtonFormField<String>(
                  value: statut, // Valeur sélectionnée par défaut
                  decoration: const InputDecoration(
                    labelText: 'Statut',
                    border: OutlineInputBorder(),
                  ),
                  items: const [
                    DropdownMenuItem(
                      value: 'admin',
                      child: Text('Admin'),
                    ),
                    DropdownMenuItem(
                      value: 'étudiant',
                      child: Text('Étudiant'),
                    ),
                  ],
                  onChanged: (value) {
                    // Met à jour le statut en fonction de la sélection
                    setState(() {
                      statut = value!;
                    });
                  },
                ),
                const SizedBox(height: 30),

                // Bouton Ajouter
                Center(
                  child: ElevatedButton(
                    onPressed:
                        addUser, // Appelle la méthode pour ajouter un utilisateur
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.teal,
                      padding: const EdgeInsets.symmetric(
                        vertical: 15,
                        horizontal: 50,
                      ),
                    ),
                    child: const Text(
                      'Ajouter l’utilisateur',
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
