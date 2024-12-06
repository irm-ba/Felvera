import 'package:felvera/models/pet_data.dart';
import 'package:flutter/material.dart';

class PetDetailsScreen extends StatelessWidget {
  final PetData pet;

  const PetDetailsScreen({Key? key, required this.pet}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(pet.name),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.network(pet.imageUrl),
            const SizedBox(height: 16),
            Text(
              pet.name,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              pet.breed,
              style: TextStyle(fontSize: 18, color: Colors.grey[700]),
            ),
            const SizedBox(height: 8),
            Text(
              pet.isGenderMale ? 'Erkek' : 'Dişi',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 8),
            Text(
              '${pet.age} yaşında',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            const Text(
              'Sağlık Durumu:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(pet.healthStatus),
            const SizedBox(height: 16),
            if (pet.healthCardImageUrl.isNotEmpty) ...[
              const Text(
                'Sağlık Kartı:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Image.network(pet.healthCardImageUrl),
              const SizedBox(height: 16),
            ],
            const Text(
              'Hayvan Türü:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(pet.animalType),
            const SizedBox(height: 16),
            const Text(
              'Lokasyon:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(pet.location),
            const SizedBox(height: 16),
            const Text(
              'Açıklama:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(pet.description),
          ],
        ),
      ),
    );
  }
}
