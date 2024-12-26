import 'package:felvera/services/image_utils.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:typed_data';

class EventPage extends StatefulWidget {
  const EventPage({Key? key}) : super(key: key);

  @override
  _EventPageState createState() => _EventPageState();
}

class _EventPageState extends State<EventPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gönüllük Etkinlikleri'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => CreateEventPage()),
              );
            },
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('events').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Hata oluştu: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('Henüz etkinlik bulunmamaktadır.'));
          }

          List<QueryDocumentSnapshot> docs = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            itemCount: docs.length,
            itemBuilder: (context, index) {
              var doc = docs[index];
              return EventCard(
                eventData: EventData.fromSnapshot(doc),
              );
            },
          );
        },
      ),
    );
  }
}

class CreateEventPage extends StatefulWidget {
  const CreateEventPage({Key? key}) : super(key: key);

  @override
  _CreateEventPageState createState() => _CreateEventPageState();
}

class _CreateEventPageState extends State<CreateEventPage> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  Uint8List? _selectedImage;

  final _formKey = GlobalKey<FormState>();

  Future<void> _pickImage() async {
    _selectedImage = await ImageUtils.pickImage();
    setState(() {});
  }

  Future<void> _uploadEvent() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    String? imageUrl;
    if (_selectedImage != null) {
      imageUrl = await ImageUtils.uploadImage(_selectedImage!, 'events');
    }

    await FirebaseFirestore.instance.collection('events').add({
      'title': _titleController.text,
      'description': _descriptionController.text,
      'imageUrl': imageUrl,
      'date': _dateController.text,
      'participants': [],
    });

    Navigator.pop(context);
  }

  Future<void> _selectDate() async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (pickedDate != null) {
      setState(() {
        _dateController.text = pickedDate.toLocal().toIso8601String().split('T')[0];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Etkinlik Oluştur"),
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
                  height: 200,
                  color: Colors.grey[200],
                  child: _selectedImage == null
                      ? const Center(child: Text('Resim Seç'))
                      : Image.memory(_selectedImage!, fit: BoxFit.cover),
                ),
              ),
              const SizedBox(height: 16.0),
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Başlık'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Başlık boş olamaz';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16.0),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: 'Açıklama'),
                maxLines: 4,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Açıklama boş olamaz';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16.0),
              GestureDetector(
                onTap: _selectDate,
                child: AbsorbPointer(
                  child: TextFormField(
                    controller: _dateController,
                    decoration: const InputDecoration(
                      labelText: 'Tarih',
                      suffixIcon: Icon(Icons.calendar_today),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Tarih boş olamaz';
                      }
                      return null;
                    },
                  ),
                ),
              ),
              const SizedBox(height: 32.0),
              ElevatedButton(
                onPressed: _uploadEvent,
                child: const Text('Oluştur'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class EventData {
  final String id;
  final String? title;
  final String? description;
  final String? imageUrl;
  final String? date;
  final List<dynamic>? participants;

  EventData({
    required this.id,
    this.title,
    this.description,
    this.imageUrl,
    this.date,
    this.participants,
  });

  factory EventData.fromSnapshot(DocumentSnapshot snapshot) {
    final data = snapshot.data() as Map<String, dynamic>;
    return EventData(
      id: snapshot.id,
      title: data['title'] as String?,
      description: data['description'] as String?,
      imageUrl: data['imageUrl'] as String?,
      date: data['date'] as String?,
      participants: data['participants'] as List<dynamic>?,
    );
  }
}

class EventCard extends StatelessWidget {
  final EventData eventData;

  const EventCard({required this.eventData});

  Future<void> joinEvent(BuildContext context) async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId != null) {
      final eventDoc =
      FirebaseFirestore.instance.collection('events').doc(eventData.id);

      await eventDoc.update({
        'participants': FieldValue.arrayUnion([userId])
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Etkinliğe katıldınız!')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Katılmak için giriş yapmalısınız.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _showEventDetails(context),
      child: Card(
        elevation: 8,
        margin: const EdgeInsets.symmetric(vertical: 12.0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
        color: Colors.white,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius:
              const BorderRadius.vertical(top: Radius.circular(12.0)),
              child: eventData.imageUrl != null
                  ? Image.network(
                eventData.imageUrl!,
                height: 200,
                width: double.infinity,
                fit: BoxFit.cover,
              )
                  : const Placeholder(fallbackHeight: 200),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    eventData.title ?? 'Başlık Yok',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w600,
                      color: Color.fromARGB(255, 147, 58, 142),
                    ),
                  ),
                  const SizedBox(height: 8.0),
                  Row(
                    children: [
                      const Icon(Icons.date_range,
                          color: Color.fromARGB(255, 170, 169, 170)),
                      const SizedBox(width: 4.0),
                      Text(
                        eventData.date ?? 'Tarih Yok',
                        style: TextStyle(
                          color: Colors.grey[700],
                          fontSize: 14,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4.0),
                  Row(
                    children: [
                      const Icon(Icons.people,
                          color: Color.fromARGB(255, 170, 169, 170)),
                      const SizedBox(width: 4.0),
                      Text(
                        "${eventData.participants?.length} katılımcı",
                        style: TextStyle(
                          color: Colors.grey[700],
                          fontSize: 14,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8.0),
                  Text(
                    eventData.description ?? 'Açıklama Yok',
                    style: const TextStyle(
                      fontSize: 16,
                      height: 1.5,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 16.0),
                  ElevatedButton(
                    onPressed: () => joinEvent(context),
                    child: const Text('Etkinliğe Katıl'),
                    style: ElevatedButton.styleFrom(
                      foregroundColor: const Color.fromARGB(255, 147, 58, 142),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showEventDetails(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0),
          ),
          title: Text(
            eventData.title ?? 'Başlık Yok',
            style: const TextStyle(
              color: Color.fromARGB(255, 147, 58, 142),
            ),
          ),
          content: SingleChildScrollView(
            child: ListBody(
              children: [
                Text(
                  'Etkinlik Tarihi: ${eventData.date ?? 'Tarih Yok'}',
                  style: TextStyle(
                    color: Colors.grey[700],
                    fontSize: 14,
                    fontStyle: FontStyle.italic,
                  ),
                ),
                const SizedBox(height: 8.0),
                Text(
                  'Katılımcılar: ${eventData.participants?.length ?? 0}',
                  style: TextStyle(
                    color: Colors.grey[700],
                    fontSize: 14,
                    fontStyle: FontStyle.italic,
                  ),
                ),
                const SizedBox(height: 8.0),
                Text(
                  eventData.description ?? 'Açıklama Yok',
                  style: const TextStyle(
                    fontSize: 16,
                    height: 1.5,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              child: const Text(
                'Kapat',
                style: TextStyle(
                  color: Color.fromARGB(255, 147, 58, 142),
                ),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
