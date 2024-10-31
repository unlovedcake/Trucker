/*
Blocked users page

this page displays a list of users that have been blocked
- u can unblock users here
*/

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:trucker/services/database/database_provider.dart';

class BlockedUsersPage extends StatefulWidget {
  const BlockedUsersPage({super.key});

  @override
  State<BlockedUsersPage> createState() => _BlockedUsersPageState();
}

class _BlockedUsersPageState extends State<BlockedUsersPage> {
  //providers
  late final listeningProvider = Provider.of<DatabaseProvider>(context);
  late final databaseProvider =
      Provider.of<DatabaseProvider>(context, listen: false);

  //on startup,
  @override
  void initState() {
    super.initState();

    //load blocked users
    loadBlockedUsers();
  }

  //load blocked users
  Future<void> loadBlockedUsers() async {
    await databaseProvider.loadBlockedUsers();
  }

  //show confirm unblock box
  void _showUnblockConfirmationBox(String userId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Unblock User"),
        content: const Text("Are you sure you want to unblock this user?"),
        actions: [
          //cancel button
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),

          //unblock button
          TextButton(
            onPressed: () async {
              //report user
              await databaseProvider.unblockUser(userId);

              //close box
              Navigator.pop(context);

              //let user know it was successfully reported
              ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("User unblocked!")));
            },
            child: const Text("Unblock"),
          ),
        ],
      ),
    );
  }

  //Build UI
  @override
  Widget build(BuildContext context) {
    //listen to blocked users
    final blockedUsers = listeningProvider.blockedUsers;

    //Scafflod
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,

      //appbar
      appBar: AppBar(
        title: const Text("Blocked Users"),
        foregroundColor: Theme.of(context).colorScheme.primary,
      ),

      //body
      body: blockedUsers.isEmpty
          ? const Center(
              child: Text("No blocked users"),
            )
          : ListView.builder(
              itemCount: blockedUsers.length,
              itemBuilder: (context, index) {
                //get each user
                final user = blockedUsers[index];

                //return as a ListTile UI
                return ListTile(
                  title: Text(user.name),
                  subtitle: Text('@${user.username}'),
                  trailing: IconButton(
                    icon: const Icon(Icons.block),
                    onPressed: () => _showUnblockConfirmationBox(user.uid),
                  ),
                );
              },
            ),
    );
  }
}
