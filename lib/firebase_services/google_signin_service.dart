// ignore_for_file: use_build_context_synchronously

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fire_app/ui/posts/post_screen.dart';
import 'package:fire_app/utils/utils.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

class GoogleSignInSerice {
  void signInWithGoogle(BuildContext context) async {
    FirebaseAuth auth = FirebaseAuth.instance;
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    try {
      GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

      GoogleSignInAuthentication? googleAuth = await googleUser!.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      UserCredential userCredential =
          await auth.signInWithCredential(credential);

      firestore.collection("Users").doc(auth.currentUser!.uid).set({
        'uid': auth.currentUser!.uid,
        'username': userCredential.user!.displayName.toString(),
        'email': userCredential.user!.email.toString(),
      });

      Utils().showMessage(
          context,
          "${userCredential.user!.displayName} logged in successfully",
          Theme.of(context).colorScheme.secondary);

      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => const PostScreen()));
    } catch (e) {
      Utils().showMessage(
          context, e.toString(), Theme.of(context).colorScheme.error);
    }
  }
}
