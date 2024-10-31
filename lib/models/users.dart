import 'package:cloud_firestore/cloud_firestore.dart';

/*

USER PROFILE

This is what every user should have for their profile 

--------------------------------------------------------------------------------

- UID 
- NAME
- EMAIL
- USERNAME
- BIO 
- PROFILE PHOTO 

 */

class UserProfile {
  final String uid;
  final String name;
  final String email;
  final String username;
  final String bio;
  final String role;
  final GeoPoint location;
  String? truckname;
  String? address;

  UserProfile({
    required this.uid,
    required this.name,
    required this.email,
    required this.username,
    required this.bio,
    required this.role,
    required this.location,
    this.truckname,
    this.address,
  });

  /*

  firebase -> app
  convert firestore document to a user profile (so that we can use in our app)

  */

  factory UserProfile.fromMap(Map<String, dynamic> map) {
    return UserProfile(
      uid: map['uid'] ?? '',
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      username: map['username'] ?? '',
      bio: map['bio'] ?? '',
      role: map['role'] ?? '',
      truckname: map['truckname'] ?? '',
      address: map['address'] ?? '',
      location: map['location'] as GeoPoint,
    );
  }

  factory UserProfile.fromDocument(DocumentSnapshot doc) {
    return UserProfile(
      uid: doc['uid'],
      name: doc['name'],
      email: doc['email'],
      username: doc['username'],
      bio: doc['bio'],
      role: doc['role'],
      truckname: doc['truckname'],
      address: doc['address'],
      location: doc['location'],
    );
  }

  /*
  
  app -> firebase
  convert user profile to a map (so that we can store in firebase)
  
  */
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'name': name,
      'email': email,
      'username': username,
      'bio': bio,
      'truckname': truckname,
      'address': address,
      'role': role,
      'location': location,
    };
  }
}

class Location {
  final double lat;
  final double lng;

  Location({
    required this.lat,
    required this.lng,
  });
}

class Truck {
  String? name;
  String? address;
  double? distance;

  Truck({this.name, this.address, this.distance});

  factory Truck.fromDocument(DocumentSnapshot data) {
    return Truck(
      name: data['name'] ?? '',
      address: data['address'] ?? '',
      distance: data['distance'] ?? 0,
    );
  }

  factory Truck.fromMap(Map<String, dynamic> data) {
    return Truck(
      name: data['name'] ?? '',
      address: data['address'] ?? '',
      distance: data['distance'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'address': address,
      'distance': distance,
    };
  }
}
