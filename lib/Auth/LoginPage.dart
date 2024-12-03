import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:student_manager/Pages/admin_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  // Création de l'état associé à la page de connexion
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  // Variables pour stocker les informations saisies par l'utilisateur
  String email = '';
  String password = '';
  String message = '';

  // Instance de FirebaseFirestore pour interagir avec Firestore
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Méthode pour gérer la connexion de l'utilisateur
  Future<void> login() async {
    try {
      // Accéder à la collection "User" dans Firestore
      final QuerySnapshot result = await _firestore
          .collection('User')
          .where('email', isEqualTo: email)
          .where('mdp', isEqualTo: password)
          .get();

      if (result.docs.isNotEmpty) {
        // Si un document est trouvé, récupérer les données de l'utilisateur
        final userData = result.docs[0].data() as Map<String, dynamic>;

        // Vérifier le statut de l'utilisateur
        if (userData['statut'] == true) {
          // Rediriger vers la page Admin
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const AdminPage()),
          );
        } else {
          // Rediriger vers la page Étudiant
          /*Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const StudentPage()),
          );*/
        }
      } else {
        // Aucun utilisateur correspondant trouvé
        setState(() {
          message = 'Email ou mot de passe incorrect.';
        });
      }
    } catch (e) {
      // En cas d'erreur, afficher un message
      setState(() {
        message = 'Erreur : ${e.toString()}';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Couleur de fond de la page
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0), // Marge interne
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Titre principal de la page
                const Text(
                  'Bienvenue!',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.teal, // Couleur principale
                  ),
                ),
                const SizedBox(height: 10),

                // Message secondaire
                Text(
                  'Connectez-vous pour continuer.',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600], // Couleur grise pour le texte
                  ),
                ),
                const SizedBox(height: 30),

                // Champ de saisie pour l'email
                TextField(
                  decoration: InputDecoration(
                    labelText: 'Email',
                    prefixIcon: const Icon(Icons.email), // Icône pour l'email
                    border: OutlineInputBorder(
                      borderRadius:
                          BorderRadius.circular(10.0), // Coins arrondis
                    ),
                  ),
                  keyboardType: TextInputType.emailAddress, // Type d'entrée
                  onChanged: (value) => email = value, // Mise à jour de l'email
                ),
                const SizedBox(height: 20),

                // Champ de saisie pour le mot de passe
                TextField(
                  decoration: InputDecoration(
                    labelText: 'Mot de passe',
                    prefixIcon:
                        const Icon(Icons.lock), // Icône pour le mot de passe
                    border: OutlineInputBorder(
                      borderRadius:
                          BorderRadius.circular(10.0), // Coins arrondis
                    ),
                  ),
                  obscureText: true, // Masque le mot de passe
                  onChanged: (value) =>
                      password = value, // Mise à jour du mot de passe
                ),
                const SizedBox(height: 20),

                // Bouton pour lancer l'authentification
                ElevatedButton(
                  onPressed: login, // Appelle la méthode de connexion
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal, // Couleur du bouton
                    padding: const EdgeInsets.symmetric(
                        vertical: 15), // Taille du bouton
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.login), // Icône du bouton
                      SizedBox(width: 10),
                      Text('Se connecter', style: TextStyle(fontSize: 16)),
                    ],
                  ),
                ),
                const SizedBox(height: 10),

                // Lien vers la page "Mot de passe oublié"
                TextButton(
                  onPressed: () {
                    // Redirection vers une autre page
                    Navigator.pushNamed(context, '/forgot_password');
                  },
                  child: const Text(
                    'Mot de passe oublié ?',
                    style: TextStyle(
                        color: Colors.teal), // Couleur du texte du lien
                  ),
                ),

                // Affichage d'un message d'erreur ou de succès
                if (message.isNotEmpty)
                  Text(
                    message, // Contenu du message
                    style: TextStyle(
                      color: message.contains('réussie')
                          ? Colors.green // Message de succès en vert
                          : Colors.red, // Message d'erreur en rouge
                      fontSize: 16,
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
