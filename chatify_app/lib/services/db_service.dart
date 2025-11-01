import '../models/conversation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/contact.dart';
import '../models/message.dart';
import '../services/cloud_storage_service.dart';

class DBService {
  static DBService instance = DBService();
  late FirebaseFirestore _db;

  DBService() {
    _db = FirebaseFirestore.instance;
  }

  String usersCollection = "Users";
  String conversationsCollection = "Conversations";

  Future<void> createUserInDB(
    String uid,
    String name,
    String email,
    String imageUrl,
  ) async {
    try {
      return await _db.collection(usersCollection).doc(uid).set({
        'name': name,
        'email': email,
        'imageUrl': imageUrl,
        "LastSeen": DateTime.now().toUtc(),
      });
    } catch (e) {
      throw Exception("Error creating user in DB: $e");
    }
  }

  Future<void> sendMessage(String conversationID, Message message) async {
    var ref = _db.collection(conversationsCollection).doc(conversationID);
    var messageType = "";
    switch (message.type) {
      case MessageType.text:
        messageType = "text";
        break;
      case MessageType.image:
        messageType = "image";
        break;
      default:
        messageType = "text";
    }
    return ref.update({
      'messages': FieldValue.arrayUnion([
        {
          'message': message.content,
          'timestamp': message.timestamp,
          'senderID': message.senderID,
          'type': messageType,
        },
      ]),
    });
  }

  Future<void> createOrGetConversation(
    String currentID,
    String recipientID,
    Future<void> Function(String conversationID) onSuccess,
  ) async {
    var ref = _db.collection(conversationsCollection);

    try {
      // 🔍 Step 1: Check if a conversation already exists between the two users
      var existingConversations = await ref
          .where("members", arrayContains: currentID)
          .get();

      for (var doc in existingConversations.docs) {
        List members = List<String>.from(doc["members"] ?? []);
        if (members.contains(recipientID)) {
          // ✅ Conversation already exists → reuse its ID
          return onSuccess(doc.id);
        }
      }

      // 🆕 Step 2: If no existing conversation, create a new one
      var conversationRef = ref.doc();
      await conversationRef.set({
        "members": [currentID, recipientID],
        "ownerID": currentID,
        "messages": [],
        "timestamp": FieldValue.serverTimestamp(),
      });

      // ✅ Return the newly created conversationID
      return onSuccess(conversationRef.id);
    } catch (e) {
      throw Exception("Error creating or getting conversation: $e");
    }
  }

  Future<void> deleteMessages(
    String currentUid,
    String receiverID,
    String conversationID,
    List<String> messageIDs,
  ) async {
    try {
      final convoRef = _db
          .collection(conversationsCollection)
          .doc(conversationID);
      final convoSnap = await convoRef.get();

      if (!convoSnap.exists) return;

      final convoData = convoSnap.data() as Map<String, dynamic>;
      final messages = List<Map<String, dynamic>>.from(
        convoData['messages'] ?? [],
      );

      // 🗑️ Filter out deleted messages
      final updatedMessages = messages.where((m) {
        final ts = m['timestamp'];
        final tsString = ts is Timestamp
            ? ts.millisecondsSinceEpoch.toString()
            : ts.toString();
        return !messageIDs.contains(tsString);
      }).toList();

      // 🖼️ Delete any image files if type = image
      for (var m in messages) {
        final ts = m['timestamp'];
        final tsString = ts is Timestamp
            ? ts.millisecondsSinceEpoch.toString()
            : ts.toString();
        if (messageIDs.contains(tsString) &&
            m['type'] == 'image' &&
            m['message'] != null) {
          await CloudStorageService.instance.deleteImage(m['message']);
        }
      }

      // 🆙 Update conversation messages
      await convoRef.update({'messages': updatedMessages});

      // 🔄 Update the last message for both users
      Future<void> updateUserSnippet(String userId, String otherId) async {
        final userConvoRef = _db
            .collection(usersCollection)
            .doc(userId)
            .collection(conversationsCollection)
            .doc(otherId);

        if (updatedMessages.isEmpty) {
          await userConvoRef.update({
            'lastMessage': '',
            'timestamp': null,
            'type': null,
          });
        } else {
          updatedMessages.sort((a, b) {
            final aTs = a['timestamp'] as Timestamp;
            final bTs = b['timestamp'] as Timestamp;
            return bTs.compareTo(aTs);
          });
          final latest = updatedMessages.first;
          await userConvoRef.update({
            'lastMessage': latest['message'] ?? '',
            'timestamp': latest['timestamp'],
            'type': latest['type'],
          });
        }
      }

      await updateUserSnippet(currentUid, receiverID);
      await updateUserSnippet(receiverID, currentUid);
    } catch (e) {
      throw Exception('Error deleting messages: $e');
    }
  }

  Stream<Contact> getUserData(String uid) {
    var ref = _db.collection(usersCollection).doc(uid);
    return ref.get().asStream().map(
      (snapshot) => Contact.fromFirestore(snapshot),
    );
  }

  Stream<List<ConversationSnippet>> getUserConversations(String uid) {
    var ref = _db
        .collection(usersCollection)
        .doc(uid)
        .collection(conversationsCollection);

    return ref.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return ConversationSnippet.fromFirestore(doc);
      }).toList();
    });
  }

  Stream<List<Contact>> getUsersInDB(String searchName) {
    var ref = _db
        .collection(usersCollection)
        .orderBy("name")
        .startAt([searchName])
        .endAt(["$searchName\uf8ff"]);

    return ref.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => Contact.fromFirestore(doc)).toList();
    });
  }

  Stream<Conversation> getConversation(String conversationID) {
    var ref = _db.collection(conversationsCollection).doc(conversationID);

    return ref.snapshots().map((snapshot) {
      return Conversation.fromFirestore(snapshot);
    });
  }
}
