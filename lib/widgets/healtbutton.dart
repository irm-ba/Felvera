import 'package:felvera/HealthRecordAdd.dart';
import 'package:felvera/healthRecordlist.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp();
  }
}

class HealthRecordHomePage extends StatelessWidget {
  const HealthRecordHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const HealthRecordAdd(
                          petId: 'PET_ID')), // Geçerli bir pet ID'si ekleyin
                );
              },
              child: const Text('Sağlık Kaydı Ekle'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const HealthRecordList()),
                );
              },
              child: const Text('Sağlık Kayıtlarını Görüntüle'),
            ),
          ],
        ),
      ),
    );
  }
}
