import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:felvera/lost_details.dart';
import 'package:felvera/models/lost_animal_data.dart';

class LostAnimalsPage extends StatefulWidget {
  @override
  _LostAnimalsPageState createState() => _LostAnimalsPageState();
}

class _LostAnimalsPageState extends State<LostAnimalsPage> {
  String selectedAnimalType = '';
  String location = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kayıp Hayvanlar'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterDialog,
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _getFilteredLostAnimalsStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('Henüz kayıp ilanı yok.'));
          }

          // Kart sayısını platforma göre ayarla
          int crossAxisCount = kIsWeb
              ? 4 // Web için 4 kart
              : MediaQuery.of(context).size.width > 600
              ? 4 // Tablet ve geniş ekranlı cihazlar için 4 kart
              : 2; // Mobil cihazlar için 2 kart

          return GridView.builder(
            padding: const EdgeInsets.all(10),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount,
              mainAxisSpacing: 10.0,
              crossAxisSpacing: 10.0,
              childAspectRatio: 0.75, // Kartların en-boy oranı
            ),
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              final doc = snapshot.data!.docs[index];

              final lostAnimal = LostAnimalData(
                name: doc['name'],
                breed: doc['breed'],
                isGenderMale: doc['isGenderMale'],
                age: doc['age'],
                imageUrls: List<String>.from(doc['imageUrls']),
                description: doc['description'],
                location: doc['location'],
                userId: doc['userId'],
                lostAnimalId: doc['lostAnimalId'],
                animalType: doc['animalType'],
              );

              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          LostAnimalDetailsScreen(lostAnimal: lostAnimal),
                    ),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.all(12),
                  margin: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(255, 147, 97, 150),
                    gradient: const LinearGradient(
                      colors: [
                        Colors.black12,
                        Colors.black54,
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomCenter,
                    ),
                    borderRadius: BorderRadius.circular(14),
                    image: DecorationImage(
                      image: NetworkImage(
                        lostAnimal.imageUrls.isNotEmpty
                            ? lostAnimal.imageUrls[0]
                            : 'https://example.com/default_image.png',
                      ),
                      fit: BoxFit.cover,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        lostAnimal.name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        lostAnimal.description,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      const Row(
                        children: [
                          Icon(
                            Icons.access_time_outlined,
                            size: 16,
                            color: Colors.white,
                          ),
                          SizedBox(width: 4),
                          Text(
                            'Kayıp',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Stream<QuerySnapshot> _getFilteredLostAnimalsStream() {
    CollectionReference lostAnimalsRef =
    FirebaseFirestore.instance.collection('lost_animals');

    Query query = lostAnimalsRef;

    if (selectedAnimalType.isNotEmpty) {
      query = query.where('animalType', isEqualTo: selectedAnimalType);
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
          title: const Text('Filtrele'),
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
                    hint: const Text('Hayvan Türü'),
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
                  // Konum seçimi
                  DropdownButton<String>(
                    value: location.isNotEmpty ? location : null,
                    hint: const Text('Konum'),
                    onChanged: (String? newValue) {
                      setState(() {
                        location = newValue ?? '';
                      });
                    },
                    items: [
                      'Adana',
                      'Ankara',
                      'İstanbul',
                      'İzmir',
                      'Bursa',
                      'Antalya',
                      'Gaziantep',
                      // Diğer şehirler eklenebilir
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
              child: const Text('İptal'),
              onPressed: () {
                Navigator.of(context).pop();
                setState(() {
                  selectedAnimalType = '';
                  location = '';
                });
              },
            ),
            TextButton(
              child: const Text('Uygula'),
              onPressed: () {
                Navigator.of(context).pop();
                setState(() {});
              },
            ),
          ],
        );
      },
    );
  }
}
