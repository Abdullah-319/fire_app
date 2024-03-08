import 'package:fire_app/ui/auth/verify_phone.dart';
import 'package:fire_app/utils/utils.dart';
import 'package:fire_app/widgets/round_button.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class LoginWithPhone extends StatefulWidget {
  const LoginWithPhone({super.key});

  @override
  State<LoginWithPhone> createState() => _LoginWithPhoneState();
}

class _LoginWithPhoneState extends State<LoginWithPhone> {
  bool loading = false;
  final phoneNumberController = TextEditingController();
  final auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text("Login with phone"),
      ),
      body: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextFormField(
              controller: phoneNumberController,
              keyboardType: TextInputType.text,
              decoration: const InputDecoration(
                hintText: "+92 000 0000000",
              ),
            ),
            const SizedBox(height: 50),
            RoundButton(
              loading: loading,
              title: "Login",
              onTap: () {
                setState(() {
                  loading = true;
                });
                if (phoneNumberController.text.trim().isNotEmpty) {
                  auth.verifyPhoneNumber(
                    phoneNumber: phoneNumberController.text,
                    verificationCompleted: (_) {
                      setState(() {
                        loading = false;
                      });
                      Utils().showMessage(context, "Logged in successfully.",
                          Theme.of(context).colorScheme.secondary);
                    },
                    verificationFailed: (e) {
                      Utils().showMessage(
                          context,
                          e.toString(),
                          Theme.of(context)
                              .colorScheme
                              .error
                              .withOpacity(0.75));
                      setState(() {
                        loading = false;
                      });
                    },
                    codeSent: (verificationId, forceResendingToken) {
                      setState(() {
                        loading = false;
                      });
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => VerifyPhone(
                                    verificationId: verificationId,
                                  )));
                    },
                    codeAutoRetrievalTimeout: (e) {
                      Utils().showMessage(
                          context,
                          e.toString(),
                          Theme.of(context)
                              .colorScheme
                              .error
                              .withOpacity(0.75));
                      setState(() {
                        loading = false;
                      });
                    },
                  );
                } else {
                  setState(() {
                    loading = false;
                  });
                  Utils().showMessage(context, "Enter your phone number.",
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