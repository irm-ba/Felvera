import 'dart:io';
import 'package:felvera/firebase/petimage.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'models/lost_animal_data.dart';

class MainScreen extends StatefulWidget {
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Hayvan İlanları"),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: "İlan Ekle"),
            Tab(text: "Kayıp İlan Ekle"),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          const ProductAdd(),
          LostAnimalAdd(),
        ],
      ),
    );
  }
}

class ProductAdd extends StatefulWidget {
  const ProductAdd({Key? key}) : super(key: key);

  @override
  State<ProductAdd> createState() => _ProductAddState();
}

class _ProductAddState extends State<ProductAdd> {
  void uploadPetImage(String imagePath) async {
    bool isValid = await isPetImage(imagePath);
    if (isValid) {
      print('Geçerli hayvan resmi. Yükleniyor...');
      // Resmi Firebase Storage'a yükleyin
    } else {
      print('Bu resim hayvan resmi değil.');
      // Uyarı mesajı göster
    }
  }

  final TextEditingController nameController = TextEditingController();
  final TextEditingController breedController = TextEditingController();
  final TextEditingController ageController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController healthStatusController = TextEditingController();
  final TextEditingController animalTypeController = TextEditingController();

  String? selectedLocation;
  bool isGenderMale = true;
  List<File> _images = [];
  File? _healthCardImage;
  final picker = ImagePicker();

  String selectedPetType = "Kedi";

  get animalTypes => null;

  Future<void> _getImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    setState(() {
      if (pickedFile != null) {
        _images.add(File(pickedFile.path));
      } else {
        print('Resim seçilmedi');
      }
    });
  }

  Future<void> _getHealthCardImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    setState(() {
      if (pickedFile != null) {
        _healthCardImage = File(pickedFile.path);
      } else {
        print('Sağlık kartı resmi seçilmedi');
      }
    });
  }

  void _removeImage(int index) {
    setState(() {
      _images.removeAt(index);
    });
  }

  Future<String?> _uploadFile(File file, String folder) async {
    final storageRef =
    FirebaseStorage.instance.ref().child('$folder/${Uuid().v4()}');
    try {
      await storageRef.putFile(file);
      return await storageRef.getDownloadURL();
    } catch (e) {
      print('Dosya yükleme hatası: $e');
      return null;
    }
  }

  Future<void> _submitForm() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Kullanıcı oturum açmamış.'),
        ),
      );
      return;
    }
    if (nameController.text.isEmpty ||
        breedController.text.isEmpty ||
        ageController.text.isEmpty ||
        _images.isEmpty ||
        healthStatusController.text.isEmpty ||
        selectedLocation == null ||
        selectedPetType == null ||
        descriptionController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content:
          Text('Lütfen tüm zorunlu alanları doldurun ve resim ekleyin.'),
        ),
      );
      return;
    }
    String userId = user.uid; // Kullanıcının ID'sini al
    String petId = const Uuid().v4(); // Benzersiz bir kimlik

    // Fotoğrafları ve sağlık kartını Firebase Storage'a yükleyin
    List<String> imageUrls = [];
    for (var image in _images) {
      bool isValid = await isPetImage(image.path); // Hayvan resmi doğrulama
      if (isValid) {
        print('Geçerli hayvan resmi. Yükleniyor...');
        var imageUrl = await _uploadFile(image, 'pet_images');
        if (imageUrl != null) imageUrls.add(imageUrl);
      } else {
        print('Bu resim hayvan resmi değil.');
        // İsteğe bağlı olarak kullanıcıya uyarı gösterin
      }
    }

    String? healthCardUrl = _healthCardImage != null
        ? await _uploadFile(_healthCardImage!, 'health_card_images')
        : null;

    final newPet = PetData(
      name: nameController.text,
      breed: breedController.text,
      isGenderMale: isGenderMale,
      age: int.parse(ageController.text),
      imageUrl: imageUrls.isNotEmpty ? imageUrls[0] : '',
      healthStatus: healthStatusController.text,
      healthCardImageUrl: healthCardUrl ?? '',
      description: descriptionController.text,
      animalType: selectedPetType,
      location: selectedLocation!,
      userId: userId,
      petId: petId,
      status: 'Available', // Status alanını ekleyin
    );

