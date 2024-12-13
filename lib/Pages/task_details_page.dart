import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class TaskDetailsPage extends StatelessWidget {
  final Map<String, dynamic> taskData;
  final String taskId;

  const TaskDetailsPage(
      {super.key, required this.taskData, required this.taskId});

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
              Card(
                color: Colors.teal[50],
                elevation: 4,
                margin: const EdgeInsets.only(bottom: 16.0),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        taskData['titleTask'] ?? 'Titre non défini',
                        style: const TextStyle(
                            fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      _buildStatusIcon(taskData['statut']),
                    ],
                  ),
                ),
              ),
              ..._buildDetailCards(context),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _buildDetailCards(BuildContext context) {
    final List<Map<String, dynamic>> details = [
      {
        'label': 'Description',
        'value': taskData['descTask'],
        'icon': Icons.description
      },
      {
        'label': 'Catégorie',
        'value': taskData['cathegTask'],
        'icon': Icons.category
      },
      {
        'label': 'Priorité',
        'value': taskData['priorityTask'],
        'icon': Icons.flag
      },
      {
        'label': 'Créé le',
        'value': _formatDate(taskData['datCreation']),
        'icon': Icons.calendar_today
      },
      {
        'label': 'Date d\'échéance',
        'value': _formatDate(taskData['datEchea']),
        'icon': Icons.event
      },
      {
        'label': 'Date d\'archivage',
        'value': _formatDate(taskData['datArchiv']),
        'icon': Icons.archive
      },
    ];

    return details.map((detail) {
      return Card(
        margin: const EdgeInsets.symmetric(vertical: 8.0),
        elevation: 2,
        child: ListTile(
          leading: Icon(detail['icon'], color: Colors.teal),
          title: Text(
            detail['label'],
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          subtitle: detail['label'] == 'Priorité'
              ? _buildPriorityLabel(detail['value'])
              : Text(
                  detail['value'] ?? 'Non défini',
                  style: const TextStyle(color: Colors.black87),
                ),
        ),
      );
    }).toList();
  }

  Widget _buildPriorityLabel(String? priority) {
    Color color;
    switch (priority) {
      case 'Haute':
        color = Colors.red;
        break;
      case 'Moyenne':
        color = Colors.orange;
        break;
      case 'Basse':
        color = Colors.green;
        break;
      default:
        color = Colors.grey;
    }

    return Row(
      children: [
        Icon(Icons.flag, color: color),
        const SizedBox(width: 8),
        Text(
          priority ?? 'Non défini',
          style: TextStyle(fontWeight: FontWeight.bold, color: color),
        ),
      ],
    );
  }

  Widget _buildStatusIcon(String? status) {
    IconData icon;
    Color color;

    switch (status) {
      case 'En cours':
        icon = Icons.timelapse;
        color = Colors.orange;
        break;
      case 'Complété':
        icon = Icons.check_circle;
        color = Colors.green;
        break;
      case 'En attente':
        icon = Icons.pause_circle;
        color = Colors.blue;
        break;
      default:
        icon = Icons.info;
        color = Colors.grey;
        break;
    }

    return Row(
      children: [
        Icon(icon, color: color, size: 28),
        const SizedBox(width: 8),
        Text(
          status ?? 'Statut non défini',
          style: TextStyle(
              fontSize: 16, fontWeight: FontWeight.bold, color: color),
        ),
      ],
    );
  }

  String _formatDate(dynamic field) {
    if (field is Timestamp) {
      return (field as Timestamp).toDate().toLocal().toString().split(' ')[0];
    } else if (field is String) {
      try {
        DateTime date = DateTime.parse(field);
        return date.toLocal().toString().split(' ')[0];
      } catch (e) {
        return 'Non défini';
      }
    } else {
      return 'Non défini';
    }
  }
}
