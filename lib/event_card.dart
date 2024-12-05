import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '/models/event_data.dart';

class EventCard extends StatelessWidget {
  final EventData eventData;

  const EventCard({required this.eventData});

  // Kullanıcıyı etkinliğe katılmak için listeye ekleme fonksiyonu
  Future<void> joinEvent(BuildContext context) async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId != null) {
      final eventDoc =
          FirebaseFirestore.instance.collection('events').doc(eventData.id);

      // Katılımcı listesine UID ekle
      await eventDoc.update({
        'participants': FieldValue.arrayUnion([userId])
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Etkinliğe katıldınız!')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Katılmak için giriş yapmalısınız.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      margin: const EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Etkinlik resmi
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
            child: eventData.imageUrl != null
                ? Image.network(eventData.imageUrl!, fit: BoxFit.cover)
                : const Placeholder(fallbackHeight: 200),
          ),
          Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  eventData.title ?? 'Başlık Yok',
                  style: const TextStyle(
                      fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 5),
                Text(eventData.date ?? 'Tarih Yok',
                    style: const TextStyle(color: Colors.grey)),
                const SizedBox(height: 10),
                Text(eventData.description ?? 'Açıklama Yok'),
                const SizedBox(height: 10),
                Row(
                  children: [
                    const Icon(Icons.people, color: Colors.grey),
                    const SizedBox(width: 5),
                    Text(
                      "${eventData.participants?.length ?? 0} katılımcı",
                      style: const TextStyle(fontSize: 16),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () => joinEvent(context),
                  child: const Text('Etkinliğe Katıl'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
