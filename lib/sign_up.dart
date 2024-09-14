import 'package:felvera/login.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  _SignupPageState createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final _auth = FirebaseAuth.instance;
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  String? _errorMessage;

  void _signup() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final confirmPassword = _confirmPasswordController.text.trim();
    final firstName = _firstNameController.text.trim();
    final lastName = _lastNameController.text.trim();

    if (password != confirmPassword) {
      setState(() {
        _errorMessage = "Şifreler uyuşmuyor";
      });
      return;
    }

    try {
      UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Add user data to Firestore
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userCredential.user?.uid)
          .set({
        'firstName': firstName,
        'lastName': lastName,
        'email': email,
        'profileImageUrl': '', // Default or empty initially
        'location': '', // Default or empty initially
        'phoneNumber': '', // Default or empty initially
      });

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginPage()),
      );
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
      });
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    super.dispose();
  }

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
            _inputFields(),
            const SizedBox(height: 20),
            if (_errorMessage != null)
              Text(
                _errorMessage!,
                style: const TextStyle(color: Colors.red),
              ),
            const SizedBox(height: 20),
            _signupButton(context),
            const SizedBox(height: 10),
            _login(context),
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
        const SizedBox(height: 10),
        const Text(
          "Üye Ol",
          style: TextStyle(
            fontSize: 30,
            fontWeight: FontWeight.bold,
            color: Color(0xFF933A8E), // Renk kodu
          ),
        ),
        const SizedBox(height: 5),
        const Text(
          "Hesabınızı oluşturun",
          style: TextStyle(
            fontSize: 16,
            color: Color(0xFF707070), // Renk kodu
          ),
        ),
      ],
    );
  }

  Widget _inputFields() {
    return Column(
      children: [
        _textField(_firstNameController, "Ad", Icons.person),
        const SizedBox(height: 15),
        _textField(_lastNameController, "Soyad", Icons.person),
        const SizedBox(height: 15),
        _textField(_emailController, "E-posta", Icons.email),
        const SizedBox(height: 15),
        _textField(_passwordController, "Şifre", Icons.lock, obscureText: true),
        const SizedBox(height: 15),
        _textField(_confirmPasswordController, "Şifreyi Onayla", Icons.lock,
            obscureText: true),
      ],
    );
  }

  Widget _textField(
      TextEditingController controller, String hintText, IconData icon,
      {bool obscureText = false}) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        hintText: hintText,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(25), // Yuvarlak köşeler
          borderSide: BorderSide.none,
        ),
        filled: true,
        fillColor: Color.fromARGB(255, 243, 234, 241), // Hafif pembe opak renk
        prefixIcon: Icon(icon, color: Color(0xFF933A8E)), // Renk kodu
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      ),
      obscureText: obscureText,
    );
  }

  Widget _signupButton(BuildContext context) {
    return ElevatedButton(
      onPressed: _signup,
      style: ElevatedButton.styleFrom(
        shape: const StadiumBorder(), // Yuvarlak köşeler
        padding: const EdgeInsets.symmetric(vertical: 16),
        backgroundColor: Color(0xFF933A8E), // Renk kodu
      ),
      child: const Text(
        "Üye Ol",
        style: TextStyle(
          fontSize: 18,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _login(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text("Üye misiniz? "),
        TextButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => LoginPage()),
            );
          },
          child: const Text(
            "Giriş Yap",
            style: TextStyle(
                color: Color(0xFF933A8E), // Renk kodu
                fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }
}
