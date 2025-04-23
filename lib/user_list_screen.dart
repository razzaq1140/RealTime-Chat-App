import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class UsersListTab extends StatelessWidget {
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;

  void _sendFriendRequest(String receiverId, String? receiverName, BuildContext context) async {
    // Check if request already exists
    var existingRequest = await _firestore
        .collection('friend_requests')
        .where('senderId', isEqualTo: _auth.currentUser!.uid)
        .where('receiverId', isEqualTo: receiverId)
        .where('status', whereIn: ['pending', 'accepted'])
        .get();

    if (existingRequest.docs.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Friend request already sent or accepted')),
      );
      return;
    }

    await _firestore.collection('friend_requests').add({
      'senderId': _auth.currentUser!.uid,
      'senderName': _auth.currentUser!.displayName ?? 'Unknown',
      'receiverId': receiverId,
      'receiverName': receiverName ?? 'Unknown',
      'status': 'pending',
      'timestamp': FieldValue.serverTimestamp(),
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Friend request sent')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestore.collection('users').snapshots(),
      builder: (context, userSnapshot) {
        if (!userSnapshot.hasData) return const Center(child: CircularProgressIndicator());

        return StreamBuilder<QuerySnapshot>(
          stream: _firestore
              .collection('friends')
              .where('user1', isEqualTo: _auth.currentUser!.uid)
              .where('status', isEqualTo: 'accepted')
              .snapshots(),
          builder: (context, friendSnapshot) {
            if (!friendSnapshot.hasData) return const Center(child: CircularProgressIndicator());

            // Get list of already friends
            var friendIds = friendSnapshot.data!.docs.map((doc) =>
            (doc.data() as Map<String, dynamic>)['user2']).toList();

            // Get list of pending requests
            return StreamBuilder<QuerySnapshot>(
              stream: _firestore
                  .collection('friend_requests')
                  .where('senderId', isEqualTo: _auth.currentUser!.uid)
                  .where('status', isEqualTo: 'pending')
                  .snapshots(),
              builder: (context, requestSnapshot) {
                if (!requestSnapshot.hasData) return const Center(child: CircularProgressIndicator());

                var pendingRequestIds = requestSnapshot.data!.docs.map((doc) =>
                (doc.data() as Map<String, dynamic>)['receiverId']).toList();

                return ListView(
                  children: userSnapshot.data!.docs.where((doc) {
                    return doc.id != _auth.currentUser!.uid &&
                        !friendIds.contains(doc.id);
                  }).map((doc) {
                    final data = doc.data() as Map<String, dynamic>;
                    bool isPending = pendingRequestIds.contains(doc.id);

                    return ListTile(
                      leading: CircleAvatar(
                        child: Text(data['name']?.substring(0, 1) ?? '?'),
                      ),
                      title: Text(data['name'] ?? 'Unknown'),
                      subtitle: Text(data['email'] ?? 'No email'),
                      trailing: isPending
                          ? const Text('Request Sent', style: TextStyle(color: Colors.grey))
                          : ElevatedButton(
                        onPressed: () => _sendFriendRequest(
                          doc.id,
                          data['name'],
                          context,
                        ),
                        child: const Text('Add Friend'),
                      ),
                    );
                  }).toList(),
                );
              },
            );
          },
        );
      },
    );
  }
}