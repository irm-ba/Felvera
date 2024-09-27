import 'package:flutter/material.dart';

class PrivacyPolicyPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Gizlilik Politikası'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Felvera Gizlilik Politikası',
              style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Color.fromARGB(255, 147, 58, 142)),
            ),
            SizedBox(height: 20),
            _buildSection('1. Giriş',
                'Felvera olarak, kullanıcılarımızın gizliliğine büyük önem veriyoruz. Bu Gizlilik Politikası, uygulamamızın kullanımında topladığımız kişisel bilgilerin nasıl işlendiğini, saklandığını ve korunduğunu açıklamaktadır.'),
            _buildSection('2. Toplanan Bilgiler',
                'Uygulama kullanımınız sırasında, aşağıdaki bilgileri toplayabiliriz:\n- Kullanıcı Bilgileri: Ad, soyad, e-posta adresi, kullanıcı adı.\n- Hayvan Bilgileri: Sahiplendirmek istediğiniz hayvanın adı, türü, yaşı, sağlık bilgileri, fotoğraflar.\n- Cihaz Bilgileri: Cihaz türü, işletim sistemi, benzersiz cihaz tanımlayıcıları.\n- Konum Bilgileri: Sahiplenme sürecinde konum bilgilerinizi kullanabiliriz.'),
            _buildSection('3. Bilgilerin Kullanımı',
                'Topladığımız bilgileri şu amaçlarla kullanıyoruz:\n- Hizmet Sunumu: Uygulama hizmetlerini sunmak ve yönetmek.\n- Geliştirme: Uygulamayı geliştirmek ve kullanıcı deneyimini iyileştirmek.\n- İletişim: Kullanıcılarla iletişim kurmak, destek sağlamak ve bilgilendirmeler yapmak.\n- Güvenlik: Kullanıcı verilerini korumak ve kötüye kullanımları önlemek.'),
            _buildSection('4. Bilgilerin Paylaşımı',
                'Felvera, kullanıcı bilgilerini üçüncü şahıslarla paylaşmaz, satmaz veya kiralamaz. Ancak, aşağıdaki durumlarda bilgilerinizi paylaşabiliriz:\n- Yasal taleplere yanıt vermek.\n- Hizmet sağlayıcılarla işbirliği yapmak (örneğin, bulut depolama sağlayıcıları).\n- Felvera\'nın haklarını ve güvenliğini korumak.'),
            _buildSection('5. Veri Güvenliği',
                'Kullanıcı bilgilerinin güvenliğini sağlamak için çeşitli güvenlik önlemleri uyguluyoruz. Ancak, internet üzerinden veri aktarımının tamamen güvenli olduğunu garanti edemeyiz. Herhangi bir güvenlik ihlali durumunda, sizi bilgilendireceğiz.'),
            _buildSection('6. Çocukların Gizliliği',
                'Felvera, 13 yaşından küçük çocuklardan bilerek bilgi toplamaz. 13 yaşından küçük bir çocuğun bilgilerini topladığımızı fark edersek, bu bilgileri derhal sileceğiz. Ancak, kullanıcıların yaşını doğrulamak için herhangi bir özel işlem yapmamaktayız. Bu nedenle, 13 yaşından küçük çocukların uygulamayı kullanmamalarını önemle tavsiye ediyoruz.')
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, String content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Color.fromARGB(255, 147, 58, 142)),
          ),
          SizedBox(height: 8),
          Text(
            content,
            style: TextStyle(fontSize: 16, color: Colors.black87),
          ),
        ],
      ),
    );
  }
}
