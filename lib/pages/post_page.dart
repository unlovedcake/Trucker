/*

Post page

This page displays:
-individual post
-comments on this post

 */
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:trucker/components/my_comment_tile.dart';
import 'package:trucker/components/my_post_tile.dart';
import 'package:trucker/helper/navigate_pages.dart';
import 'package:trucker/services/database/database_provider.dart';

import '../models/post.dart';

class PostPage extends StatefulWidget {
  final Post post;

  const PostPage({
    super.key,
    required this.post,
  });

  @override
  State<PostPage> createState() => _PostPageState();
}

class _PostPageState extends State<PostPage> {
  //providers
  late final listeningProvider = Provider.of<DatabaseProvider>(context);
  late final databaseProvider =
      Provider.of<DatabaseProvider>(context, listen: false);

  //BUILD UI
  @override
  Widget build(BuildContext context) {
    //listen to all comments for this post
    final allComments = listeningProvider.getComments(widget.post.id);

    //scaffold
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,

      //App Bar
      appBar: AppBar(
        foregroundColor: Theme.of(context).colorScheme.primary,
      ),

      //body
      body: ListView(
        children: [
          //post
          MyPostTile(
              post: widget.post,
              onUserTap: () => goUserPage(context, widget.post.uid),
              onPostTap: () {}),

          //comments on this post
          allComments.isEmpty
              ?
              //no comment yet..
              const Center(
                  child: Text("No comments yet"),
                )
              :

              //comments exist
              ListView.builder(
                  itemCount: allComments.length,
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemBuilder: (context, index) {
                    //get each comment
                    final comment = allComments[index];

                    //return as comment tile UI
                    return MyCommentTile(
                      comment: comment,
                      onUserTap: () => goUserPage(context, comment.uid),
                    );
                  },
                )
        ],
      ),
    );
  }
}
