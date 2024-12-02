import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:student_manager/Auth/LoginPage.dart';
import 'package:student_manager/Pages/add_task_page.dart';
import 'package:student_manager/Pages/add_user_page.dart';
import 'package:student_manager/Pages/admin_page.dart';
import 'package:student_manager/Pages/edit_task_page.dart';
import 'package:student_manager/Pages/etud_page.dart';
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
  runApp(MyApp(
    userId: '',
  ));
}

class MyApp extends StatelessWidget {
  String userId = '';

  MyApp({super.key, required this.userId});

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
          final args = settings.arguments as Map<String, dynamic>;
          final user = args['user'];
          final userId = args['userId'];
          return MaterialPageRoute(
            builder: (context) => EditUserPage(user: user, userId: userId),
          );
        }

        if (settings.name == '/task_details') {
          final args = settings.arguments
              as Map<String, dynamic>; // Récupérer les arguments passés
          return MaterialPageRoute(
            builder: (context) => TaskDetailsPage(
                taskData: args['task'], taskId: '',), // Correct argument name here
          );
        }

        if (settings.name == '/edit_task') {
          final args = settings.arguments as Map<String, dynamic>;
          return MaterialPageRoute(
            builder: (context) => EditTaskPage(
              taskData: args[
                  'task'], // Assurez-vous que 'task' est bien passé dans les arguments
              taskId: args[
                  'taskId'], // Assurez-vous que 'taskId' est bien passé dans les arguments
            ),
          );
        }

        if (settings.name == '/add_task') {
          final args = settings.arguments as Map<String, dynamic>;
          return MaterialPageRoute(
            builder: (context) => AddTaskPage(userId: args['userId']),
          );
        }
        return null;
      },
      routes: {
        '/': (context) => const LoginPage(),
        '/admin': (context) => const AdminPage(),
        '/etud': (context) => EtudPage(
              userId: ModalRoute.of(context)!.settings.arguments as String,
            ),
        '/add_user': (context) => const AddUserPage(),
        '/view_users': (context) => const ViewUsersPage(),
        '/view_tasks': (context) => ViewTasksPage(userId: userId),
        '/add_task': (context) => AddTaskPage(userId: userId),
        '/edit_task': (context) => const EditTaskPage(taskId: '', taskData: {}),
      },
    );
  }
}
