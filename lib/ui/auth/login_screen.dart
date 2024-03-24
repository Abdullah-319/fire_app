import 'package:fire_app/firebase_services/google_signin_service.dart';
import 'package:fire_app/ui/auth/forgot_password.dart';
import 'package:fire_app/ui/auth/login_with_phone.dart';
import 'package:fire_app/ui/auth/signup_screen.dart';
import 'package:fire_app/ui/posts/post_screen.dart';
import 'package:fire_app/utils/utils.dart';
import 'package:fire_app/widgets/round_button.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool loading = false;
  bool obsecurePass = true;
  final formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  final auth = FirebaseAuth.instance;

  @override
  void dispose() {
    super.dispose();
    emailController.dispose();
    passwordController.dispose();
  }

  void login(String email, String password) {
    if (formKey.currentState!.validate()) {
      setState(() {
        loading = true;
      });
      auth
          .signInWithEmailAndPassword(email: email, password: password)
          .then((value) {
        setState(() {
          loading = false;
          passwordController.clear();
        });
        Utils().showMessage(
            context,
            "${value.user!.email} logged in successfully",
            Theme.of(context).colorScheme.secondary);
        Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => const PostScreen(),
            ));
      }).onError((error, stackTrace) {
        setState(() {
          loading = false;
          emailController.clear();
          passwordController.clear();
        });
        Utils().showMessage(
            context, error.toString(), Theme.of(context).colorScheme.error);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Login"),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: SizedBox(
            width: double.infinity,
            height: MediaQuery.of(context).size.height * 0.88,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Form(
                  key: formKey,
                  child: Column(
                    children: [
                      TextFormField(
                        controller: emailController,
                        keyboardType: TextInputType.emailAddress,
                        validator: (value) {
                          if (value!.trim().isEmpty) {
                            return 'Enter email address';
                          }
                          return null;
                        },
                        decoration: const InputDecoration(
                          prefixIcon: Icon(
                            Icons.alternate_email,
                          ),
                          hintText: "Email",
                        ),
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        controller: passwordController,
                        keyboardType: TextInputType.text,
                        obscureText: obsecurePass,
                        validator: (value) {
                          if (value!.trim().isEmpty) {
                            return 'Enter password';
                          }
                          return null;
                        },
                        decoration: InputDecoration(
                          prefixIcon: const Icon(
                            Icons.password,
                          ),
                          suffixIcon: IconButton(
                            onPressed: () {
                              setState(() {
                                obsecurePass = !obsecurePass;
                              });
                            },
                            icon: Icon(
                              obsecurePass
                                  ? Icons.visibility_off_rounded
                                  : Icons.visibility_rounded,
                              size: 18,
                            ),
                          ),
                          hintText: "Password",
                        ),
                      ),
                      const SizedBox(height: 7),
                      Container(
                        alignment: Alignment.bottomRight,
                        child: InkWell(
                          onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        const ForgotPasswordScreen()));
                          },
                          child: Text(
                            'Forgot Password?',
                            style: TextStyle(
                              fontSize: 13,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
                RoundButton(
                  loading: loading,
                  title: "Login",
                  onTap: () {
                    try {
                      login(
                        emailController.text.toString(),
                        passwordController.text.toString(),
                      );
                    } catch (e) {
                      Utils().showMessage(context, e.toString(),
                          Theme.of(context).colorScheme.error);
                    }
                  },
                ),
                const SizedBox(height: 30),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Don't have an account?"),
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const SignupScreen()));
                      },
                      child: const Text("Sign up"),
                    ),
                  ],
                ),
                const SizedBox(height: 15),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    GestureDetector(
                      onTap: () {
                        GoogleSignInSerice().signInWithGoogle(context);
                      },
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: Colors.black,
                          ),
                          borderRadius: BorderRadius.circular(156465),
                        ),
                        child: Image.asset(
                          "assets/images/google.png",
                          height: 30,
                          width: 30,
                          filterQuality: FilterQuality.high,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    const SizedBox(
                      height: 30,
                      child: VerticalDivider(
                        color: Colors.black54,
                        thickness: 2,
                      ),
                    ),
                    const SizedBox(width: 10),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const LoginWithPhone()));
                      },
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: Colors.black,
                          ),
                          borderRadius: BorderRadius.circular(156465),
                        ),
                        child: const Icon(
                          Icons.call,
                          size: 30,
                          color: Colors.blueAccent,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
