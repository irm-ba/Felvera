import 'dart:io';
import 'package:felvera/services/image_utils.dart';
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
  final TextEditingController nameController = TextEditingController();
  final TextEditingController breedController = TextEditingController();
  final TextEditingController ageController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController healthStatusController = TextEditingController();

  String? selectedLocation;
  bool isGenderMale = true;
  Uint8List? _healthCardImage;
  final List<Uint8List> _images = [];
  String selectedPetType = "Kedi";

  Future<void> _pickImage() async {
    final Uint8List? image = await ImageUtils.pickImage();
    if (image != null) {
      setState(() {
        _images.add(image);
      });
    }
  }

  Future<void> _pickHealthCardImage() async {
    final Uint8List? image = await ImageUtils.pickImage();
    if (image != null) {
      setState(() {
        _healthCardImage = image;
      });
    }
  }

  void _removeImage(int index) {
    setState(() {
      _images.removeAt(index);
    });
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
        descriptionController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content:
              Text('Lütfen tüm zorunlu alanları doldurun ve resim ekleyin.'),
        ),
      );
      return;
    }

    String userId = user.uid;
    String petId = const Uuid().v4();

    // Resimleri Firebase Storage'a yükle
    List<String> imageUrls = [];
    for (var image in _images) {
      String? imageUrl = await ImageUtils.uploadImage(image, 'pet_images');
      if (imageUrl != null) {
        imageUrls.add(imageUrl);
      }
    }

    String? healthCardUrl = _healthCardImage != null
        ? await ImageUtils.uploadImage(_healthCardImage!, 'health_card_images')
        : null;

    final newPet = {
      'name': nameController.text,
      'breed': breedController.text,
      'isGenderMale': isGenderMale,
      'age': int.parse(ageController.text),
      'imageUrl': imageUrls.isNotEmpty ? imageUrls[0] : '',
      'healthStatus': healthStatusController.text,
      'healthCardImageUrl': healthCardUrl ?? '',
      'description': descriptionController.text,
      'animalType': selectedPetType,
      'location': selectedLocation!,
      'userId': userId,
      'petId': petId,
      'status': 'Available',
    };

    final firestore = FirebaseFirestore.instance;
    await firestore.collection('pet').doc(petId).set(newPet);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Hayvan başarıyla eklendi!'),
      ),
    );

    // Formu sıfırla
    nameController.clear();
    breedController.clear();
    ageController.clear();
    descriptionController.clear();
    healthStatusController.clear();
    setState(() {
      _images.clear();
      _healthCardImage = null;
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
              LengthLimitingTextInputFormatter(2),
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
                onTap: _pickImage,
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
                                Image.memory(
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
              const SizedBox(width: 8),
              GestureDetector(
                onTap: _pickHealthCardImage,
                child: Container(
                  height: 200,
                  color: Colors.grey[300],
                  width: 180,
                  child: _healthCardImage == null
                      ? const Center(child: Text("Sağlık Kartı Ekle"))
                      : Image.memory(
                          _healthCardImage!,
                          width: 180,
                          height: 200,
                          fit: BoxFit.cover,
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
              backgroundColor: const Color.fromARGB(255, 147, 58, 142),
              padding:
                  const EdgeInsets.symmetric(vertical: 10, horizontal: 110),
              textStyle: const TextStyle(fontSize: 18),
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
  String? selectedLocation;
  bool isGenderMale = true;
  List<Uint8List> _images = [];
  final picker = ImageUtils();

  String selectedPetType = "Kedi";

  Future<void> _getImage() async {
    final image = await ImageUtils
        .pickImage(); // Accessing static method directly through class
    if (image != null) {
      setState(() {
        _images.add(image);
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Resim seçilmedi')),
      );
    }
  }

  void _removeImage(int index) {
    setState(() {
      _images.removeAt(index);
    });
  }

  Future<String?> _uploadFile(Uint8List file, String folder) async {
    final storageRef =
        FirebaseStorage.instance.ref().child('$folder/${Uuid().v4()}');
    try {
      final uploadTask = storageRef.putData(file);
      await uploadTask;
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

    final newLostAnimal = {
      'name': nameController.text,
      'breed': breedController.text,
      'isGenderMale': isGenderMale,
      'age': int.parse(ageController.text),
      'imageUrls': imageUrls,
      'description': descriptionController.text,
      'location': selectedLocation!,
      'userId': userId,
      'lostAnimalId': lostAnimalId,
      'animalType': selectedPetType,
    };

    final firestore = FirebaseFirestore.instance;
    await firestore
        .collection('lost_animals')
        .doc(lostAnimalId)
        .set(newLostAnimal);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Kayıp hayvan ilanı başarıyla eklendi!')),
    );

    // Formu sıfırlama
    nameController.clear();
    breedController.clear();
    descriptionController.clear();
    ageController.clear();
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
                        Image.memory(
                          _images[index],
                          width: 100,
                          height: 100,
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
