import 'package:chat_app/delete/fetch_data.dart';
import 'package:chat_app/delete/firebase_services.dart';
import 'package:chat_app/delete/show_data.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class PracticePage extends StatefulWidget {
  const PracticePage({super.key});

  @override
  State<PracticePage> createState() => _PracticePageState();
}

class _PracticePageState extends State<PracticePage> {
  final _nameController = TextEditingController();
  final _ageController = TextEditingController();
  final _classController = TextEditingController();
  FirebaseServices _firebaseServices = FirebaseServices();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.pink,
        title: Text('Firebase Task',style: TextStyle(color: Colors.white),),
        actions: [
          IconButton(onPressed: (){
            Navigator.push(context, MaterialPageRoute(builder: (context) => ShowDataScreen(),));
          }, icon: Icon(Icons.person,color: Colors.white,))
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 16,vertical: 10),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            TextFormField(
              controller: _nameController,
              decoration: InputDecoration(
                hintText: 'Your name',
                border: OutlineInputBorder(

                )
              ),
            ),
            SizedBox(height: 10,),
            TextFormField(
              controller: _ageController,
              decoration: InputDecoration(
                  hintText: 'Your age',
                  border: OutlineInputBorder(

                  )
              ),
            ),
            SizedBox(height: 10,),
            TextFormField(
              controller: _classController,
              decoration: InputDecoration(
                  hintText: 'Your class',
                  border: OutlineInputBorder(

                  )
              ),
            ),
            SizedBox(height: 40,),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.pink,

              ),
                onPressed: () async{
                try{
                  _firebaseServices.postData(_nameController.text, _ageController.text, _classController.text,context);
                }catch(e){
                 print(e);
                }
                // try{
                //   await FirebaseFirestore.instance.collection('parentColl').doc('parentDocId').collection('nestedColl').add({
                //     "name": _nameController.text,
                //     "age": _ageController.text,
                //     "class": _classController.text,
                //   });
                //   _nameController.clear();
                //   _ageController.clear();
                //   _classController.clear();
                //   ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Data added successful')));
                // }catch(e){
                //   ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
                // }
                },
                child: Text('Add Data',style: TextStyle(color: Colors.white),),
            ),
          ],
        ),
      ),
    );
  }
}
