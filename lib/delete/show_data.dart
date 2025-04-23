import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ShowDataScreen extends StatefulWidget {
  const ShowDataScreen({super.key});

  @override
  State<ShowDataScreen> createState() => _ShowDataScreenState();
}

class _ShowDataScreenState extends State<ShowDataScreen> {
  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    print("Current UID: $uid"); // Debug UID
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.pink,
        title: Text('Fetch data any user', style: TextStyle(color:  Colors.white),),
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance.collection('posts').where('uid', isEqualTo: uid).snapshots(),
        builder: (context, snapshot) {
          if(snapshot.connectionState == ConnectionState.waiting){
            return Center(child: CircularProgressIndicator(),);
          }
          if(!snapshot.hasData || snapshot.data!.docs.isEmpty){
            return Center(child: Text("No posts found"));
          }
          final posts = snapshot.data!.docs.toList();
        return ListView.builder(
          itemCount: posts.length,
          itemBuilder: (context, index) {
            final post = posts[index];
            return ListTile(
              title: Text(post['name'],),
              subtitle: Text(post['age'],),
            );
        },);
      },),
    );
  }
}
