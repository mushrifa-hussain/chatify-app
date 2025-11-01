import 'package:cloud_firestore/cloud_firestore.dart';

class Contact {
  final String? id;
  final String? email;
  final String? image;
  final Timestamp? lastseen;
  final String? name;

  Contact({this.id, this.email, this.name, this.image, this.lastseen});

  factory Contact.fromFirestore(DocumentSnapshot snapshot) {
    final data = snapshot.data() as Map<String, dynamic>?;

    return Contact(
      id: snapshot.id,
      lastseen: data?["LastSeen"],
      email: data?["email"],
      name: data?["name"],
      image: data?["imageUrl"] ?? '',
    );
  }
}
