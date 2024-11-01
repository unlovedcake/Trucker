import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';

class PresenceService {
  final DatabaseReference _statusRef = FirebaseDatabase.instance.ref();
  final DatabaseReference _connectedRef =
      FirebaseDatabase.instance.ref(".info/connected");

  final DatabaseReference _dbRef =
      FirebaseDatabase.instance.ref().child('users');

  final userI = FirebaseAuth.instance.currentUser;

  Future<void> addUserToRealTimeDatabase(String userId) async {
    try {
      // Create a unique key for the new user
      //String userId = userI!.uid; //_dbRef.push().key!;

      Map<String, String> userData = {
        'status': 'online',
      };

      // Add the user data under the generated key
      await _dbRef.child(userId).set(userData);
      print("User added successfully!");
    } catch (e) {
      print("Error adding user: $e");
    }
  }

  void setUserOnlineStatus() async {
    final userStatusRef = _statusRef.child('users/${userI!.uid}');

    // Monitor connection status.
    _connectedRef.onValue.listen((event) {
      if (event.snapshot.value == true) {
        // User is online
        userStatusRef.set({"status": "online"});
        userStatusRef.onDisconnect().set({"status": "offline"});
        print("User Online");
      } else {
        // User is offline
        userStatusRef.set({"status": "offline"});
        print("User offline ");
      }
    });

    // // Fetch data from Realtime Database using UID as the key
    // DatabaseEvent event = await _dbRef.child(userI!.uid).once();

    // // Check if data exists
    // if (event.snapshot.exists) {
    //   print('event snap ${event.snapshot.value}');
    // } else {
    //   print('event snap');
    // }
  }
}
