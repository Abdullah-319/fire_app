// ignore_for_file: use_build_context_synchronously

import 'dart:io';

import 'package:fire_app/utils/utils.dart';
import 'package:fire_app/widgets/round_button.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class AddPost extends StatefulWidget {
  const AddPost({super.key});

  @override
  State<AddPost> createState() => _AddPostState();
}

class _AddPostState extends State<AddPost> {
  bool loading = false;

  final thoughtKey = GlobalKey<FormState>();
  final postController = TextEditingController();

  final database = FirebaseDatabase.instance;
  final auth = FirebaseAuth.instance;

  File? image;
  final imagePicker = ImagePicker();

  Future pickGalleryImage() async {
    final pickedImage =
        await imagePicker.pickImage(source: ImageSource.gallery);

    setState(() {
      if (pickedImage != null) {
        image = File(pickedImage.path);
        Utils().showMessage(
            context, "Image picked", Theme.of(context).colorScheme.secondary);
      } else {
        Utils().showMessage(context, "No image was picked",
            Theme.of(context).colorScheme.error);
      }
    });
  }

  void addPost(String desc) {
    if (image != null) {
      if (thoughtKey.currentState!.validate()) {
        try {
          setState(() {
            loading = true;
          });
          // DateTime now = DateTime.now();
          // String formattedDate =
          //     DateFormat('yyyy-MM-dd – kk:mm:ss:ms').format(now);
          final id = DateTime.now().microsecondsSinceEpoch.toString();

          database.ref('Posts').child(id).set({
            'id': id,
            'user': auth.currentUser?.email ?? auth.currentUser!.phoneNumber,
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
    } else {
      Utils().showMessage(
          context, "Please select image", Theme.of(context).colorScheme.error);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text("Add Post"),
      ),
      body: SingleChildScrollView(
        child: Container(
          height: MediaQuery.of(context).size.height * 0.8,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              Column(
                children: [
                  const SizedBox(height: 20),
                  InkWell(
                    onTap: () {
                      setState(() {
                        pickGalleryImage();
                      });
                    },
                    child: Container(
                      height: MediaQuery.of(context).size.width * 0.85,
                      width: MediaQuery.of(context).size.width * 0.85,
                      decoration: BoxDecoration(
                        border: Border.all(),
                      ),
                      child: image != null
                          ? Image.file(
                              image!.absolute,
                              fit: BoxFit.cover,
                            )
                          : Icon(
                              Icons.add_a_photo_rounded,
                              color: Theme.of(context)
                                  .colorScheme
                                  .primary
                                  .withOpacity(0.6),
                            ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Form(
                    key: thoughtKey,
                    child: TextFormField(
                      validator: (value) {
                        if (value!.trim().isEmpty) {
                          return 'Enter your thoughts';
                        }
                        return null;
                      },
                      maxLines: 2,
                      controller: postController,
                      decoration: const InputDecoration(
                        hintText: "What's on your mind?",
                        border: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(20))),
                      ),
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
            ],
          ),
        ),
      ),
    );
  }
}
