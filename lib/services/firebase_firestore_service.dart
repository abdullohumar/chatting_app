import 'package:chatting_app/model/chat.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseFirestoreService {
  final FirebaseFirestore _firebaseFirestore;
  FirebaseFirestoreService(FirebaseFirestore? firebaseFireStore)
    : _firebaseFirestore = firebaseFireStore ??= FirebaseFirestore.instance;

  Future<void> sendMessage({
    required String text,
    required String emailSender,
    Timestamp? timestamp,
  }) async {
    timestamp ??= Timestamp.now();

    await _firebaseFirestore.collection('messages').add({
      'text': text,
      'sender': emailSender,
      'dateCreated': timestamp,
    });
  }

  Stream<List<Chat>> getMessages() {
    return _firebaseFirestore
        .collection('messages')
        .orderBy('dateCreated', descending: true)
        .snapshots()
        .map(
          (event) => event.docs.map((e) {
            final data = Chat.fromJson(e.data());
            return data;
          }).toList(),
        );
  }
}
