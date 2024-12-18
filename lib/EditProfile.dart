import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  _EditProfilePageState createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();

  User? _currentUser;
  Map<String, dynamic>? _userData;

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    _currentUser = FirebaseAuth.instance.currentUser;
    if (_currentUser != null) {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(_currentUser!.uid)
          .get();

      setState(() {
        _userData = userDoc.data() as Map<String, dynamic>?;
        if (_userData != null) {
          _firstNameController.text = _userData!['firstName'] ?? '';
          _lastNameController.text = _userData!['lastName'] ?? '';

          // Telefon numarasını almayı kaldırdık
        }
      });
    }
  }

  Future<void> _saveProfile() async {
    if (_formKey.currentState!.validate()) {
      try {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(_currentUser!.uid)
            .update({
          'firstName': _firstNameController.text,
          'lastName': _lastNameController.text,

          // Telefon numarasını güncellemelerden çıkardık
        });
        Navigator.pop(context); // Profili kaydettikten sonra geri dön
      } catch (e) {
        print('Error updating user data: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil Düzenle'),
      ),
      body: _userData == null
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextFormField(
                      controller: _firstNameController,
                      decoration: const InputDecoration(labelText: 'Ad'),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Bu alan boş bırakılamaz';
                        }
                        return null;
                      },
                    ),
                    TextFormField(
                      controller: _lastNameController,
                      decoration: const InputDecoration(labelText: 'Soyad'),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Bu alan boş bırakılamaz';
                        }
                        return null;
                      },
                    ),
                    // Telefon numarasını kaldırdık
                    // TextFormField(
                    //   controller: _phoneNumberController,
                    //   decoration:
                    //       InputDecoration(labelText: 'Telefon Numarası'),
                    //   validator: (value) {
                    //     if (value == null || value.isEmpty) {
                    //       return 'Bu alan boş bırakılamaz';
                    //     }
                    //     return null;
                    //   },
                    // ),

                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: _saveProfile,
                      child: const Text('Değişiklikleri Kaydet'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            const Color.fromARGB(255, 147, 58, 142),
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();

    super.dispose();
  }
}
