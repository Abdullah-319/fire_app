// ignore_for_file: use_build_context_synchronously

import 'package:fire_app/ui/posts/post_screen.dart';
import 'package:fire_app/utils/utils.dart';
import 'package:fire_app/widgets/round_button.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class VerifyPhone extends StatefulWidget {
  const VerifyPhone({super.key, required this.verificationId});

  final String verificationId;

  @override
  State<VerifyPhone> createState() => _VerifyPhoneState();
}

class _VerifyPhoneState extends State<VerifyPhone> {
  bool loading = false;
  final verifyCodeController = TextEditingController();
  final auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text("Verify phone"),
      ),
      body: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextFormField(
              controller: verifyCodeController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                hintText: "6-digit code",
              ),
            ),
            const SizedBox(height: 50),
            RoundButton(
              loading: loading,
              title: "Verify",
              onTap: () async {
                setState(() {
                  loading = true;
                });
                final credential = PhoneAuthProvider.credential(
                    verificationId: widget.verificationId,
                    smsCode: verifyCodeController.text);

                try {
                  await auth.signInWithCredential(credential);
                  setState(() {
                    loading = false;
                  });
                  Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const PostScreen()));
                } catch (e) {
                  setState(() {
                    loading = false;
                  });
                  Utils().showMessage(context, e.toString(),
                      Theme.of(context).colorScheme.error.withOpacity(0.75));
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
