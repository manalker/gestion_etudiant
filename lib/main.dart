import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:student_manager/Auth/LoginPage.dart';
import 'package:student_manager/Pages/add_user_page.dart';
import 'package:student_manager/Pages/admin_page.dart';
import 'package:student_manager/Pages/edit_user_page.dart';
import 'package:student_manager/Pages/user_details_page.dart';
import 'package:student_manager/Pages/view_users_page.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Gestion Étudiant',
      theme: ThemeData(primarySwatch: Colors.teal),
      initialRoute: '/',
      onGenerateRoute: (settings) {
        if (settings.name == '/user_details') {
          final user = settings.arguments as DocumentSnapshot;
          return MaterialPageRoute(
            builder: (context) => UserDetailsPage(user: user),
          );
        }
        if (settings.name == '/edit_user') {
          final args = settings.arguments
              as Map<String, dynamic>; // Récupérer les arguments passés
          return MaterialPageRoute(
            builder: (context) => EditUserPage(user: args['user']),
          );
        }
        return null;
      },
      routes: {
        '/': (context) => const LoginPage(),
        '/admin': (context) => const AdminPage(),
        '/add_user': (context) => const AddUserPage(),
        '/view_users': (context) => const ViewUsersPage(),
      },
    );
  }
}
