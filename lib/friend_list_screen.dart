import 'package:chat_app/chat_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class FriendsListTab extends StatelessWidget {
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestore
          .collection('friends')
          .where('user1', isEqualTo: _auth.currentUser!.uid)
          .where('status', isEqualTo: 'accepted')
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.data!.docs.isEmpty) {
          return const Center(child: Text('No friends yet. Find friends to chat with!'));
        }

        return ListView.builder(
          itemCount: snapshot.data!.docs.length,
          itemBuilder: (context, index) {
            final doc = snapshot.data!.docs[index];
            final data = doc.data() as Map<String, dynamic>;

            return FutureBuilder<DocumentSnapshot>(
              future: _firestore.collection('users').doc(data['user2']).get(),
              builder: (context, userSnapshot) {
                if (!userSnapshot.hasData) {
                  return const ListTile(title: Text('Loading...'));
                }

                final userData = userSnapshot.data!.data() as Map<String, dynamic>;

                return ListTile(
                  leading: CircleAvatar(
                    child: Text(userData['name']?.substring(0, 1) ?? '?'),
                  ),
                  title: Text(userData['name'] ?? 'Unknown'),
                  subtitle: StreamBuilder<QuerySnapshot>(
                    stream: _firestore
                        .collection('messages')
                        .where('senderId', isEqualTo: data['user2'])
                        .where('receiverId', isEqualTo: _auth.currentUser!.uid)
                        .orderBy('timestamp', descending: true)
                        .limit(1)
                        .snapshots(),
                    builder: (context, messageSnapshot) {
                      if (messageSnapshot.hasData && messageSnapshot.data!.docs.isNotEmpty) {
                        final lastMessage = messageSnapshot.data!.docs.first.data() as Map<String, dynamic>;
                        return Text(
                          lastMessage['message'],
                          overflow: TextOverflow.ellipsis,
                        );
                      }
                      return const Text('No messages yet');
                    },
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ChatScreen(friendId: data['user2']),
                      ),
                    );
                  },
                );
              },
            );
          },
        );
      },
    );
  }
}

// Friend Requests Tab
class FriendRequestsTab extends StatelessWidget {
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestore
          .collection('friend_requests')
          .where('receiverId', isEqualTo: _auth.currentUser!.uid)
          .where('status', isEqualTo: 'pending')
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.data!.docs.isEmpty) {
          return const Center(child: Text('No pending friend requests'));
        }

        return ListView.builder(
          itemCount: snapshot.data!.docs.length,
          itemBuilder: (context, index) {
            final doc = snapshot.data!.docs[index];
            final data = doc.data() as Map<String, dynamic>;

            return FutureBuilder<DocumentSnapshot>(
              future: _firestore.collection('users').doc(data['senderId']).get(),
              builder: (context, userSnapshot) {
                if (!userSnapshot.hasData) {
                  return const ListTile(title: Text('Loading...'));
                }

                final userData = userSnapshot.data!.data() as Map<String, dynamic>;

                return ListTile(
                  leading: CircleAvatar(
                    child: Text(userData['name']?.substring(0, 1) ?? '?'),
                  ),
                  title: Text(userData['name'] ?? 'Unknown'),
                  subtitle: const Text('Wants to be your friend'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.check, color: Colors.green),
                        onPressed: () async {
                          // Accept friend request
                          await _firestore.runTransaction((transaction) async {
                            // Update request status
                            transaction.update(doc.reference, {'status': 'accepted'});

                            // Create friendship in both directions
                            transaction.set(
                              _firestore.collection('friends').doc(),
                              {
                                'user1': _auth.currentUser!.uid,
                                'user2': data['senderId'],
                                'status': 'accepted',
                                'createdAt': FieldValue.serverTimestamp(),
                              },
                            );

                            transaction.set(
                              _firestore.collection('friends').doc(),
                              {
                                'user1': data['senderId'],
                                'user2': _auth.currentUser!.uid,
                                'status': 'accepted',
                                'createdAt': FieldValue.serverTimestamp(),
                              },
                            );
                          });

                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Friend request accepted')),
                          );
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.red),
                        onPressed: () async {
                          await doc.reference.update({'status': 'rejected'});
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Friend request rejected')),
                          );
                        },
                      ),
                    ],
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}