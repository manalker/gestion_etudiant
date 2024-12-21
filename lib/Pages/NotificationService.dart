import 'package:cloud_firestore/cloud_firestore.dart';

class NotificationService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Fonction pour récupérer les notifications non lues
  Future<List<Map<String, dynamic>>> getUnreadNotifications(String ownerId) async {
    try {
      QuerySnapshot querySnapshot = await _firestore
          .collection('Notifs') // Collection des notifications
          .where('owner', isEqualTo: ownerId) // Filtrer par utilisateur courant
          .where('is_read', isEqualTo: false) // Filtrer les notifications non lues
          .orderBy('date_notif', descending: true) // Trier par date décroissante
          .get();

      // Retourner les notifications sous forme de liste de Map
      return querySnapshot.docs.map((doc) {
        return {
          'id_tache': doc['id_tache'],
          'date_notif': (doc['date_notif'] as Timestamp).toDate(), // Convertir Timestamp en DateTime
          'is_read': doc['is_read'],
        };
      }).toList();
    } catch (e) {
      print('Erreur lors de la récupération des notifications : $e');
      return [];
    }
  }
}
