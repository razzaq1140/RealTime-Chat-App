import 'package:chat_app/delete/firebase_services.dart';
import 'package:chat_app/delete/practice.dart';
import 'package:flutter/material.dart';

class AuthScreens extends StatefulWidget {
  const AuthScreens({super.key});

  @override
  State<AuthScreens> createState() => _AuthScreensState();
}

class _AuthScreensState extends State<AuthScreens> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();
  FirebaseServices authServices = FirebaseServices();
  bool isLogin = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.pink,
        title: Text(
          'Authentication screen',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            if (!isLogin)
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(labelText: 'name'),
              ),

            SizedBox(height: 12),
            TextFormField(
              controller: _emailController,
              decoration: InputDecoration(labelText: 'email'),
            ),
            SizedBox(height: 12),
            TextFormField(
              controller: _passwordController,
              decoration: InputDecoration(labelText: 'password'),
            ),
            SizedBox(height: 30),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.pink),
              onPressed: () {
                if(isLogin){
                  authServices.login(context, _emailController.text, _passwordController.text).then((value){
                    Navigator.push(context, MaterialPageRoute(builder: (context) => PracticePage(),));
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Login successful')));
                  }).onError((error, stackTrace){
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $error')));
                  });
                }else{
                  authServices.signUp(context, _emailController.text, _passwordController.text).then((value){
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('SingUp successful')));
                  }).onError((error, stackTrace){
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $error')));
                  });
                }
              },
              child: Text(isLogin ? 'Login' : "SignUp ", style: TextStyle(color: Colors.white)),
            ),
            SizedBox(height: 15,),
            TextButton(onPressed: (){
              isLogin = !isLogin;
              setState(() {

              });
            }, child: Text(isLogin ? 'Create new account' : 'Already have an accunt',style: TextStyle(color: Colors.pink),)),
          ],
        ),
      ),
    );
  }
}
