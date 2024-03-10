import 'package:fire_app/utils/utils.dart';
import 'package:fire_app/widgets/round_button.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

class AddPost extends StatefulWidget {
  const AddPost({super.key});

  @override
  State<AddPost> createState() => _AddPostState();
}

class _AddPostState extends State<AddPost> {
  bool loading = false;
  final GlobalKey<FormState> formKey = GlobalKey();
  final postController = TextEditingController();

  final database = FirebaseDatabase.instance;
  final auth = FirebaseAuth.instance;

  void addPost(String desc) {
    setState(() {
      loading = true;
    });
    String? user;
    if (auth.currentUser!.email != null) {
      user = auth.currentUser!.email!.split('@')[0];
    } else {
      user = auth.currentUser!.phoneNumber;
    }

    if (formKey.currentState!.validate()) {
      try {
        database
            .ref('Posts')
            .child(user!)
            .child(DateTime.now().millisecondsSinceEpoch.toString())
            .set({
          'desc': desc,
        }).then((value) {
          Utils().showMessage(context, "What a nice thought. 😉",
              Theme.of(context).colorScheme.secondary);

          setState(() {
            loading = false;
            postController.clear();
          });
        }).onError((error, stackTrace) {
          Utils().showMessage(
              context, error.toString(), Theme.of(context).colorScheme.error);
          setState(() {
            loading = false;
          });
        });
      } catch (e) {
        Utils().showMessage(
            context,
            "Sorry. We can't post your thoughts at the moment. 🤕",
            Theme.of(context).colorScheme.error);
        setState(() {
          loading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text("Add Post"),
      ),
      body: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: [
            Form(
              key: formKey,
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  TextFormField(
                    maxLines: 5,
                    controller: postController,
                    decoration: const InputDecoration(
                      hintText: "What's on your mind?",
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(20))),
                    ),
                  ),
                  const SizedBox(height: 20),
                  RoundButton(
                    loading: loading,
                    title: "Post",
                    onTap: () {
                      addPost(postController.text);
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
