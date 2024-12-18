import 'package:felvera/chatPage.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AdminApplication extends StatefulWidget {
  final String applicationId;

  const AdminApplication({required this.applicationId, Key? key})
      : super(key: key);

  @override
  State<AdminApplication> createState() => _AdminApplicationState();
}

class _AdminApplicationState extends State<AdminApplication> {
  Map<String, dynamic>? _applicationData;
  Map<String, dynamic>? _userData;
  Map<String, dynamic>? _petData;
  bool _isLoading = true;
  String? _errorMessage;

  // State variables for selecting which details to show
  bool _showName = true;
  bool _showEmail = true;
  bool _showPetName = true;
  bool _showAnimalType = true;
  bool _showBreed = true;
  bool _showAdoptionReason = true;
  bool _showLivingConditions = true;

  @override
  void initState() {
    super.initState();
    _fetchApplicationDetails();
  }

  Future<void> _fetchApplicationDetails() async {
    try {
      DocumentSnapshot applicationDoc = await FirebaseFirestore.instance
          .collection('adoption_applications')
          .doc(widget.applicationId)
          .get();

      if (applicationDoc.exists) {
        setState(() {
          _applicationData = applicationDoc.data() as Map<String, dynamic>?;
          _isLoading = false;
        });

        if (_applicationData != null) {
          String userId = _applicationData!['userId'];
          String petId = _applicationData!['petId'];

          DocumentSnapshot userDoc = await FirebaseFirestore.instance
              .collection('users')
              .doc(userId)
              .get();

          DocumentSnapshot petDoc = await FirebaseFirestore.instance
              .collection('pet')
              .doc(petId)
              .get();

          setState(() {
            _userData = userDoc.data() as Map<String, dynamic>?;
            _petData = petDoc.data() as Map<String, dynamic>?;
          });
        }
      } else {
        setState(() {
          _errorMessage = 'Başvuru bulunamadı.';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Başvuru detayları alınırken bir hata oluştu: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _updateApplicationStatus(String status) async {
    try {
      // Başvuru durumunu güncelle
      await FirebaseFirestore.instance
          .collection('adoption_applications')
          .doc(widget.applicationId)
          .update({'status': status});

      // Pet'in durumunu güncelle
      String petId = _applicationData?['petId'] ?? '';
      if (status == 'Onaylandı') {
        await FirebaseFirestore.instance
            .collection('pet')
            .doc(petId)
            .update({'status': 'Adoptions'});
      } else if (status == 'Reddedildi') {
        await FirebaseFirestore.instance
            .collection('pet')
            .doc(petId)
            .update({'status': 'Available'}); // veya uygun bir değer
      }

      setState(() {
        _applicationData?['status'] = status;
      });
    } catch (e) {
      // Hata işleme kodunu burada ekleyebilirsiniz.
      print('Hata: $e');
    }
  }

  String getCurrentUserId() {
    return FirebaseAuth.instance.currentUser?.uid ?? '';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Başvuru Detayları',
          style: TextStyle(
            fontSize: 16.0,
            fontWeight: FontWeight.bold,
            color: Color.fromARGB(255, 147, 58, 142),
          ),
        ),
        elevation: 4.0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? Center(child: Text(_errorMessage!))
              : Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: ListView(
                          children: [
                            _buildApplicationDetails(),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildActionButtons(),
                    ],
                  ),
                ),
    );
  }

  Widget _buildApplicationDetails() {
    String status = _applicationData?['status'] ?? 'Bekleniyor';
    Color statusColor = status == 'Onaylandı'
        ? Colors.green
        : status == 'Reddedildi'
            ? Colors.red
            : Colors.orange;

    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Başvuru Durumu',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color.fromARGB(255, 147, 58, 142),
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Chip(
                  label: Text(
                    status,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  backgroundColor: statusColor,
                ),
              ],
            ),
            Divider(color: Colors.grey[400], height: 30),
            const Text(
              'Başvuran Detayları',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color.fromARGB(255, 147, 58, 142),
              ),
            ),
            const SizedBox(height: 10),
            if (_showName)
              _buildDetailRow('İsim',
                  '${_userData?['firstName']} ${_userData?['lastName']}'),
            if (_showEmail)
              _buildDetailRow(
                  'E-posta', _userData?['email'] ?? 'Bilgi mevcut değil'),
            Divider(color: Colors.grey[400], height: 30),
            const Text(
              'Hayvan Detayları',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color.fromARGB(255, 147, 58, 142),
              ),
            ),
            const SizedBox(height: 10),
            if (_showPetName)
              _buildDetailRow(
                  'Hayvan', _petData?['name'] ?? 'Bilgi mevcut değil'),
            if (_showAnimalType)
              _buildDetailRow(
                  'Tür', _petData?['animalType'] ?? 'Bilgi mevcut değil'),
            if (_showBreed)
              _buildDetailRow(
                  'Irk', _petData?['breed'] ?? 'Bilgi mevcut değil'),
            Divider(color: Colors.grey[400], height: 30),
            const Text(
              'Başvuru Detayları',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color.fromARGB(255, 147, 58, 142),
              ),
            ),
            const SizedBox(height: 10),
            if (_showAdoptionReason)
              _buildDetailRow('Başvuru Nedeni',
                  _applicationData?['adoptionReason'] ?? 'Bilgi mevcut değil'),
            if (_showLivingConditions)
              _buildDetailRow(
                  'Yaşam Koşulları',
                  _applicationData?['livingConditions'] ??
                      'Bilgi mevcut değil'),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color.fromARGB(255, 147, 58, 142),
            ),
          ),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    String status = _applicationData?['status'] ?? 'Bekleniyor';

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            ElevatedButton.icon(
              onPressed: () => _updateApplicationStatus('Onaylandı'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              ),
              icon: const Icon(Icons.check),
              label: const Text('Onayla'),
            ),
            ElevatedButton.icon(
              onPressed: () => _updateApplicationStatus('Reddedildi'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              ),
              icon: const Icon(Icons.close),
              label: const Text('Reddet'),
            ),
          ],
        ),
        const SizedBox(height: 16),
        if (status == 'Onaylandı')
          ElevatedButton.icon(
            onPressed: () async {
              final currentUserId =
                  getCurrentUserId(); // Onaylayan kişinin ID'si
              final receiverId =
                  _applicationData?['userId']; // Onaylanan kişinin ID'si

              // Eğer chat için bir konuşma ID'si gerekiyorsa, bunu burada oluşturabilirsiniz
              final conversationId = '${receiverId}_$currentUserId';

              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ChatPage(
                    conversationId: conversationId,
                    receiverId: receiverId!,
                    receiverName:
                        '${_userData?['firstName']} ${_userData?['lastName']}',
                    senderName: '',
                  ),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color.fromARGB(255, 147, 58, 142),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            ),
            icon: const Icon(Icons.message),
            label: const Text('Mesajlaş'),
          ),
      ],
    );
  }
}
