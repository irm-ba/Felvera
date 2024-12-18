import 'package:felvera/firebase/auth.dart';
import 'package:flutter/material.dart';

import 'login.dart'; // Giriş sayfası için import

class SettingsPage extends StatelessWidget {
  final Auth _auth = Auth();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Ayarlar"),
      ),
      body: ListView(
        children: [
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout_rounded,
                color: Color.fromARGB(255, 147, 58, 142)),
            title: const Text('Çıkış yap'),
            onTap: () async {
              try {
                await _auth.signOut();
                // Çıkış yaptıktan sonra kullanıcıyı giriş ekranına yönlendirin
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => LoginPage()),
                );
              } catch (e) {
                // Hata durumunda kullanıcıya bilgi verin
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Çıkış yapılamadı: $e')),
                );
              }
            },
          ),
        ],
      ),
    );
  }
}
