import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AnswersPage extends StatefulWidget {
  final String questionId;
  final Map<String, dynamic> questionData;

  const AnswersPage({required this.questionId, required this.questionData});

  @override
  _AnswersPageState createState() => _AnswersPageState();
}

class _AnswersPageState extends State<AnswersPage> {
  final TextEditingController _answerController = TextEditingController();
  bool _isSubmitting = false;

  @override
  Widget build(BuildContext context) {
    User? user = FirebaseAuth.instance.currentUser;
    String userName = user?.displayName ?? 'Anonim';
    String userPhotoUrl = user?.photoURL ?? ''; // Profil resmi URL'si

    return Scaffold(
      appBar: AppBar(
        title: const Text('Yanıtlar'),
      ),
      body: Column(
        children: [
          _buildQuestionCard(),
          Expanded(
            child: _buildAnswersList(),
          ),
          _buildAnswerInputSection(),
        ],
      ),
    );
  }

  Widget _buildQuestionCard() {
    return Container(
      padding: const EdgeInsets.all(20.0),
      margin: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.0),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 8.0,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.questionData['question'] ?? 'Soru bulunamadı',
            style: const TextStyle(
              fontSize: 20.0,
              fontWeight: FontWeight.bold,
              color: Color.fromARGB(255, 147, 58, 142), // Main theme color
            ),
          ),
          const SizedBox(height: 10.0),
          Text(
            "Soran: ${widget.questionData['userName'] ?? 'Anonim'}",
            style: TextStyle(color: Colors.grey[600]),
          ),
          const SizedBox(height: 10.0),
          if (widget.questionData['imageUrls'] != null &&
              widget.questionData['imageUrls'] is List &&
              (widget.questionData['imageUrls'] as List).isNotEmpty)
            Container(
              height: 200.0, // Görsellerin yüksekliği
              margin: const EdgeInsets.only(top: 10.0),
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: (widget.questionData['imageUrls'] as List).length,
                itemBuilder: (context, index) {
                  String imageUrl =
                      (widget.questionData['imageUrls'] as List)[index];
                  return Padding(
                    padding: const EdgeInsets.only(right: 10.0),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10.0),
                      child: Image.network(
                        imageUrl,
                        width: 200.0,
                        height: 200.0,
                        fit: BoxFit.cover,
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        },
                        errorBuilder: (context, error, stackTrace) =>
                            const Icon(Icons.broken_image, size: 50),
                      ),
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildAnswersList() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('forumQuestions')
          .doc(widget.questionId)
          .collection('answers')
          .orderBy('timestamp', descending: true)
          .snapshots(),
      builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Bir hata oluştu: ${snapshot.error}'));
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text('Henüz yanıt bulunmuyor.'));
        }

        return ListView(
          children: snapshot.data!.docs.map((doc) {
            var data = doc.data() as Map<String, dynamic>;
            String answerUserId = data['userId'] ?? '';

            return FutureBuilder<DocumentSnapshot>(
              future: FirebaseFirestore.instance
                  .collection('users')
                  .doc(answerUserId)
                  .get(),
              builder: (context, userSnapshot) {
                if (userSnapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (userSnapshot.hasError) {
                  return Center(
                      child: Text('Bir hata oluştu: ${userSnapshot.error}'));
                }

                var userData =
                    userSnapshot.data?.data() as Map<String, dynamic>?;

                return _buildAnswerCard(data, userData);
              },
            );
          }).toList(),
        );
      },
    );
  }

  Widget _buildAnswerCard(
      Map<String, dynamic> data, Map<String, dynamic>? userData) {
    return Container(
      padding: const EdgeInsets.all(15.0),
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.0),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 8.0,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundImage: userData?['profileImageUrl'] != null
              ? NetworkImage(userData!['profileImageUrl'])
              : const AssetImage('assets/default_avatar.png') as ImageProvider,
          backgroundColor: const Color.fromARGB(255, 147, 58, 142),
          child: userData?['profileImageUrl'] == null
              ? const Icon(Icons.person, color: Colors.white)
              : null,
        ),
        title: Text(data['answer'] ?? 'Yanıt bulunamadı'),
        subtitle: Text(
          "Yanıtlayan: ${userData?['firstName'] ?? 'Anonim'} ${userData?['lastName'] ?? ''}",
          style: TextStyle(color: Colors.grey[600]),
        ),
      ),
    );
  }

  Widget _buildAnswerInputSection() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
      color: const Color.fromARGB(255, 147, 58, 142),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _answerController,
              decoration: InputDecoration(
                hintText: 'Cevabınızı yazın...',
                hintStyle: const TextStyle(color: Colors.white70),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.white.withOpacity(0.1),
              ),
              maxLines: null,
              style: const TextStyle(color: Colors.white),
            ),
          ),
          const SizedBox(width: 8),
          ElevatedButton(
            onPressed: _isSubmitting ? null : _submitAnswer,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: const Color.fromARGB(255, 147, 58, 142),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: _isSubmitting
                ? const CircularProgressIndicator(
                    color: Color.fromARGB(255, 147, 58, 142))
                : const Text('Gönder'),
          ),
        ],
      ),
    );
  }

  Future<void> _submitAnswer() async {
    if (_answerController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Yanıt boş bırakılamaz.')),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        await FirebaseFirestore.instance
            .collection('forumQuestions')
            .doc(widget.questionId)
            .collection('answers')
            .add({
          'userId': user.uid,
          'userName': user.displayName ?? 'Anonim',
          'userPhotoUrl': user.photoURL ?? '',
          'answer': _answerController.text,
          'timestamp': Timestamp.now(),
        });

        _answerController.clear();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Yanıtınız gönderildi!')),
        );
      } catch (e) {
        print("Yanıt gönderme hatası: $e");
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Bir hata oluştu, lütfen tekrar deneyin.')),
        );
      } finally {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }
}

void main() {
  runApp(const MaterialApp(
    title: 'Forum Yanıtları',
    home: AnswersPage(
      questionId: 'exampleQuestionId',
      questionData: {'question': 'Bu bir örnek sorudur', 'userName': 'Irem'},
    ),
  ));
}
