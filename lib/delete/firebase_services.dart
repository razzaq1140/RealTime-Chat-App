import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class FirebaseServices{

  Future<void> signUp(BuildContext context, String email, String password) async{
    try{
      await FirebaseAuth.instance.createUserWithEmailAndPassword(email: email, password: password);
    }on FirebaseException catch(e){
      throw e;
    }
  }

  Future<void> login(BuildContext context, String email, String password) async{
    try{
      await FirebaseAuth.instance.signInWithEmailAndPassword(email: email, password: password);
    }on FirebaseException catch(e){
      throw e;
    }
  }

  Future<void> postData(String name, String age, String myClass, BuildContext context) async{
    final uid = FirebaseAuth.instance.currentUser!.uid;
    await FirebaseFirestore.instance.collection("posts").add({
      "uid": uid,
      "name": name,
      "age": age,
      "myClass": myClass,
    }).then((value){
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Data save successful')));
    }).onError((error, stackTrace) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('This issue of Data: $error')));
    },);
  }
}