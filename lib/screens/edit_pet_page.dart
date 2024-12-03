import 'package:flutter/material.dart';
import 'package:felvera/models/pet_data.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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

  Future<void> _saveChanges() async {
    if (_formKey.currentState!.validate()) {
      try {
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
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Hayvan bilgileri başarıyla güncellendi!')),
        );

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AccountPage(),
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Güncelleme sırasında hata oluştu: $e')),
        );
      }
    }
  }

  Future<void> _deletePet() async {
    try {
      await FirebaseFirestore.instance
          .collection('pet')
          .doc(widget.pet.petId)
          .delete();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Hayvan başarıyla silindi!')),
      );

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => AccountPage(),
        ),
      );// Kullanıcıyı önceki ekrana yönlendir
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Silme sırasında hata oluştu: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Hayvanı Düzenle',
          style: TextStyle(color: Colors.purple[800]),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.purple[800]),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
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
              SizedBox(height: 24),
              ElevatedButton(
                onPressed: _saveChanges,
                child: Text('Değişiklikleri Kaydet'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.purple[800],
                  padding: EdgeInsets.symmetric(vertical: 16),
                  textStyle: TextStyle(fontSize: 18),
                ),
              ),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: _deletePet,
                child: Text('Hayvanı Sil'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  padding: EdgeInsets.symmetric(vertical: 16),
                  textStyle: TextStyle(fontSize: 18),
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
