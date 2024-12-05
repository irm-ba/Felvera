import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ApplicationDetailPage extends StatelessWidget {
  const ApplicationDetailPage({required this.applicationId});

  final String applicationId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Başvuru Detayı',
          style: TextStyle(
            color: Color.fromARGB(255, 147, 58, 142),
          ),
        ),
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance
            .collection('adoption_applications')
            .doc(applicationId)
            .get(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Bir hata oluştu: ${snapshot.error}'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: Text('Başvuru bulunamadı.'));
          }

          var application = snapshot.data!.data() as Map<String, dynamic>;

          return Container(
            color:
                const Color(0xFFF2F2F2), // Arka plan rengini hafif gri yaptık
            padding: const EdgeInsets.all(16.0),
            child: ListView(
              children: [
                // Başvuru Bilgileri Kartı
                InfoCard(
                  title: 'Başvuru Bilgileri',
                  icon: Icons.pets,
                  content: [
                    InfoRow(
                        label: 'Yaşam Koşulları:',
                        value: application['livingConditions']),
                    InfoRow(
                        label: 'Sahiplenme Nedeni:',
                        value: application['adoptionReason']),
                  ],
                ),

                const SizedBox(height: 20),

                // Başvuru Durumu Kartı
                InfoCard(
                  title: 'Başvuru Durumu',
                  icon: Icons.pending,
                  content: [
                    InfoRow(label: 'Durum:', value: application['status']),
                  ],
                ),

                const SizedBox(height: 20),
              ],
            ),
          );
        },
      ),
    );
  }
}

class InfoCard extends StatelessWidget {
  const InfoCard(
      {required this.title, required this.icon, required this.content});

  final List<Widget> content;
  final IconData icon;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(
        borderRadius:
            BorderRadius.circular(16), // Kenarları daha yuvarlak yaptık
      ),
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: Padding(
        padding: const EdgeInsets.all(20.0), // İçeriği biraz daha geniş tuttuk
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  icon,
                  size: 28, // İkonun boyutunu biraz büyüttük
                  color: const Color.fromARGB(255, 147, 58, 142),
                ),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 20, // Başlık fontunu büyüttük
                    fontWeight: FontWeight.bold,
                    color: Color.fromARGB(255, 147, 58, 142),
                  ),
                ),
              ],
            ),
            const SizedBox(
                height: 12), // Başlık ve içerik arasındaki boşluğu artırdık
            ...content,
          ],
        ),
      ),
    );
  }
}

class InfoRow extends StatelessWidget {
  const InfoRow({required this.label, required this.value});

  final String label;
  final String? value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
          bottom: 12.0), // Satırlar arasındaki boşluğu artırdık
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color.fromARGB(255, 147, 58, 142),
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value ?? 'Beklemede',
              style: const TextStyle(
                fontSize: 16,
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
