import 'package:flutter/material.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ContactPage extends StatefulWidget {
  @override
  _ContactPageState createState() => _ContactPageState();
}

class _ContactPageState extends State<ContactPage> {
  String? selectedSubject;
  final _bodyController = TextEditingController();
  final _emailController = TextEditingController();
  bool isLoading = false;

  Future<void> sendEmail(
      String recipientMail, String userEmail, String userMessage) async {
    String senderEmail = 'felveraa@gmail.com';
    String senderPassword = 'erch ktrz vexs qvcs'; // Uygulama şifresi
    String emailSubject = "Felvera Uygulaması Üzerinden Yeni Mesaj";

    String emailBody = """
Merhaba,

Uygulama üzerinden bize ulaştığınız için teşekkür ederiz.

Seçmiş olduğunuz konu: $selectedSubject

Göndermiş olduğunuz mesaj:
---------------------------------------
$userMessage
---------------------------------------

En kısa sürede size geri dönüş yapacağız.

İyi günler dileriz.
Felvera Ekibi

---
Yanıtlamak için lütfen bu e-posta adresini kullanın: $userEmail
""";

    final smtpServer =
        gmail(senderEmail, senderPassword); // Gmail SMTP sunucusu

    final message = Message()
      ..from = Address(senderEmail, 'Felvera Uygulaması Üzerinden')
      ..recipients.add(recipientMail)
      ..subject = emailSubject
      ..text = emailBody;

    try {
      setState(() {
        isLoading = true;
      });
      final sendReport = await send(message, smtpServer);
      print('Mesaj gönderildi: ' + sendReport.toString());
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("E-posta başarıyla gönderildi")),
      );
    } catch (e) {
      print('Mesaj gönderilemedi: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("E-posta gönderilemedi: ${e.toString()}")),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  void _saveToFirestore(String mail, String metin) async {
    try {
      await FirebaseFirestore.instance.collection('contact').add({
        'mail': mail,
        'konu': selectedSubject,
        'mesaj': metin,
        'isActive': true,
        'timestamp': FieldValue.serverTimestamp(),
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Veri başarıyla kaydedildi")),
      );
    } catch (e) {
      print('Veri kaydedilemedi: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Veri kaydedilemedi")),
      );
    }
  }

  void _handleSubmit() {
    String userMail = _emailController.text;
    String userMessage = _bodyController.text;

    if (selectedSubject == null || userMessage.isEmpty || userMail.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Lütfen tüm alanları doldurun")),
      );
      return;
    }

    _saveToFirestore(userMail, userMessage);
    sendEmail('felveraa@gmail.com', userMail, userMessage);
    _bodyController.clear();
    _emailController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Bize Ulaşın'),
        elevation: 0,
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: CustomPaint(
              painter: BackgroundPainter(),
            ),
          ),
          SingleChildScrollView(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Bizimle İletişime Geçin',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Color.fromARGB(255, 147, 58, 142),
                  ),
                ),
                SizedBox(height: 20),
                Text(
                  'Geri bildiriminiz bizim için önemli. Aşağıdaki formu doldurarak bize öneri, şikayet veya dileklerinizi iletebilirsiniz.',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black87,
                  ),
                ),
                SizedBox(height: 30),
                Material(
                  elevation: 6,
                  shadowColor: Colors.black.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(12),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12.0),
                    child: DropdownButtonFormField<String>(
                      value: selectedSubject,
                      hint: Text('Konu Seçin'),
                      onChanged: (String? newValue) {
                        setState(() {
                          selectedSubject = newValue;
                        });
                      },
                      items: [
                        'Öneri',
                        'Şikayet',
                        'Dilek',
                      ].map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                      decoration: InputDecoration(
                        prefixIcon: Icon(Icons.topic,
                            color: Color.fromARGB(255, 147, 58, 142)),
                        labelText: 'Konu',
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(vertical: 16.0),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 20),
                Material(
                  elevation: 6,
                  shadowColor: Colors.black.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(12),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12.0),
                    child: TextField(
                      controller: _emailController,
                      decoration: InputDecoration(
                        prefixIcon: Icon(Icons.email,
                            color: Color.fromARGB(255, 147, 58, 142)),
                        labelText: 'E-posta Adresiniz',
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(vertical: 16.0),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 20),
                Material(
                  elevation: 6,
                  shadowColor: Colors.black.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(12),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12.0),
                    child: TextField(
                      controller: _bodyController,
                      maxLines: 5,
                      decoration: InputDecoration(
                        prefixIcon: Icon(Icons.message,
                            color: Color.fromARGB(255, 147, 58, 142)),
                        labelText: 'Mesajınız',
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(vertical: 16.0),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 30),
                Center(
                  child: ElevatedButton(
                    onPressed: isLoading ? null : _handleSubmit,
                    style: ElevatedButton.styleFrom(
                      padding:
                          EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      backgroundColor: Color.fromARGB(255, 147, 58, 142),
                    ),
                    child: isLoading
                        ? CircularProgressIndicator()
                        : Text(
                            'Gönder',
                            style: TextStyle(fontSize: 18, color: Colors.white),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class BackgroundPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Color.fromARGB(255, 239, 229, 245)
      ..style = PaintingStyle.fill;

    canvas.drawCircle(Offset(size.width * 0.2, size.height * 0.3), 150, paint);
    canvas.drawCircle(Offset(size.width * 0.8, size.height * 0.7), 150, paint);
    canvas.drawCircle(Offset(size.width * 0.5, size.height * 0.8), 120, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
