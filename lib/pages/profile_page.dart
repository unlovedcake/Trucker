import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:trucker/components/my_bio_box.dart';
import 'package:trucker/components/my_input_alert_box.dart';
import 'package:trucker/components/my_post_tile.dart';
import 'package:trucker/helper/navigate_pages.dart';
import 'package:trucker/models/users.dart';
import 'package:trucker/services/auth/auth_service.dart';
import 'package:trucker/services/database/database_provider.dart';

/*

This is a profile page for a given uid

 */

class ProfilePage extends StatefulWidget {
  final String uid;
  const ProfilePage({
    super.key,
    required this.uid,
  });

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  // providers
  late final listeningProvider = Provider.of<DatabaseProvider>(context);
  late final databaseProvider =
      Provider.of<DatabaseProvider>(context, listen: false);

  // user info
  UserProfile? user;
  String currentUserId = AuthService().getCurrentUid();

  // Text controller for bio
  final bioTextController = TextEditingController();

  // loading
  bool _isLoading = true;

  // on startup,
  @override
  void initState() {
    super.initState();

    // load user information
    loadUser();
  }

  Future<void> loadUser() async {
    // get the user profile info
    user = await databaseProvider.userProfile(widget.uid);

    // finished loading
    setState(() {
      _isLoading = false;
    });
  }

  // Show edit bio box
  void _showEditBioBox() {
    showDialog(
      context: context,
      builder: (context) => MyInputAlertBox(
          textController: bioTextController,
          hintText: "Edit bio...",
          onPressed: saveBio,
          onPressedText: "Save"),
    );
  }

  // Save updated bio
  Future<void> saveBio() async {
    // Start loading
    setState(() {
      _isLoading = true;
    });
    // update bio
    await databaseProvider.updateBio(bioTextController.text);

    // Reload the user
    await loadUser();

    // Finished loading
    setState(() {
      _isLoading = false;
    });
  }

  // BUILD UI
  @override
  Widget build(BuildContext context) {
    //get user post
    final allUserPosts = listeningProvider.filterUserPosts(widget.uid);

    // SCAFFOLD
    return Scaffold(
        backgroundColor: Theme.of(context).colorScheme.surface,
        // APP BAR
        appBar: AppBar(
          centerTitle: true,
          title: Text(_isLoading ? '' : user!.name),
          foregroundColor: Color(0xFF6D9886),
        ),

        // BODY
        body: ListView(
          children: [
            // username handle
            Center(
              child: Text(
                _isLoading ? '' : '@${user!.username}',
                style: TextStyle(color: Theme.of(context).colorScheme.primary),
              ),
            ),

            const SizedBox(height: 25),

            // profile picture
            Center(
              child: Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.secondary,
                  borderRadius: BorderRadius.circular(25),
                ),
                padding: const EdgeInsets.all(25),
                child: Icon(
                  Icons.person,
                  size: 72,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ),

            const SizedBox(height: 25),
            // profile stats

            // edit bio
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  //text
                  Text(
                    "Bio",
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),

                  //button
                  //only show button if its current user page
                  if (user != null && user!.uid == currentUserId)
                    GestureDetector(
                      onTap: _showEditBioBox,
                      child: Icon(
                        Icons.edit,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    )
                ],
              ),
            ),

            const SizedBox(height: 10),

            // bio box
            MyBioBox(text: _isLoading ? '...' : user!.bio),

            Padding(
              padding: const EdgeInsets.only(left: 25.0, top: 25),
              child: Text(
                "Posts",
                style: TextStyle(
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ),

            // list of posts from user
            allUserPosts.isEmpty
                ?

                //user post is empty
                const Center(
                    child: Text("No posts yet."),
                  )
                :

                //user post in Not empty
                ListView.builder(
                    itemCount: allUserPosts.length,
                    physics: const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemBuilder: (context, index) {
                      //get individual post
                      final post = allUserPosts[index];

                      //return tile UI
                      return MyPostTile(
                        post: post,
                        onUserTap: () {},
                        onPostTap: () => goPostPage(context, post),
                      );
                    },
                  ),
          ],
        ));
  }
}
