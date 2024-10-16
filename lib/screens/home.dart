import 'package:felvera/Contact.dart';
import 'package:felvera/Event.dart';
import 'package:felvera/aboutpage.dart';
import 'package:felvera/account.dart';
import 'package:felvera/blogPage.dart';
import 'package:felvera/chatList.dart';
import 'package:felvera/constants.dart';
import 'package:felvera/models/pet_data.dart';
import 'package:felvera/privacy.dart';
import 'package:felvera/widgets/CustomBottomNavigationBar.dart';
import 'package:felvera/widgets/lostanimalpge.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../widgets/pet_grid_list.dart';
import '../login.dart';
import '../forum.dart';

// EventPage import edildi

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  String selectedCategory = 'Tüm İlanlar';
  String selectedAnimalType = '';
  String ageRange = '';
  String location = '';

  // Kullanıcı değerlendirme yanıtlarını tutan değişkenler
  int rating = 0; // Kullanıcıdan 1-5 arasında bir değerlendirme almak için
  String feedback = ''; // Kullanıcı geri bildirimi
  int adoptionProcessRating =
      0; // Hayvan Sahiplendirme Süreci Değerlendirme Değişkeni
  int healthServiceRating =
      0; // Sağlık Kontrolü Hizmeti Değerlendirme Değişkeni

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: CustomBottomNavigationBar(),
      drawer: Drawer(
        child: Column(
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color.fromARGB(255, 147, 58, 142), // Kbrown rengi
                    Color.fromARGB(255, 169, 85, 210) // İkinci renk
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  stops: [0.3, 0.7], // Geçişlerin belirgin olduğu noktalar
                ),
              ),
              child: Center(
                child: Text(
                  'Menu',
                  style: TextStyle(
                    color: Color.fromARGB(255, 255, 255, 255),
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  ListTile(
                    leading: Icon(Icons.person,
                        color: Color.fromARGB(255, 147, 58, 142)),
                    title: Text('Profil'),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => AccountPage()),
                      );
                    },
                  ),
                  ListTile(
                    leading: Icon(Icons.announcement_outlined,
                        color: Color.fromARGB(255, 147, 58, 142)),
                    title: Text('Bize Ulaşın'),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => ContactPage()),
                      );
                    },
                  ),
                  ListTile(
                    leading: Icon(Icons.accessibility_new_sharp,
                        color: Color.fromARGB(255, 147, 58, 142)),
                    title: Text('Hakkımızda'),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => AboutUsPage()),
                      );
                    },
                  ),
                  ListTile(
                    leading: Icon(Icons.chat_outlined,
                        color: Color.fromARGB(255, 147, 58, 142)),
                    title: Text('Mesaj'),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => ChatListPage()),
                      );
                    },
                  ),
                  ListTile(
                    leading: Icon(Icons.wysiwyg_outlined,
                        color: Color.fromARGB(255, 147, 58, 142)),
                    title: Text('Gizlilik sözleşmesi'),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => PrivacyPolicyPage()),
                      );
                    },
                  ),
                  Divider(),
                  ListTile(
                    leading: Icon(Icons.logout_rounded,
                        color: Color.fromARGB(255, 147, 58, 142)),
                    title: Text('Çıkış yap'),
                    onTap: () async {
                      try {
                        // Firebase Authentication ile çıkış yapma
                        await FirebaseAuth.instance.signOut();
                        // Çıkış yaptıktan sonra LoginPage'e yönlendirme
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (context) => LoginPage()),
                        );
                      } catch (e) {
                        // Hata durumunda kullanıcıyı bilgilendirmek için bir yöntem ekleyebilirsiniz
                        print('Çıkış yapma hatası: $e');
                      }
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      appBar: AppBar(
        leading: Builder(
          builder: (context) => Padding(
            padding: EdgeInsets.all(8.0),
            child: CircleAvatar(
              radius: 20,
              child: IconButton(
                icon: Icon(Icons.menu_rounded, color: kBrownColor),
                onPressed: () {
                  Scaffold.of(context).openDrawer();
                },
              ),
            ),
          ),
        ),
        title: Align(
          alignment: Alignment.center, // Yazıyı ortalar
          child: Text(
            'Felvera',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.star, color: Color.fromARGB(255, 147, 58, 142)),
            onPressed: _showRatingDialog,
          ),
        ],
      ),
      body: Column(
        children: [
          /// Kategoriler
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildCategoryButton('Tüm İlanlar'),
                _buildCategoryButton('Kayıp İlanları'),
                _buildCategoryButton('Gönüllülük Etkinlikleri'),
                _buildCategoryButton('Forum'),
                _buildCategoryButton('Blog'),
              ],
            ),
          ),
          const SizedBox(height: 24),
    
          Expanded(
            child: selectedCategory == 'Blog'
                ? BlogPage()
                : selectedCategory == 'Forum'
                    ? ForumPage()
                    : selectedCategory == 'Gönüllülük Etkinlikleri'
                        ? EventPage()
                        : selectedCategory == 'Kayıp İlanları'
                            ? LostAnimalsPage()
                            : StreamBuilder(
                                stream: _getCategoryStream(selectedCategory),
                                builder: (context,
                                    AsyncSnapshot<QuerySnapshot> snapshot) {
                                  if (snapshot.connectionState ==
                                      ConnectionState.waiting) {
                                    return Center(
                                        child: CircularProgressIndicator());
                                  }
                                  if (snapshot.hasError) {
                                    return Center(
                                        child: Text(
                                            'Hata oluştu: ${snapshot.error}'));
                                  }
                                  if (!snapshot.hasData ||
                                      snapshot.data!.docs.isEmpty) {
                                    return Center(
                                      child: Text(
                                        selectedCategory ==
                                                'Gönüllülük Etkinlikleri'
                                            ? 'Henüz gönüllülük etkinliği bulunmamaktadır.'
                                            : 'Hiç hayvan bulunamadı.',
                                      ),
                                    );
                                  }
    
                                  // Firestore'dan gelen verileri PetData listesine dönüştürme
                                  List<PetData> pets = snapshot.data!.docs
                                      .map((DocumentSnapshot doc) {
                                    return PetData.fromSnapshot(doc);
                                  }).toList();
    
                                  return PetGridList(
                                      pets:
                                          pets); // Burada pets parametresini geçiyoruz
                                },
                              ),
          ),
        ],
      ),
    );
  }

  void _showRatingDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Uygulamayı Değerlendir'),
          content: StatefulBuilder(
            builder: (context, setState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Uygulamamızı 1-5 arasında yıldızlarla değerlendirin:'),

                  // Genel Yıldız Değerlendirme Kısmı
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(5, (index) {
                      return IconButton(
                        icon: Icon(
                          index < rating ? Icons.star : Icons.star_border,
                          color: Color.fromARGB(255, 147, 58, 142),
                        ),
                        onPressed: () {
                          setState(() {
                            rating = index + 1;
                          });
                        },
                      );
                    }),
                  ),
                  const SizedBox(height: 10),

                  // Soru 1: Hayvan Sahiplendirme Süreci
                  Text(
                      '1. Hayvan sahiplendirme sürecini nasıl değerlendirirsiniz?'),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(5, (index) {
                      return IconButton(
                        icon: Icon(
                          index < adoptionProcessRating
                              ? Icons.star
                              : Icons.star_border,
                          color: Color.fromARGB(255, 147, 58, 142),
                        ),
                        onPressed: () {
                          setState(() {
                            adoptionProcessRating = index + 1;
                          });
                        },
                      );
                    }),
                  ),
                  const SizedBox(height: 10),

                  // Soru 2: Sağlık Kontrolü Hizmeti
                  Text(
                      '2. Sağlık kontrolü hizmetini nasıl değerlendirirsiniz?'),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(5, (index) {
                      return IconButton(
                        icon: Icon(
                          index < healthServiceRating
                              ? Icons.star
                              : Icons.star_border,
                          color: Color.fromARGB(255, 147, 58, 142),
                        ),
                        onPressed: () {
                          setState(() {
                            healthServiceRating = index + 1;
                          });
                        },
                      );
                    }),
                  ),
                  const SizedBox(height: 10),

                  // Geri Bildirim Metni
                  TextField(
                    decoration: InputDecoration(
                      labelText: 'Fikir ve görüşleriniz için',
                    ),
                    onChanged: (value) {
                      setState(() {
                        feedback = value;
                      });
                    },
                  ),
                ],
              );
            },
          ),
          actions: [
            TextButton(
              child: Text('İptal'),
              onPressed: () {
                // Alanları temizle
                setState(() {
                  rating = 0;
                  adoptionProcessRating = 0;
                  healthServiceRating = 0;
                  feedback = '';
                });
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Gönder'),
              onPressed: () async {
                await _submitFeedback(); // Geri bildirimi gönder
                // Alanları temizle
                setState(() {
                  rating = 0;
                  adoptionProcessRating = 0;
                  healthServiceRating = 0;
                  feedback = '';
                });
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _submitFeedback() async {
    try {
      // Firestore'a geri bildirim verilerini kaydet
      await FirebaseFirestore.instance.collection('feedbacks').add({
        'rating': rating,
        'adoptionProcessRating': adoptionProcessRating,
        'healthServiceRating': healthServiceRating,
        'feedback': feedback,
        'timestamp': FieldValue.serverTimestamp(), // Zaman damgası
      });

      // Başarılı kaydetme işlemi sonrası kullanıcıya bilgi ver
      print('Geri bildirim başarıyla kaydedildi.');
    } catch (e) {
      // Hata durumunda
      print('Geri bildirim kaydedilirken bir hata oluştu: $e');
    }
  }

  Widget _buildCategoryButton(String category, {bool isNavigable = false}) {
    return GestureDetector(
      onTap: () {
        if (category == 'Kayıp İlanları' && isNavigable) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => LostAnimalsPage()),
          );
        } else {
          setState(() {
            selectedCategory = category;
          });
        }
      },
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 10),
        padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
        decoration: BoxDecoration(
          color: selectedCategory == category
              ? Color.fromARGB(255, 147, 58, 142)
              : Colors.grey[300],
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          category,
          style: TextStyle(
            color: selectedCategory == category ? Colors.white : Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Stream<QuerySnapshot> _getCategoryStream(String category) {
    CollectionReference collection =
        FirebaseFirestore.instance.collection('pet');

    Query query = collection;

    if (category == 'Kayıp İlanları') {
      query = FirebaseFirestore.instance.collection('lost_animals');
    } else if (category == 'Gönüllülük Etkinlikleri') {
      return FirebaseFirestore.instance
          .collection('volunteering_events')
          .snapshots();
    }

    // `status` alanı "onaylandı" olan hayvanları hariç tutma
    query = query.where('status', isNotEqualTo: 'Onaylandı');

    // Filtreleme kriterlerini uygulama
    if (selectedAnimalType.isNotEmpty) {
      query = query.where('animalType', isEqualTo: selectedAnimalType);
    }

    if (ageRange.isNotEmpty) {
      // Yaş aralığını işleme
      List<String> ageRangeParts = ageRange.split('-');
      if (ageRangeParts.length == 2) {
        int minAge = int.tryParse(ageRangeParts[0].trim()) ?? 0;
        int maxAge = int.tryParse(ageRangeParts[1].trim()) ?? 0;
        query = query
            .where('age', isGreaterThanOrEqualTo: minAge)
            .where('age', isLessThanOrEqualTo: maxAge);
      }
    }

    if (location.isNotEmpty) {
      query = query.where('location', isEqualTo: location);
    }

    return query.snapshots();
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Filtrele'),
          content: StatefulBuilder(
            builder: (context, setState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Hayvan türü seçimi
                  DropdownButton<String>(
                    value: selectedAnimalType.isNotEmpty
                        ? selectedAnimalType
                        : null,
                    hint: Text('Hayvan Türü'),
                    onChanged: (String? newValue) {
                      setState(() {
                        selectedAnimalType = newValue ?? '';
                      });
                    },
                    items: [
                      'Kedi',
                      'Köpek',
                      'Kuş',
                      'Balık',
                      'Hamster',
                      'Tavşan',
                      'Kaplumbağa',
                      'Yılan',
                      'Kertenkele',
                      'Sürüngen',
                      'Böcek',
                      'Diğer'
                    ].map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                  ),
                  // Yaş aralığı seçimi
                  TextField(
                    decoration: InputDecoration(
                      labelText: 'Yaş Aralığı (ör. 1-5)',
                    ),
                    onChanged: (value) {
                      setState(() {
                        ageRange = value;
                      });
                    },
                  ),
                  // Konum seçimi
                  DropdownButton<String>(
                    value: location.isNotEmpty ? location : null,
                    hint: Text('Konum'),
                    onChanged: (String? newValue) {
                      setState(() {
                        location = newValue ?? '';
                      });
                    },
                    items: [
                      'Adana',
                      'Adıyaman',
                      'Afyonkarahisar',
                      'Ağrı',
                      'Aksaray',
                      'Amasya',
                      'Ankara',
                      'Antalya',
                      'Ardahan',
                      'Artvin',
                      'Aydın',
                      'Balıkesir',
                      'Bartın',
                      'Batman',
                      'Bayburt',
                      'Bilecik',
                      'Bingöl',
                      'Bitlis',
                      'Bolu',
                      'Burdur',
                      'Bursa',
                      'Çanakkale',
                      'Çankırı',
                      'Çorum',
                      'Denizli',
                      'Diyarbakır',
                      'Düzce',
                      'Edirne',
                      'Elazığ',
                      'Erzincan',
                      'Erzurum',
                      'Eskişehir',
                      'Gaziantep',
                      'Giresun',
                      'Gümüşhane',
                      'Hakkari',
                      'Hatay',
                      'Iğdır',
                      'Isparta',
                      'İstanbul',
                      'İzmir',
                      'Kahramanmaraş',
                      'Karabük',
                      'Karaman',
                      'Kars',
                      'Kayseri',
                      'Kırıkkale',
                      'Kırklareli',
                      'Kırşehir',
                      'Kocaeli',
                      'Konya',
                      'Kütahya',
                      'Malatya',
                      'Manisa',
                      'Mardin',
                      'Mersin',
                      'Muğla',
                      'Muş',
                      'Nevşehir',
                      'Niğde',
                      'Ordu',
                      'Osmaniye',
                      'Rize',
                      'Sakarya',
                      'Samsun',
                      'Siirt',
                      'Sinop',
                      'Sivas',
                      'Şanlıurfa',
                      'Şırnak',
                      'Tekirdağ',
                      'Tokat',
                      'Trabzon',
                      'Tunceli',
                      'Uşak',
                      'Van',
                      'Yalova',
                      'Yozgat',
                      'Zonguldak'
                    ].map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                  ),
                ],
              );
            },
          ),
          actions: [
            TextButton(
              child: Text('İptal'),
              onPressed: () {
                Navigator.of(context).pop();
                setState(() {
                  // İptal butonuna basıldığında filtreleme değerlerini sıfırla
                  selectedAnimalType = '';
                  ageRange = '';
                  location = '';
                });
              },
            ),
            TextButton(
              child: Text('Uygula'),
              onPressed: () {
                Navigator.of(context).pop();
                setState(() {
                  // Filtreleme değerlerini güncelle
                });
              },
            ),
          ],
        );
      },
    );
  }
}
