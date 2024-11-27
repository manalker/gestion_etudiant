import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:student_manager/Auth/LoginPage.dart';
import 'package:student_manager/Pages/add_task_page.dart';
import 'package:student_manager/Pages/add_user_page.dart';
import 'package:student_manager/Pages/admin_page.dart';
import 'package:student_manager/Pages/edit_task_page.dart';
import 'package:student_manager/Pages/task_details_page.dart';
import 'package:student_manager/Pages/edit_user_page.dart';
import 'package:student_manager/Pages/user_details_page.dart';
import 'package:student_manager/Pages/view_tasks_page.dart';
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
              as Map<String, dynamic>; // Retrieve the passed arguments
          return MaterialPageRoute(
            builder: (context) => EditUserPage(
                user: args['user']), // Pass the entire args map to the page
          );
        }

        if (settings.name == '/task_details') {
          final args = settings.arguments
              as Map<String, dynamic>; // Récupérer les arguments passés
          return MaterialPageRoute(
            builder: (context) => TaskDetailsPage(
                taskData: args['task']), // Correct argument name here
          );
        }

        if (settings.name == '/edit_task') {
          final args = settings.arguments
              as Map<String, dynamic>; // Récupérer les arguments passés
          return MaterialPageRoute(
            builder: (context) => EditTaskPage(
                taskData: args['task']), // Pass the correct task argument
          );
        }
        return null;
      },
      routes: {
        '/': (context) => const LoginPage(),
        '/admin': (context) => const AdminPage(),
        '/add_user': (context) => const AddUserPage(),
        '/view_users': (context) => const ViewUsersPage(),
        '/view_tasks': (context) => const ViewTasksPage(),
        '/add_task': (context) => const AddTaskPage(),
        '/edit_task':(context) => const EditTaskPage(taskData: {},),
              },
    );
  }
}
