import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fire_app/ui/auth/login_screen.dart';
import 'package:fire_app/ui/posts/add_post.dart';
import 'package:fire_app/ui/posts/post_image.dart';
import 'package:fire_app/utils/utils.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
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
final firestore = FirebaseFirestore.instance;
final storage = FirebaseStorage.instance;

class _PostScreenState extends State<PostScreen> {
  // Widget userAccess = Text(auth.currentUser!.email.toString());

  final ref = database.ref('Posts');
  final searchController = TextEditingController();
  final updateController = TextEditingController();
  String username = '';

  List<dynamic> list = [];

  void getPostsFromDb(AsyncSnapshot<DatabaseEvent> snapshot) async {
    Map<dynamic, dynamic> map = snapshot.data!.snapshot.value as dynamic;
    list.clear();
    setState(() {
      list = map.values.toList();
    });
  }

  Future<String> getUsername() async {
    User? user = auth.currentUser;
    if (user != null) {
      // Get the document snapshot corresponding to the current user's UID
      DocumentSnapshot snapshot = await firestore
          .collection('Users') // Replace 'Users' with your collection name
          .doc(user.uid)
          .get();

      // Get the 'username' field from the document
      setState(() {
        username = snapshot.get('username');
      });
      return username;
    } else {
      return 'User not logged in.';
    }
  }

  @override
  void initState() {
    ref.onValue.listen((event) {
      getPostsFromDb(event.snapshot as AsyncSnapshot<DatabaseEvent>);
    });
    getUsername();
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
        leading: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.person_outline_rounded),
            Text(username.split(' ')[0]),
          ],
        ),
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
      body: Column(
        children: [
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10.0),
            child: TextFormField(
              controller: searchController,
              decoration: const InputDecoration(
                labelText: "Search",
                floatingLabelBehavior: FloatingLabelBehavior.auto,
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                setState(() {});
              },
            ),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: StreamBuilder(
              stream: ref.onValue,
              builder: (context, AsyncSnapshot<DatabaseEvent> snapshot) {
                getPostsFromDb(snapshot);

                if (snapshot.hasData) {
                  return ListView.builder(
                    itemCount: snapshot.data!.snapshot.children.length,
                    itemBuilder: (context, index) {
                      final title = list[index]['desc'].toString();

                      if (searchController.text.isEmpty) {
                        return ListTile(
                          title: Text(list[index]['desc']),
                          subtitle: Text(list[index]['user']),
                          leading: GestureDetector(
                            onTap: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => PostImage(
                                          image: list[index]['picUrl'])));
                            },
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(9999),
                              child: SizedBox(
                                height: 50,
                                width: 50,
                                child: Image.network(
                                  list[index]['picUrl'],
                                  fit: BoxFit.cover,
                                  filterQuality: FilterQuality.high,
                                ),
                              ),
                            ),
                          ),
                          trailing: PopupMenuButton(
                            icon: const Icon(Icons.more_vert_rounded),
                            itemBuilder: (context) => [
                              PopupMenuItem(
                                  value: 1,
                                  onTap: () {
                                    showEditDialog(
                                        title, list[index]['id'].toString());
                                  },
                                  child: const ListTile(
                                    leading: Icon(Icons.edit),
                                    title: Text('Edit'),
                                  )),
                              PopupMenuItem(
                                value: 2,
                                onTap: () {
                                  showDeleteDialog(
                                    list[index]['id'].toString(),
                                    list[index]['desc'].toString(),
                                  );
                                },
                                child: const ListTile(
                                  leading: Icon(Icons.delete),
                                  title: Text('Delete'),
                                ),
                              ),
                            ],
                          ),
                        );
                      } else if (title
                          .toLowerCase()
                          .contains(searchController.text.toLowerCase())) {
                        return ListTile(
                          title: Text(list[index]['desc']),
                          subtitle: Text(list[index]['user']),
                          // subtitle: Text(list[index]['id']),
                          leading: GestureDetector(
                            onTap: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => PostImage(
                                          image: list[index]['picUrl'])));
                            },
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(9999),
                              child: SizedBox(
                                height: 50,
                                width: 50,
                                child: Image.network(
                                  list[index]['picUrl'],
                                  fit: BoxFit.cover,
                                  filterQuality: FilterQuality.high,
                                ),
                              ),
                            ),
                          ),
                          trailing: PopupMenuButton(
                            icon: const Icon(Icons.more_vert_rounded),
                            itemBuilder: (context) => [
                              PopupMenuItem(
                                  value: 1,
                                  onTap: () {
                                    showEditDialog(
                                        title, list[index]['id'].toString());
                                  },
                                  child: const ListTile(
                                    leading: Icon(Icons.edit),
                                    title: Text('Edit'),
                                  )),
                              PopupMenuItem(
                                  value: 2,
                                  onTap: () {
                                    showDeleteDialog(
                                      list[index]['id'].toString(),
                                      list[index]['desc'].toString(),
                                    );
                                  },
                                  child: const ListTile(
                                    leading: Icon(Icons.delete),
                                    title: Text('Delete'),
                                  )),
                            ],
                          ),
                        );
                      } else {
                        return Container();
                      }
                    },
                  );
                } else if (snapshot.hasError) {
                  return const Text("Unexpected error occrured.");
                } else {
                  return const Center(child: CircularProgressIndicator());
                }
              },
            ),
          ),
        ],
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

  Future<void> showEditDialog(String title, String id) async {
    updateController.text = title;
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Update'),
        content: TextField(
          controller: updateController,
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              ref.child(id).update({
                'desc': updateController.text.toString(),
              }).then((value) {
                Utils().showMessage(context, "Updated successfully!",
                    Theme.of(context).colorScheme.secondary);
              }).onError((error, stackTrace) {
                Utils().showMessage(context, error.toString(),
                    Theme.of(context).colorScheme.onError);
              });

              Navigator.pop(context);
            },
            child: Text(
              'Update',
              style: TextStyle(
                color: Theme.of(context).colorScheme.secondary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future showDeleteDialog(String id, String title) async {
    return showCupertinoModalPopup(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('Delete'),
        content: Text('You sure want to delete $title?'),
        actions: [
          CupertinoDialogAction(
            isDefaultAction: true,
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('No'),
          ),
          CupertinoDialogAction(
            isDestructiveAction: true,
            onPressed: () {
              storage.ref('Post_Images').child('$id.jpg').delete();
              ref.child(id).remove();
              Navigator.pop(context);
            },
            child: const Text('Yes'),
          ),
        ],
      ),
    );
  }
}
