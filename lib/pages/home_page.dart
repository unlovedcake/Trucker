import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:trucker/components/my_drawer.dart';
import 'package:trucker/components/my_input_alert_box.dart';
import 'package:trucker/components/my_post_tile.dart';
import 'package:trucker/helper/navigate_pages.dart';
import 'package:trucker/models/post.dart';
import 'package:trucker/services/database/database_provider.dart';

/*

HOME PAGE

This is the main page of the app : It displays a list of all posts.

 */
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // providers
  late final listeningProvider = Provider.of<DatabaseProvider>(context);
  late final databaseProvider =
      Provider.of<DatabaseProvider>(context, listen: false);

  // text controllers
  final _messageController = TextEditingController();

  // on startup,
  @override
  void initState() {
    super.initState();

    // let's load all post
    loadAllPosts();
  }

  Future<void> loadAllPosts() async {
    await databaseProvider.loadAllPosts();
  }

  // show post message dialog box
  void _openPostMessageBox() {
    showDialog(
      context: context,
      builder: (context) => MyInputAlertBox(
          textController: _messageController,
          hintText: "What's on your mind",
          onPressed: () async {
            // post in db
            await postMessage(_messageController.text);
          },
          onPressedText: "Post"),
    );
  }

  // Users wants to post a message
  Future<void> postMessage(String message) async {
    await databaseProvider.postMessage(message);
  }

  // BUILD UI
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      drawer: MyDrawer(),

      //APP BAR
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          "T R U C K E R",
          style: TextStyle(
            color: Color(0xFF6D9886),
          ),
        ),
        foregroundColor: Theme.of(context).colorScheme.primary,
      ),

      // Floating Action Button
      floatingActionButton: FloatingActionButton(
        onPressed: _openPostMessageBox,
        backgroundColor: Color(0xFF6D9886),
        child: Icon(
          Icons.add,
          size: 25,
          color: Theme.of(context).colorScheme.secondary,
        ),
      ),

      // Body: List of all posts
      body: _buildPostList(listeningProvider.allPosts),
    );
  }

  // build list UI given a list of posts
  Widget _buildPostList(List<Post> posts) {
    return posts.isEmpty
        ?
        // post list is empty
        const Center(
            child: Text("Nothing here..."),
          )
        :
        // post list is NOT empty
        ListView.builder(
            itemCount: posts.length,
            itemBuilder: (context, index) {
              // get each individual post
              final post = posts[index];

              // return Post Tile UI
              return MyPostTile(
                post: post,
                onUserTap: () => goUserPage(context, post.uid),
                onPostTap: () => goPostPage(context, post),
              );
            },
          );
  }
}
