import 'package:felvera/Contact.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:felvera/screens/home.dart';
import 'sign_up.dart';
import 'size_config.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool _rememberMe = false; // Checkbox durumu için değişken

  @override
  void initState() {
    super.initState();
    _checkLoginStatus(); // Uygulama açıldığında oturum kontrolü yap
    _loadSavedCredentials(); // Kayıtlı e-posta ve şifreyi yükle
  }

  void _checkLoginStatus() async {
    // Oturum durumunu kontrol et
  }

  void _loadSavedCredentials() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? email = prefs.getString('email');
    String? password = prefs.getString('password');

    if (email != null) {
      emailController.text = email;
    }
    if (password != null) {
      passwordController.text = password;
    }
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);

    //buradan-------------------------------------
        // Ekran genişliğini alıyoruz
    double screenWidth = MediaQuery.of(context).size.width;

    double horizontalPadding = screenWidth;
if (screenWidth <= 400) {
    // Küçük ekranlar için boşluk
    horizontalPadding = SizeConfig.blockSizeHorizontal * 5;
} else if (screenWidth <= 600) {
    // Orta büyüklükte ekranlar için boşluk
    horizontalPadding = SizeConfig.blockSizeHorizontal * 10;
} else if (screenWidth <= 800) {
    // Büyük ekranlar için boşluk
    horizontalPadding = SizeConfig.blockSizeHorizontal * 15;
} else if (screenWidth <= 1200) {
    // Daha büyük ekranlar için boşluk
    horizontalPadding = SizeConfig.blockSizeHorizontal * 20;
} else {
    // Çok geniş ekranlar için maksimum boşluk
    horizontalPadding = SizeConfig.blockSizeHorizontal * 25;
}

