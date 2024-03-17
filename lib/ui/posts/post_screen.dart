import 'package:fire_app/ui/auth/login_screen.dart';
import 'package:fire_app/ui/posts/add_post.dart';
import 'package:fire_app/utils/utils.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
// import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

class PostScreen extends StatefulWidget {
  const PostScreen({super.key});

  @override
  State<PostScreen> createState() => _PostScreenState();
}

final auth = FirebaseAuth.instance;
final database = FirebaseDatabase.instance;

class _PostScreenState extends State<PostScreen> {
  // Widget userAccess = Text(auth.currentUser!.email.toString());

  final ref = database.ref('Posts');

  List<dynamic> list = [];

  void getPostsFromDb(AsyncSnapshot<DatabaseEvent> snapshot) async {
    Map<dynamic, dynamic> map = await snapshot.data!.snapshot.value as dynamic;
    list.clear();
    setState(() {
      list = map.values.toList();
    });
  }

  @override
  void initState() {
    ref.onValue.listen((event) {});

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // if (auth.currentUser!.email == null) {
    //   setState(() {
    //     userAccess = Text(auth.currentUser!.phoneNumber.toString());
    //   });
    // }

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text("Posts"),
        leading: null,
        actions: [
          IconButton(
              onPressed: () async {
                await GoogleSignIn().signOut();
                auth.signOut().then((value) {
                  Utils().showMessage(context, "Sorry to see you go.",
                      Theme.of(context).colorScheme.secondary);
                  Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const LoginScreen()));
                }).onError((error, stackTrace) {
                  Utils().showMessage(context, "Unable to logout.",
                      Theme.of(context).colorScheme.error);
                });
              },
              icon: const Icon(Icons.logout_rounded)),
        ],
      ),
      body: StreamBuilder(
        stream: ref.onValue,
        builder: (context, AsyncSnapshot<DatabaseEvent> snapshot) {
          getPostsFromDb(snapshot);

          if (snapshot.hasData) {
            return ListView.builder(
              itemCount: snapshot.data!.snapshot.children.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(list[index]['desc']),
                  subtitle: Text(list[index]['id']),
                );
              },
            );
          } else if (snapshot.hasError) {
            return const Text("Unexpected error occrured.");
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
      // body: FirebaseAnimatedList(
      //   defaultChild: const Center(child: CircularProgressIndicator()),
      //   query: ref,
      //   itemBuilder: (context, snapshot, animation, index) {
      //     return ListTile(
      //       title: Text(snapshot.child("id").value.toString()),
      //       subtitle: Text(snapshot.child("desc").value.toString()),
      //     );
      //   },
      // ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => const AddPost()));
        },
        backgroundColor: Theme.of(context).colorScheme.primary,
        child: const Icon(
          Icons.add,
          color: Colors.white60,
        ),
      ),
    );
  }
}
