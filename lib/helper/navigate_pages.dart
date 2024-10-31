import 'package:flutter/material.dart';
import 'package:trucker/pages/profile_page.dart';

import '../models/post.dart';
import '../pages/account_settings_page.dart';
import '../pages/blocked_users_page.dart';
import '../pages/post_page.dart';

String role = '';

//go to user page
void goUserPage(BuildContext context, String uid) {
  //navigate to the page
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => ProfilePage(uid: uid),
    ),
  );
}

//go to post page
void goPostPage(BuildContext context, Post post) {
  //navigate to post page
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => PostPage(
        post: post,
      ),
    ),
  );
}

//go to blocked users page
void goBlockedUsersPage(BuildContext context) {
  //navigate to page
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => const BlockedUsersPage(),
    ),
  );
}

//go to account settings page
void goAccountSettingsPage(BuildContext context) {
  //navigate to page
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => const AccountSettingsPage(),
    ),
  );
}
