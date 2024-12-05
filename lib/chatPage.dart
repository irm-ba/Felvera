import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ChatPage extends StatefulWidget {
  final String conversationId;
  final String receiverId;
  final String receiverName;
  final String senderName;

  const ChatPage({
    required this.conversationId,
    required this.receiverId,
    required this.receiverName,
    required this.senderName,
    Key? key,
  }) : super(key: key);

  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  String? _receiverProfileImageUrl;

  @override
  void initState() {
    super.initState();
    _fetchReceiverProfileImage();
  }

  Future<void> _fetchReceiverProfileImage() async {
    try {
      final userDoc =
          await _firestore.collection('users').doc(widget.receiverId).get();
      if (userDoc.exists) {
        setState(() {
          _receiverProfileImageUrl = userDoc.data()?['profileImageUrl'];
        });
      }
    } catch (e) {
      print('Profil resmi alınamadı: $e');
    }
  }

  bool _containsPhoneNumber(String text) {
    // Telefon numarası regexi
    final phoneNumberRegex = RegExp(r'\b\d{10,13}\b');
    return phoneNumberRegex.hasMatch(text);
  }

  Future<void> _sendMessage() async {
    final messageText = _messageController.text.trim();
    if (messageText.isEmpty) return;

    final currentUserId = _auth.currentUser?.uid;
    if (currentUserId == null) return;

    try {
      final chatDoc =
          await _firestore.collection('chats').doc(widget.conversationId).get();
      if (!chatDoc.exists) {
        // Sohbet belgesi yoksa oluştur
        await _firestore.collection('chats').doc(widget.conversationId).set({
          'participants': [currentUserId, widget.receiverId],
          'lastMessage': messageText,
          'lastMessageTimestamp': FieldValue.serverTimestamp(),
          'timestamp': FieldValue.serverTimestamp(),
        });
      }

      // Mesajı sohbete ekle
      await _firestore
          .collection('chats')
          .doc(widget.conversationId)
          .collection('messages')
          .add({
        'text': messageText,
        'senderId': currentUserId,
        'timestamp': FieldValue.serverTimestamp(),
      });

      // Sohbet listesindeki son mesajı güncelle
      await _firestore.collection('chats').doc(widget.conversationId).update({
        'lastMessage': messageText,
        'lastMessageTimestamp': FieldValue.serverTimestamp(),
      });

      _messageController.clear();
    } catch (e) {
      print('Mesaj gönderme hatası: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            CircleAvatar(
              backgroundImage: _receiverProfileImageUrl != null
                  ? NetworkImage(_receiverProfileImageUrl!)
                  : const AssetImage('assets/default_profile_image.png')
                      as ImageProvider,
            ),
            const SizedBox(width: 8),
            Text(widget.receiverName),
          ],
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: const AssetImage(
                'assets/images/paw_print_background.png'), // Arka plan resmi
            fit: BoxFit.cover,
            colorFilter: ColorFilter.mode(
                Colors.white.withOpacity(0.6), BlendMode.dstATop),
          ),
        ),
        child: Stack(
          children: [
            Column(
              children: [
                Expanded(
                  child: StreamBuilder<QuerySnapshot>(
                    stream: _firestore
                        .collection('chats')
                        .doc(widget.conversationId)
                        .collection('messages')
                        .orderBy('timestamp', descending: true)
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      final messages = snapshot.data!.docs;

                      return ListView.builder(
                        controller: _scrollController,
                        reverse: true,
                        itemCount: messages.length,
                        itemBuilder: (context, index) {
                          final message =
                              messages[index].data() as Map<String, dynamic>;
                          final isMe =
                              message['senderId'] == _auth.currentUser?.uid;

                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4.0),
                            child: Row(
                              mainAxisAlignment: isMe
                                  ? MainAxisAlignment.end
                                  : MainAxisAlignment.start,
                              children: [
                                if (!isMe)
                                  CircleAvatar(
                                    backgroundImage: _receiverProfileImageUrl !=
                                            null
                                        ? NetworkImage(
                                            _receiverProfileImageUrl!)
                                        : const AssetImage(
                                                'assets/default_profile_image.png')
                                            as ImageProvider,
                                  ),
                                const SizedBox(width: 8),
                                Flexible(
                                  child: Container(
                                    padding: const EdgeInsets.all(12),
                                    margin: EdgeInsets.only(
                                        left: isMe ? 0 : 8,
                                        right: isMe ? 8 : 0),
                                    decoration: BoxDecoration(
                                      color: isMe
                                          ? const Color.fromARGB(
                                              255, 147, 58, 142)
                                          : Colors.grey[200],
                                      borderRadius: BorderRadius.only(
                                        topLeft: const Radius.circular(12),
                                        topRight: const Radius.circular(12),
                                        bottomLeft:
                                            Radius.circular(isMe ? 12 : 0),
                                        bottomRight:
                                            Radius.circular(isMe ? 0 : 12),
                                      ),
                                    ),
                                    child: Text(
                                      message['text'],
                                      style: TextStyle(
                                        color: isMe
                                            ? Colors.white
                                            : Colors.black87,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _messageController,
                          decoration: InputDecoration(
                            hintText: 'Mesajınızı yazın...',
                            filled: true,
                            fillColor: Colors.white,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20),
                              borderSide: BorderSide.none,
                            ),
                            contentPadding:
                                const EdgeInsets.symmetric(horizontal: 16),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: _sendMessage,
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              const Color.fromARGB(255, 147, 58, 142),
                          shape: const CircleBorder(),
                          padding: const EdgeInsets.all(12),
                        ),
                        child: const Icon(Icons.send, color: Colors.white),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