// Firestore'a veri ekleme
    final firestore = FirebaseFirestore.instance;
    await firestore.collection('pet').doc(petId).set({
      'name': newPet.name,
      'breed': newPet.breed,
      'isGenderMale': newPet.isGenderMale,
      'age': newPet.age,
      'imageUrl': newPet.imageUrl,
      'healthStatus': newPet.healthStatus,
      'healthCardImageUrl': newPet.healthCardImageUrl,
      'description': newPet.description,
      'animalType': newPet.animalType,
      'location': newPet.location,
      'userId': newPet.userId,
      'petId': newPet.petId,
      'status': newPet.status, // Status alanını ekleyin
    });

    // ignore: use_build_context_synchronously
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Hayvan başarıyla eklendi!'),
      ),
    );

    // Formu sıfırlama
    nameController.clear();
    breedController.clear();
    ageController.clear();
    descriptionController.clear();
    healthStatusController.clear();
    animalTypeController.clear();
    setState(() {
      _images.clear();
      _healthCardImage = null;
      selectedLocation = null;
      isGenderMale = true; // Default gender
    });
  }

  @override
  Widget build(BuildContext context) {
    List<String> cities = [
      'Adana',
      'Adıyaman',
      'Afyonkarahisar',
      'Ağrı',
      'Aksaray',
      'Amasya',
      'Ankara',
      'Antalya',
      'Artvin',
      'Aydın',
      'Balıkesir',
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
      'Kastamonu',
      'Kayseri',
      'Kırıkkale',
      'Kırklareli',
      'Kırşehir',
      'Kilis',
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
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: <Widget>[
          TextField(
            controller: nameController,
            decoration: const InputDecoration(labelText: 'Hayvan Adı'),
          ),
          TextField(
            controller: breedController,
            decoration: const InputDecoration(labelText: 'Cinsi'),
          ),
          TextField(
            controller: ageController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: 'Yaşı'),
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(2), // En fazla 2 karakter
            ],
          ),
          TextField(
            controller: descriptionController,
            decoration: const InputDecoration(labelText: 'Açıklama'),
          ),
          TextField(
            controller: healthStatusController,
            decoration: const InputDecoration(labelText: 'Sağlık Durumu'),
          ),

          // Hayvan türlerini tanımlayın
          DropdownButtonFormField<String>(
            decoration: const InputDecoration(labelText: 'Hayvan Türü'),
            value: selectedPetType,
            items: <String>['Kedi', 'Köpek', 'Kuş', 'Diğer']
                .map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
            onChanged: (newValue) {
              setState(() {
                selectedPetType = newValue!;
              });
            },
          ),

          DropdownButtonFormField<String>(
            value: selectedLocation,
            decoration: const InputDecoration(labelText: 'Konum'),
            items: cities.map((String city) {
              return DropdownMenuItem<String>(
                value: city,
                child: Text(city),
              );
            }).toList(),
            onChanged: (newValue) {
              setState(() {
                selectedLocation = newValue;
              });
            },
          ),
          Row(
            children: [
              const Text('Cinsiyet: '),
              Radio(
                value: true,
                groupValue: isGenderMale,
                onChanged: (bool? value) {
                  setState(() {
                    isGenderMale = value ?? true;
                  });
                },
              ),
              const Text('Erkek'),
              Radio(
                value: false,
                groupValue: isGenderMale,
                onChanged: (bool? value) {
                  setState(() {
                    isGenderMale = value ?? false;
                  });
                },
              ),
              const Text('Dişi'),
            ],
          ),
          Row(
            children: [
              GestureDetector(
                onTap: _getImage,
                child: Container(
                  height: 200,
                  color: Colors.grey[300],
                  width: 180,
                  child: _images.isEmpty
                      ? const Center(child: Text("Resim Ekle"))
                      : Wrap(
                    spacing: 8.0,
                    children: List.generate(_images.length, (index) {
                      return Stack(
                        children: [
                          Image.file(
                            _images[index],
                            width: 180,
                            height: 200,
                            fit: BoxFit.cover,
                          ),
                          Positioned(
                            right: 0,
                            child: IconButton(
                              icon: const Icon(Icons.remove_circle),
                              onPressed: () => _removeImage(index),
                            ),
                          ),
                        ],
                      );
                    }),
                  ),
                ),
              ),
              const SizedBox(
                width: 8,
              ),
              GestureDetector(
                onTap: _getHealthCardImage,
                child: Container(
                  height: 200,
                  color: Colors.grey[300],
                  width: 180,
                  child: _healthCardImage == null
                      ? const Center(child: Text("Sağlık Kartı Ekle"))
                      : Wrap(
                    spacing: 8.0,
                    children: [
                      Stack(
                        children: [
                          Image.file(
                            _healthCardImage!,
                            width: 180,
                            height: 200,
                            fit: BoxFit.cover,
                          ),
                          Positioned(
                            right: 0,
                            child: IconButton(
                              icon: const Icon(Icons.remove_circle),
                              onPressed: () {
                                setState(() {
                                  _healthCardImage = null;
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16.0),
          ElevatedButton(
            onPressed: _submitForm,
            child: const Text('İlanı Gönder'),
            style: ElevatedButton.styleFrom(
              foregroundColor: Colors.white,
              backgroundColor: Color.fromARGB(255, 147, 58, 142),
              padding: EdgeInsets.symmetric(vertical: 10, horizontal: 110),
              textStyle: TextStyle(fontSize: 18),
            ),
          ),
        ],
      ),
    );
  }
}

class PetData {
  final String name;
  final String breed;
  final bool isGenderMale;
  final int age;
  final String imageUrl;
  final String healthStatus;
  final String healthCardImageUrl;
  final String description;
  final String animalType;
  final String location;
  final String userId;
  final String petId;
  final String status; // Status alanını ekleyin

  PetData({
    required this.name,
    required this.breed,
    required this.isGenderMale,
    required this.age,
    required this.imageUrl,
    required this.healthStatus,
    required this.healthCardImageUrl,
    required this.description,
    required this.animalType,
    required this.location,
    required this.userId,
    required this.petId,
    required this.status, // Status alanını ekleyin
  });

  static fromSnapshot(QueryDocumentSnapshot<Object?> doc) {}
}

class LostAnimalAdd extends StatefulWidget {
  @override
  _LostAnimalAddState createState() => _LostAnimalAddState();
}

class _LostAnimalAddState extends State<LostAnimalAdd> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController breedController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController ageController = TextEditingController();
  final TextEditingController animalTypeController = TextEditingController();
  String? selectedLocation;
  bool isGenderMale = true;
  List<File> _images = [];
  final picker = ImagePicker();

  String selectedPetType = "Kedi";
  Future<void> _getImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    setState(() {
      if (pickedFile != null) {
        _images.add(File(pickedFile.path));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Resim seçilmedi')),
        );
      }
    });
  }

  void _removeImage(int index) {
    setState(() {
      _images.removeAt(index);
    });
  }

  Future<String?> _uploadFile(File file, String folder) async {
    final storageRef =
    FirebaseStorage.instance.ref().child('$folder/${Uuid().v4()}');
    try {
      await storageRef.putFile(file);
      return await storageRef.getDownloadURL();
    } catch (e) {
      print('Dosya yükleme hatası: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Dosya yükleme sırasında bir hata oluştu.')),
      );
      return null;
    }
  }

  Future<void> _submitForm() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Kullanıcı oturum açmamış.')),
      );
      return;
    }

    if (nameController.text.isEmpty ||
        breedController.text.isEmpty ||
        descriptionController.text.isEmpty ||
        _images.isEmpty ||
        selectedLocation == null ||
        ageController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content:
            Text('Lütfen tüm zorunlu alanları doldurun ve resim ekleyin.')),
      );
      return;
    }

    String userId = user.uid;
    String lostAnimalId = const Uuid().v4();

    List<String> imageUrls = [];
    for (var image in _images) {
      var imageUrl = await _uploadFile(image, 'lost_animal_images');
      if (imageUrl != null) imageUrls.add(imageUrl);
    }

    final newLostAnimal = LostAnimalData(
      name: nameController.text,
      breed: breedController.text,
      isGenderMale: isGenderMale,
      age: int.parse(ageController.text),
      imageUrls: imageUrls,
      description: descriptionController.text,
      location: selectedLocation!,
      userId: userId,
      lostAnimalId: lostAnimalId,
      animalType: animalTypeController.text.isNotEmpty
          ? animalTypeController.text
          : 'Belirtilmemiş',
    );

    final firestore = FirebaseFirestore.instance;
    await firestore.collection('lost_animals').doc(lostAnimalId).set({
      'name': newLostAnimal.name,
      'breed': newLostAnimal.breed,
      'isGenderMale': newLostAnimal.isGenderMale,
      'age': newLostAnimal.age,
      'imageUrls': newLostAnimal.imageUrls,
      'description': newLostAnimal.description,
      'location': newLostAnimal.location,
      'userId': newLostAnimal.userId,
      'lostAnimalId': newLostAnimal.lostAnimalId,
      'animalType': newLostAnimal.animalType,
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Kayıp hayvan ilanı başarıyla eklendi!')),
    );

    // Formu sıfırlama
    nameController.clear();
    breedController.clear();
    descriptionController.clear();
    ageController.clear();
    animalTypeController.clear();
    setState(() {
      _images.clear();
      selectedLocation = null;
      isGenderMale = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    List<String> cities = [
      'Adana',
      'Adıyaman',
      'Afyonkarahisar',
      'Ağrı',
      'Aksaray',
      'Amasya',
      'Ankara',
      'Antalya',
      'Artvin',
      'Aydın',
      'Balıkesir',
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
      'Kastamonu',
      'Kayseri',
      'Kırıkkale',
      'Kırklareli',
      'Kırşehir',
      'Kilis',
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
    ];

    return ListView(padding: const EdgeInsets.all(16.0), children: [
      TextField(
        controller: nameController,
        decoration: const InputDecoration(labelText: 'Hayvan Adı'),
      ),
      TextField(
        controller: breedController,
        decoration: const InputDecoration(labelText: 'Cinsi'),
      ),
      TextField(
        controller: ageController,
        keyboardType: TextInputType.number,
        decoration: const InputDecoration(labelText: 'Yaşı'),
      ),
      TextField(
        controller: descriptionController,
        decoration: const InputDecoration(labelText: 'Açıklama'),
      ),
      DropdownButtonFormField<String>(
        decoration: const InputDecoration(labelText: 'Hayvan Türü'),
        value: selectedPetType,
        items: <String>[
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
        onChanged: (newValue) {
          setState(() {
            selectedPetType = newValue!;
          });
        },
      ),
      DropdownButtonFormField<String>(
        value: selectedLocation,
        decoration: const InputDecoration(labelText: 'Konum'),
        items: cities.map((String city) {
          return DropdownMenuItem<String>(
            value: city,
            child: Text(city),
          );
        }).toList(),
        onChanged: (newValue) {
          setState(() {
            selectedLocation = newValue;
          });
        },
      ),
      Row(
        children: [
          const Text('Cinsiyet: '),
          Radio(
            value: true,
            groupValue: isGenderMale,
            onChanged: (bool? value) {
              setState(() {
                isGenderMale = value ?? true;
              });
            },
          ),
          const Text('Erkek'),
          Radio(
            value: false,
            groupValue: isGenderMale,
            onChanged: (bool? value) {
              setState(() {
                isGenderMale = value ?? false;
              });
            },
          ),
          const Text('Dişi'),
        ],
      ),
      GestureDetector(
        onTap: _getImage,
        child: Container(
          height: 200,
          color: Colors.grey[300],
          width: 180,
          child: _images.isEmpty
              ? const Center(child: Text("Resim Ekle"))
              : Wrap(
            spacing: 8.0,
            children: List.generate(_images.length, (index) {
              return Stack(
                children: [
                  Image.file(
                    _images[index],
                    width: 400,
                    height: 200,
                    fit: BoxFit.cover,
                  ),
                  Positioned(
                    right: 0,
                    child: IconButton(
                      icon: const Icon(Icons.remove_circle),
                      onPressed: () => _removeImage(index),
                    ),
                  ),
                ],
              );
            }),
          ),
        ),
      ),
      const SizedBox(height: 16.0),
      ElevatedButton(
        onPressed: _submitForm,
        child: const Text('İlanı Gönder'),
        style: ElevatedButton.styleFrom(
          foregroundColor: Colors.white,
          backgroundColor: Color.fromARGB(255, 147, 58, 142),
          padding: EdgeInsets.symmetric(vertical: 10, horizontal: 110),
          textStyle: TextStyle(fontSize: 18),
        ),
      )
    ]);
  }
}