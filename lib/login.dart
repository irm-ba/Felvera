import 'package:felvera/Contact.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Firestore'u kullanmak için
import 'package:felvera/screens/home.dart';
import 'sign_up.dart';

class LoginPage extends StatelessWidget {
  LoginPage({Key? key}) : super(key: key);

  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Burada kontrolörleri tanımlıyoruz
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _header(context),
            const SizedBox(height: 30),
            _inputField(context),
            const SizedBox(height: 20),
            _forgotPassword(context),
            const SizedBox(height: 20),
            _loginButton(context),
            const SizedBox(height: 10),
            _guestLogin(context),
            const SizedBox(height: 20),
            _signup(context),
            const SizedBox(height: 20),
            _contactPage(context), // Yeni butonu ekleyin
          ],
        ),
      ),
    );
  }

  Widget _header(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 5), // Üstten boşluk
          child: Image.asset('assets/images/felvera.png',
              height: 180), // Daha büyük resim
        ),
        const SizedBox(height: 5),
        const Text(
          "HOŞGELDİNİZ",
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Color(0xFF933A8E), // Renk kodu
          ),
        ),
        const SizedBox(height: 5),
        const Text(
          "Hayvan dostlarımız yuva bulsun",
          style: TextStyle(
            fontSize: 16,
            color: Color(0xFF707070), // Renk kodu
            fontStyle: FontStyle.normal, // İtalik olmayan stil
          ),
        ),
      ],
    );
  }

  Widget _inputField(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextField(
          controller: emailController,
          decoration: InputDecoration(
            hintText: "E-Posta",
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(25), // Daha yuvarlak köşeler
              borderSide: BorderSide.none,
            ),
            filled: true,
            fillColor:
                Color.fromARGB(255, 243, 234, 241), // Hafif pembe opak renk
            prefixIcon: const Icon(
              Icons.person,
              color: Color(0xFF933A8E), // Renk kodu
            ),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
          ),
        ),
        const SizedBox(height: 15),
        TextField(
          controller: passwordController,
          decoration: InputDecoration(
            hintText: "Şifre",
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(25), // Daha yuvarlak köşeler
              borderSide: BorderSide.none,
            ),
            filled: true,
            fillColor:
                Color.fromARGB(255, 243, 234, 241), // Hafif pembe opak renk
            prefixIcon: const Icon(
              Icons.lock,
              color: Color(0xFF933A8E), // Renk kodu
            ),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
          ),
          obscureText: true,
        ),
      ],
    );
  }

  Widget _forgotPassword(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight, // Yazıyı sağa hizalar
      child: TextButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              final TextEditingController _emailController =
                  TextEditingController();

              return AlertDialog(
                title: const Text("Şifremi Unuttum"),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: _emailController,
                      decoration: InputDecoration(
                        hintText: "E-Posta",
                        border: OutlineInputBorder(
                          borderRadius:
                              BorderRadius.circular(12), // Yuvarlak köşeler
                        ),
                      ),
                    ),
                    SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: () async {
                        String email = _emailController.text.trim();

                        if (email.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text("Lütfen e-posta adresinizi girin"),
                            ),
                          );
                          return;
                        }

                        try {
                          await FirebaseAuth.instance
                              .sendPasswordResetEmail(email: email);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content:
                                  Text("Şifre sıfırlama e-postası gönderildi"),
                            ),
                          );
                          Navigator.of(context)
                              .pop(); // E-posta gönderildikten sonra dialog'ı kapat
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text("E-posta gönderilemedi"),
                            ),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(12), // Yuvarlak köşeler
                        ),
                        padding: const EdgeInsets.symmetric(
                            vertical: 12, horizontal: 24),
                        backgroundColor: Color(0xFF933A8E), // Renk kodu
                      ),
                      child: const Text("Gönder"),
                    ),
                  ],
                ),
              );
            },
          );
        },
        child: const Text(
          "Şifremi unuttum",
          style: TextStyle(color: Color(0xFF933A8E)), // Renk kodu
        ),
      ),
    );
  }

  Widget _loginButton(BuildContext context) {
    return ElevatedButton(
      onPressed: () async {
        try {
          final email = emailController.text.trim();
          final password = passwordController.text.trim();

          if (email.isEmpty || password.isEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text("Lütfen e-posta ve şifre girin"),
              ),
            );
            return;
          }

          // Kullanıcıyı oturum açma
          UserCredential userCredential =
              await _auth.signInWithEmailAndPassword(
            email: email,
            password: password,
          );

          // Kullanıcı profilini Firestore'dan al
          final userDoc = await FirebaseFirestore.instance
              .collection('users')
              .doc(userCredential.user?.uid)
              .get();

          if (userDoc.exists) {
            final isSuspended = userDoc.data()?['isSuspended'] ?? false;

            if (isSuspended) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                      "Hesabınız askıya alınmış. Lütfen destek ile iletişime geçin."),
                ),
              );
              await _auth.signOut(); // Hesap askıya alınmışsa oturumu kapat
              return;
            }
          }

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (context) => Home()), // Home sayfasına yönlendirme
          );
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Giriş başarısız"),
            ),
          );
        }
      },
      style: ElevatedButton.styleFrom(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(25), // Daha yuvarlak köşeler
        ),
        padding: const EdgeInsets.symmetric(vertical: 16),
        backgroundColor: Color(0xFF933A8E), // Renk kodu
      ),
      child: const Text(
        "Giriş Yap",
        style: TextStyle(
          fontSize: 18,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _signup(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text("Üye değil misiniz? "),
        TextButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const SignupPage()),
            );
          },
          child: const Text(
            "Üye ol",
            style: TextStyle(
                color: Color(0xFF933A8E), // Renk kodu
                fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }

  Widget _guestLogin(BuildContext context) {
    return TextButton(
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const Home()),
        );
      },
      child: const Text(
        "Misafir Olarak Görüntüle",
        style: TextStyle(
          fontSize: 18,
          color: Color(0xFF707070), // Renk kodu
        ),
      ),
    );
  }

  Widget _contactPage(BuildContext context) {
    return TextButton(
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => ContactPage()), // ContactPage yönlendirme
        );
      },
      child: const Text(
        "İletişime Geç",
        style: TextStyle(
          fontSize: 14,
          color: Color(0xFF933A8E), // Renk kodu
        ),
      ),
    );
  }
}
