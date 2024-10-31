import 'package:cloud_firestore/cloud_firestore.dart';

/*

POST MODEL

This is what every post should have

*/

class Post {
  final String id; // id of this post
  final String uid; // uid of the poster
  final String name; // name of the poster
  final String username; // username of the poster
  final String message; // message of a post
  final Timestamp timestamp; // timestamp of the post
  final int likeCount; // like counts of post
  final List<String> likedBy; // list of user IDs who liked the post

  Post({
    required this.id,
    required this.uid,
    required this.name,
    required this.username,
    required this.message,
    required this.timestamp,
    required this.likeCount,
    required this.likedBy,
  });

  // Convert a Firestore document to a post object (To use in our app)
  factory Post.fromDocument(DocumentSnapshot doc) {
    return Post(
      id: doc.id,
      uid: doc['uid'],
      name: doc['name'],
      username: doc['username'],
      message: doc['message'],
      timestamp: doc['timestamp'],
      likeCount: doc['likes'],
      likedBy: List<String>.from(doc['likedBy'] ?? []),
    );
  }

  // Convert a Post object to a map (To store in firebase)
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'name': name,
      'username': username,
      'message': message,
      'timestamp': timestamp,
      'likes': likeCount,
      'likedBy': likedBy,
    };
  }
}
