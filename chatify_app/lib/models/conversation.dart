import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/message.dart';

class ConversationSnippet {
  final String? id;
  final String? chatID;
  final String? lastMessage;
  final String? name;
  final String? imageUrl;
  final MessageType? type;
  final int? unseenCount;
  final Timestamp? timestamp;

  ConversationSnippet({
    this.chatID,
    this.id,
    this.lastMessage,
    this.unseenCount,
    this.timestamp,
    this.name,
    this.imageUrl,
    this.type,
  });

  factory ConversationSnippet.fromFirestore(DocumentSnapshot snapshot) {
    final data = snapshot.data() as Map<String, dynamic>?;

    var messageType = MessageType.text;
    if (data?["type"] != null) {
      switch (data!["type"]) {
        case "text":
          break;
        case "image":
          messageType = MessageType.image;
          break;
        default:
          messageType = MessageType.text;
      }
    }
    return ConversationSnippet(
      id: snapshot.id,
      chatID: data?["chatID"],
      lastMessage: data?["lastMessage"] ?? '',
      unseenCount: data?["unseenCount"],
      timestamp: data?["timestamp"] != null ? data!["timestamp"] : null,
      name: data?["name"],
      imageUrl: data?["imageUrl"] ?? '',
      type: messageType,
    );
  }
}

class Conversation {
  final String? id;
  final List? members;
  final List<Message>? messages;
  final String? ownerID;

  Conversation({this.id, this.members, this.ownerID, this.messages});

  factory Conversation.fromFirestore(DocumentSnapshot snapshot) {
    var data = snapshot.data() as Map<String, dynamic>?;

    List? messagesData = data?["messages"];
    List<Message>? messages;

    if (messagesData != null) {
      messages = messagesData
          .map((m) {
            return Message(
              type: m["type"] == "text" ? MessageType.text : MessageType.image,
              content: m["message"],
              timestamp: m["timestamp"],
              senderID: m["senderID"],
            );
          })
          .toList()
          .cast<Message>();
    } else {
      messages = [];
    }

    return Conversation(
      id: snapshot.id,
      members: data?["members"],
      ownerID: data?["ownerID"],
      messages: messages,
    );
  }
}
