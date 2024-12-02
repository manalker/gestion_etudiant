import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class TaskDetailsPage extends StatelessWidget {
  final Map<String, dynamic> taskData;
  final String taskId; // Added taskId

  const TaskDetailsPage({super.key, required this.taskData, required this.taskId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Détails de la tâche'),
        backgroundColor: Colors.teal,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Titre: ${taskData['titleTask']}',
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              _buildDetailRow('Description', taskData['descTask']),
              _buildDetailRow('Catégorie', taskData['cathegTask']),
              _buildDetailRow('Statut', taskData['statut']),
              _buildDetailRow('Priorité', taskData['priorityTask']),
              _buildDetailRow('Créé le', _formatDate(taskData['datCreation'])),
              _buildDetailRow('Date d\'échéance', _formatDate(taskData['datEchea'])),
              _buildDetailRow('Date d\'archivage', _formatDate(taskData['datArchiv'])),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Text(
            '$label: ',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          Expanded(
            child: Text(value,
                style: const TextStyle(fontSize: 16), overflow: TextOverflow.ellipsis),
          ),
        ],
      ),
    );
  }

  String _formatDate(dynamic field) {
    if (field is Timestamp) {
      return (field as Timestamp).toDate().toString();
    } else if (field is String) {
      try {
        DateTime date = DateTime.parse(field);
        return date.toLocal().toString();
      } catch (e) {
        return 'Non défini';
      }
    } else {
      return 'Non défini';
    }
  }
}
