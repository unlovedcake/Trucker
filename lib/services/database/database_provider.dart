import 'package:flutter/material.dart';
import 'package:trucker/models/post.dart';
import 'package:trucker/models/users.dart';
import 'package:trucker/services/database/database_service.dart';

import '../../models/comment.dart';
import '../auth/auth_service.dart';

/*

DATABASE PROVIDER

This provider is use to separate the firestore data handling and UI of our app  
- The database service class handles data to and from firebase
- The database provider class processes the data to display in our app
- This is to make our code much more modular, cleaner, and easier to read and
test, particularly as the number of pages grow, we need this provider to 
properly manage the different states of the app.

- Also, if one day, we decide to change our backend from, it's much easier to 
switch out 

 */

class DatabaseProvider extends ChangeNotifier {
  /*
  
  SERVICES 
  
   */

  // get db and auth service
  final _db = DatabaseService();
  final _auth = AuthService();

  /*
  
  USER PROFILE

   */
  // get user profile given uid
  Future<UserProfile?> userProfile(String uid) => _db.getUserFromFirebase(uid);

  // update user bio
  Future<void> updateBio(String bio) => _db.updateUserBioInFirebase(bio);

  /*

  POST

  */

  // local list of post
  List<Post> _allPosts = [];

  // get posts
  List<Post> get allPosts => _allPosts;

  // post message
  Future<void> postMessage(String message) async {
    // post message in firebase
    await _db.postMessageInFirebase(message);

    // reload data from firebase
    loadAllPosts();
  }

  // fetch all post
  Future<void> loadAllPosts() async {
    // get all post from firebase
    final allPosts = await _db.getAllPostsFromFirebase();

    //get blocked user ids
    final blockedUserIds = await _db.getBlockedUidsFromFirebase();

    //filter out blocked users posts and update locally
    _allPosts =
        allPosts.where((post) => !blockedUserIds.contains(post.uid)).toList();

    //initialize local like data
    initializeLikeMap();

    // update UI
    notifyListeners();
  }

  // filter and return posts given uid
  List<Post> filterUserPosts(String uid) {
    return _allPosts.where((post) => post.uid == uid).toList();
  }

  //delete post
  Future<void> deletePost(String postId) async {
    //delete from firebase
    await _db.deletePostFromFirebase(postId);

    //reload data from firebase
    await loadAllPosts();
  }

/*

LIKES

 */

  //local map to track the like counts for each post
  Map<String, int> _likeCounts = {
    //for each post id: like count
  };

  //local list to track posts liked by current user
  List<String> _likedPosts = [];

  //does current user like this post
  bool isPostLikedByCurrentUser(String postId) => _likedPosts.contains(postId);

  //get like count of a post
  int getLikeCount(String postId) => _likeCounts[postId] ?? 0;

  //initialize like map locally
  void initializeLikeMap() {
    //get current uid
    final currentUserID = _auth.getCurrentUid();

    //clear liked posts (for when new user  signs in, clear local data)
    _likedPosts.clear();

    //for each post get like data
    for (var post in _allPosts) {
      //update like count map
      _likeCounts[post.id] = post.likeCount;

      //if the current user already likes this post
      if (post.likedBy.contains(currentUserID)) {
        // add this post id to local list of liked posts
        _likedPosts.add(post.id);
      }
    }
  }

  //toggle like
  Future<void> toggleLike(String postId) async {
    /*

    This first part will update the local values first so that the UI feels 
    immediate and responsive. we will update the UI , and revert back if anything 
    goes wrong while writing to the database

    optimistically updating the local values like this is important because:
    reading and writing from the database take some time (1-2 seconds depends on
    the internet). We dont want the users to experience slow lagged

     */

    //store original values in case it fails
    final likedPostsOriginal = _likedPosts;
    final likeCountsOriginal = _likeCounts;

    //perform like / unlike
    if (_likedPosts.contains(postId)) {
      _likedPosts.remove(postId);
      _likeCounts[postId] = (_likeCounts[postId] ?? 0) - 1;
    } else {
      _likedPosts.add(postId);
      _likeCounts[postId] = (_likeCounts[postId] ?? 0) + 1;
    }

    //update UI
    notifyListeners();

    /*
    
    Now lets try to update in our database

    */

    //attempt like in database
    try {
      await _db.toggleLikeInFirebase(postId);
    }

    //revert back to initial state if update fails
    catch (e) {
      _likedPosts = likedPostsOriginal;
      _likeCounts = likeCountsOriginal;

      //update UI again
      notifyListeners();
    }
  }

/*

Comments
{
postId1: [comment1, comment2, ...],
postId2: [comment1, comment2, ...],
postId3: [comment1, comment2, ...],
}

*/

  //local list of comments
  final Map<String, List<Comment>> _comments = {};

  //get comments locally
  List<Comment> getComments(String postId) => _comments[postId] ?? [];

  //fetch comments from database for a post
  Future<void> loadComments(String postId) async {
    //get all comments for this post
    final allComments = await _db.getCommentsFromFirebase(postId);

    //update local data
    _comments[postId] = allComments;

    //update UI
    notifyListeners();
  }

  //add a comment
  Future<void> addComment(String postId, message) async {
    //add comment in firebase
    await _db.addCommentInFirebase(postId, message);

    //reload comments
    await loadComments(postId);
  }

  //delete a comment
  Future<void> deleteComment(String commentId, postId) async {
    //delete comment from firebase
    await _db.deleteCommentInFirebase(commentId);

    //reload comments
    await loadComments(postId);
  }

/*
Account stuff
*/

  //local list of blocked users
  List<UserProfile> _blockedUsers = [];

  //get list of blocked users
  List<UserProfile> get blockedUsers => _blockedUsers;

  //fetch blocked users
  Future<void> loadBlockedUsers() async {
    //get list of blocked user ids
    final blockedUserIds = await _db.getBlockedUidsFromFirebase();

    //get full user details using uid
    final blockedUsersData = await Future.wait(
        blockedUserIds.map((id) => _db.getUserFromFirebase(id)));

    //return as a list
    _blockedUsers = blockedUsersData.whereType<UserProfile>().toList();

    //update UI
    notifyListeners();
  }

  //block user
  Future<void> blockUser(String userId) async {
    //perform block in firebase
    await _db.blockUserInFirebase(userId);

    //reload blocked users
    await loadBlockedUsers();

    //reload posts
    await loadAllPosts();

    //update UI
    notifyListeners();
  }

  //unblock user
  Future<void> unblockUser(String blockedUserId) async {
    //perform unblock in firebase
    await _db.unblockUserInFirebase(blockedUserId);

    //reload blocked users
    await loadBlockedUsers();

    //reload posts
    await loadAllPosts();

    //update UI
    notifyListeners();
  }

  //report user & post
  Future<void> reportUser(String postId, userId) async {
    await _db.reportUserInFirebase(postId, userId);
  }
}
