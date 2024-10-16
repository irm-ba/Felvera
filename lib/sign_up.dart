import 'package:felvera/login.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'size_config.dart';

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
  bool _isKvkkAccepted = false; // KVKK onay durumu
  bool _isRulesAccepted = false; // Kullanım kuralları onay durumu

  void _signup() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final confirmPassword = _confirmPasswordController.text.trim();
    final firstName = _firstNameController.text.trim();
    final lastName = _lastNameController.text.trim();

    if (!_isKvkkAccepted) {
      setState(() {
        _errorMessage = "KVKK metnini kabul etmelisiniz.";
      });
      return;
    }

    if (!_isRulesAccepted) {
      setState(() {
        _errorMessage = "Kullanım kurallarını kabul etmelisiniz.";
      });
      return;
    }

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
        'isKvkkAccepted': _isKvkkAccepted, // KVKK onay durumu
        'isRulesAccepted': _isRulesAccepted, // Kullanım kuralları onay durumu
        'isSuspended': false, // Varsayılan olarak false
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
    SizeConfig().init(context); // Ekran boyutlarını hesapla
    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.all(
              SizeConfig.blockSizeHorizontal * 4), // Oranlı padding
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _header(context),
              SizedBox(
                  height: SizeConfig.blockSizeVertical * 2), // Oranlı boşluk
              _inputFields(),
              SizedBox(
                  height: SizeConfig.blockSizeVertical * 1), // Oranlı boşluk
              _kvkkCheckbox(),
              SizedBox(
                  height: SizeConfig.blockSizeVertical * 1), // Oranlı boşluk
              _rulesCheckbox(),
              SizedBox(height: SizeConfig.blockSizeVertical * 2),
              if (_errorMessage != null)
                Text(
                  _errorMessage!,
                  style: TextStyle(color: Colors.red),
                ),
              SizedBox(height: SizeConfig.blockSizeVertical * 2),
              _signupButton(context),
              SizedBox(height: SizeConfig.blockSizeVertical * 1),
              _login(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _header(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.only(top: SizeConfig.blockSizeVertical * 1),
          child: Image.asset('assets/images/felvera.png',
              height: SizeConfig.blockSizeVertical * 20),
        ),
        SizedBox(height: SizeConfig.blockSizeVertical * 1),
        Text(
          "Üye Ol",
          style: TextStyle(
            fontSize: SizeConfig.blockSizeHorizontal * 7, // Oranlı font
            fontWeight: FontWeight.bold,
            color: Color(0xFF933A8E),
          ),
        ),
        SizedBox(height: SizeConfig.blockSizeVertical * 1),
        Text(
          "Hesabınızı oluşturun",
          style: TextStyle(
            fontSize: SizeConfig.blockSizeHorizontal * 4,
            color: Color(0xFF707070),
          ),
        ),
      ],
    );
  }

  Widget _inputFields() {
    return Column(
      children: [
        _textField(_firstNameController, "Ad", Icons.person),
        const SizedBox(height: 10),
        _textField(_lastNameController, "Soyad", Icons.person),
        const SizedBox(height: 10),
        _textField(_emailController, "E-posta", Icons.email),
        const SizedBox(height: 10),
        _textField(_passwordController, "Şifre", Icons.lock, obscureText: true),
        const SizedBox(height: 10),
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
          borderRadius: BorderRadius.circular(25),
          borderSide: BorderSide.none,
        ),
        filled: true,
        fillColor: Color.fromARGB(255, 243, 234, 241),
        prefixIcon: Icon(icon, color: Color(0xFF933A8E)),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      ),
      obscureText: obscureText,
    );
  }

  Widget _kvkkCheckbox() {
    return Row(
      children: [
        Checkbox(
          value: _isKvkkAccepted,
          onChanged: (bool? newValue) {
            setState(() {
              _isKvkkAccepted = newValue!;
            });
          },
          checkColor: Colors.white,
          activeColor: Color(0xFF933A8E),
        ),
        Expanded(
          child: GestureDetector(
            onTap: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: Text("KVKK Metni"),
                  content: SingleChildScrollView(
                    child: Text(
                      """
Değerli Kullanıcı,

6698 sayılı Kişisel Verilerin Korunması Kanunu (KVKK) uyarınca, kişisel verilerinizin işlenmesi, korunması ve saklanmasına dair önemli bilgilendirmeler aşağıda yer almaktadır:

**1. Kişisel Verilerin Toplanması ve İşlenmesi:**
Uygulamamızı kullandığınız süre boyunca, adınız, soyadınız, e-posta adresiniz gibi kimlik ve iletişim bilgileriniz toplanabilir. Bu veriler, size daha iyi hizmet sunmak, uygulamanın fonksiyonlarını geliştirmek ve kullanıcı memnuniyetini artırmak amacıyla işlenecektir.

**2. Kişisel Verilerin Kullanım Amacı:**
Toplanan veriler, size sunulan hizmetlerin geliştirilmesi, uygulamanın etkin şekilde çalışması, iletişim kurulması ve yasal yükümlülüklerin yerine getirilmesi gibi amaçlarla kullanılacaktır.

**3. Kişisel Verilerin Paylaşımı:**
Toplanan veriler, yasal merciler ve iş ortaklarımız dışında üçüncü şahıslarla paylaşılmayacak, gizliliği sağlanacaktır. Hukuki gereklilikler doğrultusunda kişisel veriler resmi mercilerle paylaşılabilir.

**4. Kişisel Verilerin Korunması:**
Verilerinizin gizliliği ve güvenliği bizim için önemlidir. Bu veriler, yasal düzenlemelere uygun şekilde korunmakta ve izinsiz erişimlere karşı güvenlik önlemleri alınmaktadır.

**5. Haklarınız:**
KVKK kapsamında, kişisel verilerinizin işlenmesi ile ilgili olarak verilerinize erişme, düzeltme, silme veya anonim hale getirilmesini talep etme haklarınız bulunmaktadır. Bu haklarınızı kullanmak için bize başvurabilirsiniz.

**6. Veri Saklama Süresi:**
Kişisel verileriniz, ilgili yasal mevzuat doğrultusunda veya işlenme amacının ortadan kalkması halinde silinecek veya anonim hale getirilecektir.

KVKK'ya dair daha fazla bilgi almak ya da taleplerinizi iletmek için bizimle iletişime geçebilirsiniz. 

Saygılarımızla,
Felvera Ekibi
                      """,
                    ),
                  ),
                  actions: <Widget>[
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: Text("Kapat"),
                    ),
                  ],
                ),
              );
            },
            child: Text(
              "KVKK metnini kabul ediyorum",
              style: TextStyle(
                color: Color(0xFF933A8E),
                fontSize: 14,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _rulesCheckbox() {
    return Row(
      children: [
        Checkbox(
          value: _isRulesAccepted,
          onChanged: (bool? newValue) {
            setState(() {
              _isRulesAccepted = newValue!;
            });
          },
          checkColor: Colors.white,
          activeColor: Color(0xFF933A8E),
        ),
        Expanded(
          child: GestureDetector(
            onTap: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: Text("Kullanım Kuralları"),
                  content: SingleChildScrollView(
                    child: Text(
                      """
Değerli Kullanıcı,

Felvera'nın kullanım kuralları ve şartları aşağıda yer almaktadır:

**1. Kullanım Amacı:**
Felvera, evcil hayvanlar için bir sahiplendirme ve sağlık kaydı platformudur. Platformun amacı, evcil hayvanların sahiplendirilmesi ve sağlık bilgileri ile ilgili kullanıcılar arasında bilgi paylaşımını sağlamaktır.

**2. Hesap Güvenliği:**
Kullanıcılar, hesaplarının güvenliğinden sorumludur. Şifreler gizli tutulmalı ve hesabın izinsiz erişimlere karşı korunması sağlanmalıdır.

**3. İçerik Paylaşımı:**
Platformda paylaşılan içerikler (resimler, açıklamalar vb.) doğru ve ilgili olmalıdır. Yanıltıcı, yanlış veya başka amaçlar için kullanılacak içerikler paylaşılmamalıdır.

**4. Gizlilik ve Güvenlik:**
Kullanıcıların kişisel verileri ve paylaşımları gizli tutulur. Kullanıcılar, KVKK kapsamında kişisel verilerinin nasıl işlendiğini ve korunduğunu bilmelidir.

**5. Yasa Dışılıklar:**
Platformda yasadışı içerikler veya faaliyetler kesinlikle yasaktır. Kullanıcılar, platformun kurallarına ve ilgili yasal düzenlemelere uymak zorundadır.

**6. Sorumluluk:**
Felvera, platformda paylaşılan bilgilerin doğruluğu ve güvenliği konusunda sorumluluk üstlenmez. Kullanıcılar, kendi paylaşımlarından ve hesap güvenliklerinden sorumludur.

**7. Kurallarda Değişiklik:**
Kullanım kuralları zaman zaman güncellenebilir. Kullanıcılar, bu değişiklikleri takip etmeli ve kabul etmelidir.

Daha fazla bilgi veya sorularınız için bizimle iletişime geçebilirsiniz. 

Saygılarımızla,
Felvera Ekibi
                      """,
                    ),
                  ),
                  actions: <Widget>[
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: Text("Kapat"),
                    ),
                  ],
                ),
              );
            },
            child: Text(
              "Kullanım kurallarını kabul ediyorum",
              style: TextStyle(
                color: Color(0xFF933A8E),
                fontSize: 14,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _signupButton(BuildContext context) {
    return ElevatedButton(
      onPressed: _signup,
      style: ElevatedButton.styleFrom(
        backgroundColor: Color(0xFF933A8E),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(
              SizeConfig.blockSizeHorizontal * 5), // Oranlı radius
        ),
        padding:
            EdgeInsets.symmetric(vertical: SizeConfig.blockSizeVertical * 2),
      ),
      child: Text(
        "Üye Ol",
        style: TextStyle(
          fontSize: SizeConfig.blockSizeHorizontal * 4, // Oranlı font
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _login(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text("Zaten bir hesabınız var mı?"),
        TextButton(
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => LoginPage()),
            );
          },
          child: const Text(
            "Giriş Yap",
            style: TextStyle(
              color: Color(0xFF933A8E),
              fontSize: 16,
            ),
          ),
        ),
      ],
    );
  }
}
