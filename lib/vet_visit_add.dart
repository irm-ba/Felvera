import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';

class VetVisitAdd extends StatefulWidget {
  const VetVisitAdd({Key? key}) : super(key: key);

  @override
  _VetVisitAddState createState() => _VetVisitAddState();
}

class _VetVisitAddState extends State<VetVisitAdd> {
  final _descriptionController = TextEditingController();
  final _visitDateController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  DateTime? _selectedDate;
  String? _selectedAnimalId;
  List<String> _animalIds = [];
  File? _selectedImage;

  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _fetchAnimals();
  }

  Future<void> _fetchAnimals() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final snapshot = await FirebaseFirestore.instance
          .collection('animals')
          .where('userId', isEqualTo: user.uid)
          .get();
      final animals = snapshot.docs.map((doc) {
        final data = doc.data();
        return {
          'id': doc.id,
          'name': data['name'] ?? 'Unknown',
          'imageUrl': data['animalImageUrl'] ?? '',
        };
      }).toList();

      setState(() {
        _animalIds = animals.map((animal) => animal['id'] as String).toList();
      });
    }
  }

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  Future<String?> _uploadImage(File image) async {
    try {
      final storageRef = FirebaseStorage.instance.ref();
      final fileName = DateTime
          .now()
          .millisecondsSinceEpoch
          .toString();
      final imageRef = storageRef.child('vet_visit_images/$fileName');
      final uploadTask = imageRef.putFile(image);
      final snapshot = await uploadTask.whenComplete(() {});
      final downloadUrl = await snapshot.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      print('Error uploading image: $e');
      return null;
    }
  }

  Future<void> _saveVetVisit() async {
    if (_formKey.currentState?.validate() ?? false) {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        try {
          String? imageUrl;
          if (_selectedImage != null) {
            imageUrl = await _uploadImage(_selectedImage!);
          }

          await FirebaseFirestore.instance.collection('vet_visits').add({
            'description': _descriptionController.text,
            'visitDate': _selectedDate?.toIso8601String(), // Tarih formatı
            'animalId': _selectedAnimalId,
            'animalImageUrl': imageUrl,
            'userId': user.uid,
          });

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Veteriner ziyareti eklendi!')),
          );
          Navigator.pop(context);
        } catch (e) {
          print('Error adding vet visit: $e');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content:
                Text('Veteriner ziyareti eklenirken bir hata oluştu.')),
          );
        }
      }
    }
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    String? hint,
    required FormFieldValidator<String> validator,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        filled: true,
        fillColor: Colors.white,
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
      validator: validator,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Veteriner Ziyareti Ekle"),
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Veteriner ziyareti bilgilerini doldurun.',
                          style: Theme
                              .of(context)
                              .textTheme
                              .headlineSmall
                              ?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Color.fromARGB(255, 147, 58, 142),
                          ),
                        ),
                        SizedBox(height: 20),
                        GestureDetector(
                          onTap: _pickImage,
                          child: _selectedImage == null
                              ? Card(
                            elevation: 2,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Row(
                                children: [
                                  Icon(Icons.add_a_photo,
                                      color: Colors.grey[600]),
                                  SizedBox(width: 8),
                                  Text('Hayvan Resmi Ekle'),
                                ],
                              ),
                            ),
                          )
                              : Column(
                            children: [
                              Image.file(
                                _selectedImage!,
                                width: 100,
                                height: 100,
                                fit: BoxFit.cover,
                              ),
                              SizedBox(height: 8),
                              TextButton(
                                onPressed: _pickImage,
                                child: Text('Resmi Değiştir'),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 20),
                        _buildTextField(
                          controller: _descriptionController,
                          label: 'Açıklama',
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Açıklama girin';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: 20),
                        GestureDetector(
                          onTap: () async {
                            final DateTime? pickedDate = await showDatePicker(
                              context: context,
                              initialDate: _selectedDate ?? DateTime.now(),
                              firstDate: DateTime(2000),
                              lastDate: DateTime(2100),
                            );
                            if (pickedDate != null &&
                                pickedDate != _selectedDate) {
                              setState(() {
                                _selectedDate = pickedDate;
                                _visitDateController.text = _selectedDate
                                    ?.toLocal()
                                    .toString()
                                    .split(' ')[0] ??
                                    '';
                              });
                            }
                          },
                          child: AbsorbPointer(
                            child: _buildTextField(
                              controller: _visitDateController,
                              label: 'Ziyaret Tarihi',
                              hint: 'Tarih Seçin',
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Tarih seçin';
                                }
                                return null;
                              },
                            ),
                          ),
                        ),
                        SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 20),
                Center(
                  child: ElevatedButton(
                    onPressed: _saveVetVisit,
                    child: const Text('Kaydet'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color.fromARGB(255, 147, 58, 142),
                      foregroundColor: Colors.white,
                      padding:
                      EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      textStyle:
                      TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
