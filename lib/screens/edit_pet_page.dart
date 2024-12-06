import 'dart:io';
import 'package:flutter/material.dart';
import 'package:felvera/models/pet_data.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';

import '../account.dart';

class EditPetPage extends StatefulWidget {
  final PetData pet;

  const EditPetPage({Key? key, required this.pet}) : super(key: key);

  @override
  _EditPetPageState createState() => _EditPetPageState();
}

class _EditPetPageState extends State<EditPetPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _ageController;
  late TextEditingController _healthStatusController;
  late TextEditingController _animalTypeController;
  late TextEditingController _locationController;
  late TextEditingController _descriptionController;

  File? _selectedImage;
  String? _uploadedImageUrl;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.pet.name);
    _ageController = TextEditingController(text: widget.pet.age.toString());
    _healthStatusController =
        TextEditingController(text: widget.pet.healthStatus);
    _animalTypeController = TextEditingController(text: widget.pet.animalType);
    _locationController = TextEditingController(text: widget.pet.location);
    _descriptionController =
        TextEditingController(text: widget.pet.description);
    _uploadedImageUrl = widget.pet.imageUrl; // Mevcut resim URL'sini al
  }

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    _healthStatusController.dispose();
    _animalTypeController.dispose();
    _locationController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  Future<void> _uploadImage() async {
    if (_selectedImage != null) {
      final storageRef = FirebaseStorage.instance
          .ref()
          .child('pet_images/${widget.pet.petId}');
      final uploadTask = storageRef.putFile(_selectedImage!);

      final snapshot = await uploadTask.whenComplete(() {});
      final imageUrl = await snapshot.ref.getDownloadURL();

      setState(() {
        _uploadedImageUrl = imageUrl;
      });
    }
  }

  Future<void> _saveChanges() async {
    if (_formKey.currentState!.validate()) {
      try {
        if (_selectedImage != null) {
          await _uploadImage();
        }

        await FirebaseFirestore.instance
            .collection('pet')
            .doc(widget.pet.petId)
            .update({
          'name': _nameController.text.trim(),
          'age': int.parse(_ageController.text.trim()),
          'healthStatus': _healthStatusController.text.trim(),
          'animalType': _animalTypeController.text.trim(),
          'location': _locationController.text.trim(),
          'description': _descriptionController.text.trim(),
          'imageUrl': _uploadedImageUrl,
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Hayvan bilgileri başarıyla güncellendi!')),
        );

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const AccountPage(),
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Güncelleme sırasında hata oluştu: $e')),
        );
      }
    }
  }

  void _deletePet() async {
    try {
      // Firestore'dan hayvan kaydını sil
      await FirebaseFirestore.instance
          .collection('pet')
          .doc(widget.pet.petId)
          .delete();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Hayvan başarıyla silindi!')),
      );

      Navigator.pop(context); // Silme işleminden sonra geri dön
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Hayvan silinirken bir hata oluştu: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Hayvanı Düzenle',
          style: TextStyle(color: Color.fromARGB(255, 147, 58, 142)),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme:
            const IconThemeData(color: Color.fromARGB(255, 147, 58, 142)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  height: 150,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: _selectedImage != null
                      ? Image.file(
                          _selectedImage!,
                          fit: BoxFit.cover,
                        )
                      : _uploadedImageUrl != null
                          ? Image.network(
                              _uploadedImageUrl!,
                              fit: BoxFit.cover,
                            )
                          : const Icon(
                              Icons.add_a_photo,
                              color: Colors.grey,
                              size: 50,
                            ),
                ),
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _nameController,
                label: 'Adı',
                validator: (value) =>
                    value!.isEmpty ? 'Hayvan adı boş bırakılamaz.' : null,
              ),
              _buildTextField(
                controller: _ageController,
                label: 'Yaşı',
                keyboardType: TextInputType.number,
                validator: (value) =>
                    value!.isEmpty ? 'Yaş boş bırakılamaz.' : null,
              ),
              _buildTextField(
                controller: _healthStatusController,
                label: 'Sağlık Durumu',
              ),
              _buildTextField(
                controller: _animalTypeController,
                label: 'Hayvan Türü',
              ),
              _buildTextField(
                controller: _locationController,
                label: 'Lokasyon',
              ),
              _buildTextField(
                controller: _descriptionController,
                label: 'Açıklama',
                maxLines: 3,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _saveChanges,
                child: const Text('Değişiklikleri Kaydet'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 147, 58, 142),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  foregroundColor: Colors.white,
                  textStyle: const TextStyle(fontSize: 18),
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _deletePet,
                child: const Text('Hayvanı Sil'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  foregroundColor: Colors.white,
                  textStyle: const TextStyle(fontSize: 18),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        validator: validator,
      ),
    );
  }
}