//buraya recep ---------------------------------------

    return Scaffold(
      body: Container(
       padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _header(context),
            SizedBox(height: SizeConfig.blockSizeVertical * 3),
            _inputField(context),
            SizedBox(height: SizeConfig.blockSizeVertical * 2),
            _forgotPassword(context),
            SizedBox(height: SizeConfig.blockSizeVertical * 2),
            _loginButton(context),
            SizedBox(height: SizeConfig.blockSizeVertical),
            _guestLogin(context),
            SizedBox(height: SizeConfig.blockSizeVertical * 2),
            _signup(context),
            SizedBox(height: SizeConfig.blockSizeVertical * 2),
            _contactPage(context),
          ],
        ),
      ),
    );
  }

  Widget _header(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.only(top: SizeConfig.blockSizeVertical!),
          child: Image.asset('assets/images/felvera.png',
              height: SizeConfig.blockSizeVertical! * 25),
        ),
        SizedBox(height: SizeConfig.blockSizeVertical!),
        const Text(
          "HOŞGELDİNİZ",
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Color(0xFF933A8E),
          ),
        ),
        SizedBox(height: SizeConfig.blockSizeVertical!),
        const Text(
          "Hayvan dostlarımız yuva bulsun",
          style: TextStyle(
            fontSize: 16,
            color: Color(0xFF707070),
            fontStyle: FontStyle.normal,
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
              borderRadius: BorderRadius.circular(25),
              borderSide: BorderSide.none,
            ),
            filled: true,
            fillColor: Color.fromARGB(255, 243, 234, 241),
            prefixIcon: const Icon(
              Icons.person,
              color: Color(0xFF933A8E),
            ),
            contentPadding: EdgeInsets.symmetric(
              horizontal: SizeConfig.blockSizeHorizontal! * 5,
              vertical: SizeConfig.blockSizeVertical! * 2,
            ),
          ),
        ),
        SizedBox(height: SizeConfig.blockSizeVertical * 1.5),
        TextField(
          controller: passwordController,
          decoration: InputDecoration(
            hintText: "Şifre",
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(25),
              borderSide: BorderSide.none,
            ),
            filled: true,
            fillColor: Color.fromARGB(255, 243, 234, 241),
            prefixIcon: const Icon(
              Icons.lock,
              color: Color(0xFF933A8E),
            ),
            contentPadding: EdgeInsets.symmetric(
              horizontal: SizeConfig.blockSizeHorizontal! * 5,
              vertical: SizeConfig.blockSizeVertical! * 2,
            ),
          ),
          obscureText: true,
        ),
        // Beni hatırla Checkbox'ı ekle
        Row(
          children: [
            Checkbox(
              value: _rememberMe,
              onChanged: (value) {
                setState(() {
                  _rememberMe = value!;
                });
              },
            ),
            const Text("Beni Hatırla"),
          ],
        ),
      ],
    );
  }

  Widget _forgotPassword(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: TextButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              final TextEditingController _emailController =
                  TextEditingController();

              return AlertDialog(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                backgroundColor: Colors.white,
                title: const Text(
                  "Şifremi Unuttum",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF933A8E),
                    fontSize: 20,
                  ),
                ),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: _emailController,
                      style: TextStyle(color: Colors.black),
                      decoration: InputDecoration(
                        hintText: "E-Posta",
                        hintStyle: TextStyle(color: Colors.grey.shade500),
                        filled: true,
                        fillColor: Colors.grey.shade100,
                        contentPadding: EdgeInsets.symmetric(
                          vertical: SizeConfig.blockSizeVertical! * 2,
                          horizontal: SizeConfig.blockSizeHorizontal! * 4,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    SizedBox(height: SizeConfig.blockSizeVertical! * 2),
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
                          Navigator.of(context).pop();
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
                          borderRadius: BorderRadius.circular(15),
                        ),
                        padding: EdgeInsets.symmetric(
                          vertical: SizeConfig.blockSizeVertical! * 1.5,
                          horizontal: SizeConfig.blockSizeHorizontal! * 6,
                        ),
                        backgroundColor: const Color(0xFF933A8E),
                        elevation: 5,
                      ),
                      child: const Text(
                        "Gönder",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
        child: const Text(
          "Şifrenizi mi unuttunuz?",
          style: TextStyle(
            color: Color(0xFF933A8E),
          ),
        ),
      ),
    );
  }

  Widget _signup(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text("Hesabınız yok mu?"),
        TextButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => SignupPage()),
            );
          },
          child: const Text(
            "Kayıt Ol",
            style: TextStyle(
              color: Color(0xFF933A8E),
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  Widget _loginButton(BuildContext context) {
    return ElevatedButton(
      onPressed: () async {
        String email = emailController.text.trim();
        String password = passwordController.text.trim();

        try {
          UserCredential userCredential =
              await _auth.signInWithEmailAndPassword(
            email: email,
            password: password,
          );

          // "Beni Hatırla" seçeneği seçildiyse bilgileri kaydet
          if (_rememberMe) {
            SharedPreferences prefs = await SharedPreferences.getInstance();
            await prefs.setString('email', email);
            await prefs.setString('password', password);
          } else {
            // Seçenek seçilmediyse bilgileri temizle
            SharedPreferences prefs = await SharedPreferences.getInstance();
            await prefs.remove('email');
            await prefs.remove('password');
          }

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => Home()),
          );
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Giriş yapılamadı, lütfen tekrar deneyin."),
            ),
          );
          print("Giriş hatası: $e"); // Debug
        }
      },
      style: ElevatedButton.styleFrom(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(25),
        ),
        padding: EdgeInsets.symmetric(
          vertical: SizeConfig.blockSizeVertical! * 1.5,
          horizontal: SizeConfig.blockSizeHorizontal! * 6,
        ),
        backgroundColor: const Color(0xFF933A8E),
        elevation: 5,
      ),
      child:  Text(
        "Giriş Yap",
        style: TextStyle(
          color: Colors.white,
          fontSize:
                  SizeConfig.scaledFontSize(14),
          fontWeight: FontWeight.bold,
        ),
      ),
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
          color: Color(0xFF707070),
        ),
      ),
    );
  }

  Widget _contactPage(BuildContext context) {
    return TextButton(
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => ContactPage()),
        );
      },
      child: const Text(
        "Bize Ulaşın",
        style: TextStyle(color: Color(0xFF933A8E)),
      ),
    );
  }
}
