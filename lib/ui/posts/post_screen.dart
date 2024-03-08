import 'package:fire_app/ui/auth/login_screen.dart';
import 'package:fire_app/utils/utils.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class PostScreen extends StatefulWidget {
  const PostScreen({super.key});

  @override
  State<PostScreen> createState() => _PostScreenState();
}

final auth = FirebaseAuth.instance;

class _PostScreenState extends State<PostScreen> {
  Widget userAccess = Text(auth.currentUser!.email.toString());

  @override
  Widget build(BuildContext context) {
    if (auth.currentUser!.email == null) {
      setState(() {
        userAccess = Text(auth.currentUser!.phoneNumber.toString());
      });
    }

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text("Posts"),
        leading: null,
        actions: [
          IconButton(
              onPressed: () {
                auth.signOut().then((value) {
                  Utils().showMessage(context, "Sorry to see you go.",
                      Theme.of(context).colorScheme.secondary);
                  Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const LoginScreen()));
                }).onError((error, stackTrace) {
                  Utils().showMessage(context, "Unable to logout.",
                      Theme.of(context).colorScheme.error.withOpacity(0.75));
                });
              },
              icon: const Icon(Icons.logout_rounded)),
        ],
      ),
      body: Center(
        child: userAccess,
      ),
    );
  }
}
