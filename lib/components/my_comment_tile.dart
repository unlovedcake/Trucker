/*
Comment tile

This is the comment tile widget which belongs below a post. Its similar to the post tile widget,
but lets make the comments look slighty different to posts.

--------------------------------------------------------------------

To use this widget u need:

- the comment
-a function (for when the user taps and wants to go to the user profile 
of this comment)
*/

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:trucker/services/database/database_provider.dart';

import '../models/comment.dart';
import '../services/auth/auth_service.dart';

class MyCommentTile extends StatelessWidget {
  final Comment comment;
  final void Function()? onUserTap;

  const MyCommentTile({
    super.key,
    required this.comment,
    required this.onUserTap,
  });

  //show options for comment
  void _showOptions(BuildContext context) {
    //check if this comment is owned by the user or not
    String currentUid = AuthService().getCurrentUid();
    final bool isOwnComment = comment.uid == currentUid;

    //show options
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Wrap(
            children: [
              //this comment belongs to current user
              if (isOwnComment)

                //delete comment button
                ListTile(
                  leading: const Icon(Icons.delete),
                  title: const Text("Delete"),
                  onTap: () async {
                    //pop option box
                    Navigator.pop(context);

                    //handle delete action
                    await Provider.of<DatabaseProvider>(context, listen: false)
                        .deleteComment(comment.id, comment.postId);
                  },
                )

              //this comment does not belong to current user
              else ...[
                //report comment button
                ListTile(
                  leading: const Icon(Icons.flag),
                  title: const Text("Report"),
                  onTap: () {
                    //pop option box
                    Navigator.pop(context);

                    //handle report action
                  },
                ),

                //block user button
                ListTile(
                  leading: const Icon(Icons.block),
                  title: const Text("Block User"),
                  onTap: () {
                    //pop option box
                    Navigator.pop(context);

                    //handle block action
                  },
                )
              ],

              //cancel button
              ListTile(
                leading: const Icon(Icons.cancel),
                title: const Text("Cancel"),
                onTap: () => Navigator.pop(context),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      //padding outside
      margin: const EdgeInsets.symmetric(horizontal: 25, vertical: 5),

      //padding inside
      padding: const EdgeInsets.all(20),

      decoration: BoxDecoration(
        // color of the post tile
        color: Theme.of(context).colorScheme.tertiary,

        //curve corners
        borderRadius: BorderRadius.circular(8),
      ),

      //column
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          //top section: profile pic / name / username
          GestureDetector(
            onTap: onUserTap,
            child: Row(
              children: [
                // profile pic
                Icon(
                  Icons.person,
                  color: Theme.of(context).colorScheme.primary,
                ),

                const SizedBox(width: 10),

                // name
                Text(
                  comment.name,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),

                const SizedBox(width: 5),

                //username handle
                Text(
                  '@${comment.username}',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.secondary,
                  ),
                ),

                const Spacer(),

                //buttons -> more options: delete
                GestureDetector(
                  onTap: () => _showOptions(context),
                  child: Icon(
                    Icons.more_horiz,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          //message
          Text(
            comment.message,
            style: TextStyle(
              color: Theme.of(context).colorScheme.inversePrimary,
            ),
          ),
        ],
      ),
    );
  }
}
