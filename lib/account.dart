import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:felvera/login.dart';
import 'package:felvera/models/pet_data.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'EditProfile.dart';
import 'Change_Password_Page.dart';
import 'dart:io';
import 'adminaplication.dart'; // Import the AdminApplication page
import 'size_config.dart';

class AccountPage extends StatefulWidget {
  const AccountPage({super.key});

  @override
  State<AccountPage> createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage>
    with SingleTickerProviderStateMixin {
  File? _profileImage;
  Map<String, dynamic>? _userData;
  List<PetData> _userPets = [];
  List<DocumentSnapshot> _userApplications = [];
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _initializeData();
  }

  Future<void> _initializeData() async {
    final currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser == null) {
      // Kullanıcı oturum açmamışsa
      // Uyarı göster
      return;
    }

    try {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser.uid)
          .get();

      setState(() {
        _userData = userDoc.data() as Map<String, dynamic>?;
      });

      QuerySnapshot petsSnapshot = await FirebaseFirestore.instance
          .collection('pet')
          .where('userId', isEqualTo: currentUser.uid)
          .get();

      setState(() {
        _userPets =
            petsSnapshot.docs.map((doc) => PetData.fromSnapshot(doc)).toList();
      });

      List<String> petIds = _userPets.map((pet) => pet.petId).toList();
      if (petIds.isNotEmpty) {
        QuerySnapshot applicationsSnapshot = await FirebaseFirestore.instance
            .collection('adoption_applications')
            .where('petId', whereIn: petIds)
            .get();

        setState(() {
          _userApplications = applicationsSnapshot.docs;
        });
      } else {
        setState(() {
          _userApplications = [];
        });
      }
    } catch (e) {
      print('Error initializing data: $e');
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _profileImage = File(pickedFile.path);
      });
      await _uploadImageToFirebaseAndSaveUrl();
    }
  }

  Future<void> _uploadImageToFirebaseAndSaveUrl() async {
    if (_profileImage == null) return;

    final storageRef = FirebaseStorage.instance
        .ref()
        .child('profile_images/${FirebaseAuth.instance.currentUser!.uid}.jpg');

    await storageRef.putFile(_profileImage!);

    final imageUrl = await storageRef.getDownloadURL();

    await FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .update({'profileImageUrl': imageUrl});
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context); // SizeConfig'i başlatıyoruz
    final currentUser = FirebaseAuth.instance.currentUser;

    // Kullanıcı giriş yapmamışsa otomatik olarak giriş sayfasına yönlendir
    if (currentUser == null) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Oturum Açılmamış. Lütfen Giriş Yapın.',
                style: TextStyle(fontSize: SizeConfig.blockSizeHorizontal * 5),
              ),
              SizedBox(height: SizeConfig.blockSizeVertical * 2),
              ElevatedButton(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => LoginPage()),
                  );
                },
                child: Text(
                  'Giriş Yap',
                  style:
                      TextStyle(fontSize: SizeConfig.blockSizeHorizontal * 4),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color.fromARGB(
                      255, 147, 58, 142), // Buton arka plan rengi
                  foregroundColor: Colors.white, // Buton metin rengi
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Profil',
          style: TextStyle(fontSize: SizeConfig.blockSizeHorizontal * 5),
        ),
      ),
      body: _userData == null
          ? Center(child: CircularProgressIndicator())
          : Column(
              children: [
                _buildHeader(),
                _buildTabBar(),
                Expanded(child: _buildTabBarView()),
                _buildActionButtons(),
              ],
            ),
    );
  }

  Widget _buildHeader() {
    return Stack(
      children: [
        Positioned.fill(
          child: Image.asset(
            'assets/proarka.jpg',
            fit: BoxFit.cover,
          ),
        ),
        Container(
          padding: EdgeInsets.symmetric(
            vertical: SizeConfig.blockSizeVertical * 5,
          ),
          color: Colors.white.withOpacity(0.5),
          child: Column(
            children: [
              Align(
                alignment: Alignment.topCenter,
                child: GestureDetector(
                  onTap: _pickImage,
                  child: CircleAvatar(
                    radius: SizeConfig.blockSizeHorizontal * 12,
                    backgroundImage: _profileImage != null
                        ? FileImage(_profileImage!)
                        : NetworkImage(_userData?['profileImageUrl'] ??
                            'https://via.placeholder.com/150') as ImageProvider,
                  ),
                ),
              ),
              SizedBox(height: SizeConfig.blockSizeVertical * 1),
              Text(
                _userData?['firstName'] ?? 'Kullanıcı Adı',
                style: TextStyle(
                  fontSize: SizeConfig.blockSizeHorizontal * 6,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTabBar() {
    return TabBar(
      controller: _tabController,
      tabs: [
        Tab(text: 'Hayvanlarım'),
        Tab(text: 'Başvuranlar'),
      ],
      indicatorColor: Color.fromARGB(255, 147, 58, 142),
      labelColor: Color.fromARGB(255, 147, 58, 142),
    );
  }

  Widget _buildTabBarView() {
    return TabBarView(
      controller: _tabController,
      children: [
        _buildPetsList(),
        _buildApplicationsList(),
      ],
    );
  }

  Widget _buildPetsList() {
    return _userPets.isNotEmpty
        ? GridView.builder(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: SizeConfig.blockSizeHorizontal * 2,
              mainAxisSpacing: SizeConfig.blockSizeVertical * 2,
              childAspectRatio: 0.75,
            ),
            padding: EdgeInsets.all(SizeConfig.blockSizeHorizontal * 4),
            itemCount: _userPets.length,
            itemBuilder: (context, index) {
              var pet = _userPets[index];
              return Card(
                elevation: 5,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    ClipRRect(
                      borderRadius:
                          BorderRadius.vertical(top: Radius.circular(15)),
                      child: Image.network(
                        pet.imageUrl,
                        height: SizeConfig.screenWidth / 2 - 32,
                        width: SizeConfig.screenWidth / 2 - 32,
                        fit: BoxFit.cover,
                      ),
                    ),
                    Padding(
                      padding:
                          EdgeInsets.all(SizeConfig.blockSizeHorizontal * 2),
                      child: Text(
                        pet.name ?? 'Hayvan Adı',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: SizeConfig.blockSizeHorizontal * 4,
                          color: Colors.black,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              );
            },
          )
        : Center(
            child: Text(
              'Hayvanınız bulunmuyor',
              style: TextStyle(
                fontSize: SizeConfig.blockSizeHorizontal * 4,
              ),
            ),
          );
  }

  Widget _buildApplicationsList() {
    return _userApplications.isNotEmpty
        ? GridView.builder(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: SizeConfig.blockSizeHorizontal * 2,
              mainAxisSpacing: SizeConfig.blockSizeVertical * 2,
              childAspectRatio: 0.75,
            ),
            padding: EdgeInsets.all(SizeConfig.blockSizeHorizontal * 4),
            itemCount: _userApplications.length,
            itemBuilder: (context, index) {
              var application = _userApplications[index];
              String userId = application['userId'];
              String petId = application['petId'];

              return FutureBuilder<List<DocumentSnapshot>>(
                future: Future.wait([
                  FirebaseFirestore.instance
                      .collection('users')
                      .doc(userId)
                      .get(),
                  FirebaseFirestore.instance.collection('pet').doc(petId).get(),
                ]),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError ||
                      !snapshot.hasData ||
                      snapshot.data!.length != 2) {
                    return Center(child: Text('Veri yüklenemedi.'));
                  }

                  DocumentSnapshot userDoc = snapshot.data![0];
                  DocumentSnapshot petDoc = snapshot.data![1];

                  final userData = userDoc.data() as Map<String, dynamic>?;
                  final petData = petDoc.data() as Map<String, dynamic>?;

                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AdminApplication(
                            applicationId: application.id,
                          ),
                        ),
                      );
                    },
                    child: Card(
                      elevation: 5,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          ClipRRect(
                            borderRadius:
                                BorderRadius.vertical(top: Radius.circular(15)),
                            child: Image.network(
                              petData?['imageUrl'] ??
                                  'https://via.placeholder.com/150',
                              height:
                                  MediaQuery.of(context).size.width / 2 - 32,
                              width: MediaQuery.of(context).size.width / 2 - 32,
                              fit: BoxFit.cover,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              petData?['name'] ?? 'Hayvan Adı',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16.0,
                                color: Colors.black,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 8.0),
                            child: Text(
                              userData?['firstName'] ?? 'Başvuran Adı',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 14.0,
                                color: Colors.grey[600],
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          )
        : Center(child: Text('Başvurunuz bulunmuyor'));
  }

  Widget _buildActionButtons() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => EditProfilePage()),
              );
            },
            child: Text('Profil Düzenle'),
            style: ElevatedButton.styleFrom(
              foregroundColor: Color.fromARGB(255, 255, 255, 255),
              backgroundColor: Color.fromARGB(255, 147, 58, 142),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ChangePasswordPage()),
              );
            },
            child: Text('Şifre Değiştir'),
            style: ElevatedButton.styleFrom(
              foregroundColor: Color.fromARGB(255, 255, 255, 255),
              backgroundColor: Color.fromARGB(255, 147, 58, 142),
            ),
          ),
        ],
      ),
    );
  }
}
