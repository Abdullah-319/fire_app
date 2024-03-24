import 'package:fire_app/utils/utils.dart';
import 'package:fire_app/widgets/round_button.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  bool loading = false;

  final auth = FirebaseAuth.instance;

  final forgotPassController = TextEditingController();
  final forgotPassKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Forgot Password'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: SizedBox(
            height: MediaQuery.of(context).size.height * 0.88,
            width: MediaQuery.of(context).size.width,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextFormField(
                  key: forgotPassKey,
                  controller: forgotPassController,
                  validator: (value) {
                    if (value!.trim().isEmpty) {
                      return "Enter your emal addreess";
                    }
                    return null;
                  },
                  decoration: const InputDecoration(
                    hintText: "Your Email Address",
                  ),
                ),
                const SizedBox(height: 50),
                RoundButton(
                  title: "Forgot",
                  loading: loading,
                  onTap: () {
                    sendVerificationEmail(forgotPassController.text.toString());
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void sendVerificationEmail(String email) {
    if (forgotPassController.text.trim().isNotEmpty) {
      setState(() {
        loading = true;
      });
      auth.sendPasswordResetEmail(email: email).then((value) {
        Utils().showMessage(
            context,
            "We've sent you email to recover password, please check your inbox",
            Theme.of(context).colorScheme.secondary);
        setState(() {
          loading = false;
        });
        Navigator.pop(context);
      }).onError((error, stackTrace) {
        Utils().showMessage(
            context, error.toString(), Theme.of(context).colorScheme.error);
        setState(() {
          loading = false;
        });
      });
    } else {
      Utils().showMessage(context, "Enter your email addrress",
          Theme.of(context).colorScheme.error);
      setState(() {
        loading = false;
      });
    }
  }
}
