import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:felvera/Adoptiondetails.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'models/pet_data.dart';

class AdoptionApplicationsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final userId = FirebaseAuth.instance.currentUser?.uid;

    if (userId == null) {
      return const Scaffold(
        body: Center(child: Text('Kullanıcı oturum açmamış.')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Başvuru Listesi',
          style: TextStyle(
            color: Color.fromARGB(255, 147, 58, 142),
          ),
        ),
        elevation: 0,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('adoption_applications')
            .where('petOwnerId', isEqualTo: userId)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Bir hata oluştu: ${snapshot.error}'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('Başvuru bulunamadı.'));
          }

          var applications = snapshot.data!.docs;

          return FutureBuilder<List<PetData?>>(
            future: _fetchPetsDetails(applications),
            builder: (context, petsSnapshot) {
              if (petsSnapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (petsSnapshot.hasError) {
                return Center(
                    child: Text('Bir hata oluştu: ${petsSnapshot.error}'));
              }

              if (!petsSnapshot.hasData || petsSnapshot.data!.isEmpty) {
                return const Center(child: Text('Hayvan bilgileri alınamadı.'));
              }

              var petsDetails = petsSnapshot.data!;

              return ListView.builder(
                itemCount: applications.length,
                itemBuilder: (context, index) {
                  if (index >= petsDetails.length) {
                    return const Center(child: Text('Hayvan bilgileri eksik.'));
                  }

                  var application = applications[index];
                  var petDetails = petsDetails[index];

                  // Null kontrolü ve alan kontrolü
                  String imageUrl = petDetails?.imageUrl ?? '';
                  String petName = petDetails?.name ?? 'Bilinmiyor';

                  return Card(
                    margin: const EdgeInsets.symmetric(
                        horizontal: 16.0, vertical: 8.0),
                    elevation: 5.0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16.0),
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(16.0),
                      leading: ClipRRect(
                        borderRadius: BorderRadius.circular(8.0),
                        child: imageUrl.isNotEmpty
                            ? Image.network(
                                imageUrl,
                                width: 60,
                                height: 60,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return const Icon(Icons.error,
                                      color: Colors.red);
                                },
                              )
                            : const Icon(Icons.pets,
                                color: Color.fromARGB(255, 147, 58, 142),
                                size: 60.0),
                      ),
                      title: Text(
                        petName,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18.0,
                        ),
                      ),
                      subtitle: Text(
                        'Başvuru Sahibi: ${application['name'] ?? 'Bilinmiyor'}\n' +
                            (application['adoptionReason'] ??
                                'Neden belirtilmemiş'),
                        style: const TextStyle(
                          fontSize: 14.0,
                          color: Colors.black54,
                        ),
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ApplicationDetailPage(
                              applicationId: application.id,
                            ),
                          ),
                        );
                      },
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }

  Future<List<PetData?>> _fetchPetsDetails(
      List<QueryDocumentSnapshot> applications) async {
    final List<PetData?> petsDetailsList = [];

    for (var application in applications) {
      String petId = application['petId'] ?? '';
      if (petId.isNotEmpty) {
        try {
          PetData? petData = await getPetData(petId);
          petsDetailsList.add(petData);
        } catch (e) {
          print('Error fetching pet data for petId $petId: $e');
          petsDetailsList.add(null);
        }
      }
    }

    return petsDetailsList;
  }
}

Future<PetData?> getPetData(String petId) async {
  try {
    DocumentSnapshot petDoc =
        await FirebaseFirestore.instance.collection('pet').doc(petId).get();

    if (petDoc.exists) {
      return PetData.fromSnapshot(petDoc);
    } else {
      print('Pet not found');
      return null;
    }
  } catch (e) {
    print('Error fetching pet data: $e');
    return null;
  }
}
