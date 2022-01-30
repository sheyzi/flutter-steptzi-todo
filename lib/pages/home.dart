import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:steptzi_todo/service/auth_service.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final TextEditingController _todoController = TextEditingController();
  bool circuler = false;
  final _formKey = GlobalKey<FormState>();

  CollectionReference todos = FirebaseFirestore.instance.collection('todos');
  final Stream<QuerySnapshot> _todoStream = FirebaseFirestore.instance
      .collection('todos')
      .where('userId', isEqualTo: FirebaseAuth.instance.currentUser!.uid)
      .snapshots();

  AuthClass authClass = AuthClass();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: const Text(
          "Steptzi Todo",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900),
        ),
        backgroundColor: const Color(0xff212443),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () async {
              await authClass.logOut(context);
            },
            icon: const FaIcon(FontAwesomeIcons.signOutAlt),
          )
        ],
      ),
      body: StreamBuilder(
        stream: _todoStream,
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError) {
            return Container(
              color: const Color(0xff212443),
              child: const Center(
                child: Text(
                  "Couldn't load the todo!",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            );
          } else if (snapshot.connectionState == ConnectionState.waiting) {
            return Container(
              color: const Color(0xff212443),
              child: const Center(
                child: CircularProgressIndicator(
                  color: Colors.white,
                ),
              ),
            );
          } else {
            List children = snapshot.data!.docs.map((document) {
              Map<String, dynamic> data =
                  document.data()! as Map<String, dynamic>;
              return data;
            }).toList();

            if (children.isNotEmpty) {
              return Container(
                padding: const EdgeInsets.all(10),
                color: const Color(0xff212443),
                child: ListView.builder(
                    itemCount: children.length,
                    itemBuilder: (content, index) {
                      return Container(
                        padding: const EdgeInsets.all(30),
                        margin: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          color: children[index]['done']
                              ? Colors.green[100]
                              : Colors.black54,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 20,
                              backgroundColor: children[index]['done']
                                  ? Colors.green
                                  : Colors.grey[700],
                              child: const Padding(
                                padding: EdgeInsets.all(8.0),
                                child: FaIcon(
                                  FontAwesomeIcons.check,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            const SizedBox(
                              width: 10,
                            ),
                            Text(
                              children[index]['body'],
                              style: TextStyle(
                                  fontSize: 18,
                                  color: children[index]['done']
                                      ? Colors.green
                                      : Colors.white,
                                  fontWeight: FontWeight.bold),
                            ),
                            const Expanded(child: SizedBox()),
                            IconButton(
                              onPressed: () {
                                var _currentId = snapshot.data!.docs[index].id;
                                todos
                                    .doc(_currentId)
                                    .update({'done': !children[index]['done']});
                              },
                              icon: FaIcon(children[index]['done']
                                  ? FontAwesomeIcons.times
                                  : FontAwesomeIcons.check),
                              color: children[index]['done']
                                  ? Colors.green
                                  : Colors.white,
                            )
                          ],
                        ),
                      );
                    }),
              );
            } else {
              return Container(
                color: const Color(0xff212443),
                child: const Center(
                  child: Text(
                    "You are free!!",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              );
            }
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showModalBottomSheet(
            context: context,
            backgroundColor: Colors.transparent,
            builder: (context) => Container(
              decoration: const BoxDecoration(
                color: Color(0xff212443),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(30.0),
                  topRight: Radius.circular(30.0),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 10.0, // has the effect of softening the shadow
                    spreadRadius: 0.0, // has the effect of extending the shadow
                  )
                ],
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    const SizedBox(
                      height: 40,
                    ),
                    textItem(label: "Todo Item", controller: _todoController),
                    const SizedBox(
                      height: 20,
                    ),
                    colorButton(),
                  ],
                ),
              ),
            ),
          );
        },
        backgroundColor: const Color(0xff44cd7d),
        child: const FaIcon(FontAwesomeIcons.plus),
      ),
    );
  }

  Widget colorButton() {
    return TextButton(
      onPressed: () async {
        if (_formKey.currentState!.validate()) {
          setState(() {
            circuler = true;
          });

          todos.add({
            "body": _todoController.text,
            "userId": FirebaseAuth.instance.currentUser!.uid,
            "done": false
          }).then((value) {
            _todoController.clear();
            const SnackBar snackBar = SnackBar(
              content: Text("Todo Added Successfully!"),
            );
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(snackBar);
            setState(() {
              circuler = false;
            });
          }).catchError((error) {
            print(error);
            const SnackBar snackBar = SnackBar(
              content: Text("There was an error signing you into your account"),
            );
            ScaffoldMessenger.of(context).showSnackBar(snackBar);
            setState(() {
              circuler = false;
            });
          });
        }
      },
      style: ButtonStyle(
          minimumSize: MaterialStateProperty.all(
              Size(MediaQuery.of(context).size.width - 70, 55)),
          shape: MaterialStateProperty.all(
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(50))),
          backgroundColor: MaterialStateProperty.all(const Color(0xff44cd7d))),
      child: circuler
          ? const CircularProgressIndicator(
              color: Color(0xff212441),
            )
          : const Text(
              "Add Todo",
              style: TextStyle(
                color: Color(0xff212441),
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
    );
  }

  Widget textItem(
      {required String label,
      bool password = false,
      required TextEditingController controller}) {
    // ignore: sized_box_for_whitespace
    return Container(
      width: MediaQuery.of(context).size.width - 70,
      height: 55,
      child: TextFormField(
        validator: (text) {
          if (text == null || text.isEmpty) {
            return 'Field is required';
          }
          return null;
        },
        controller: controller,
        obscureText: password,
        enableSuggestions: !password,
        autocorrect: !password,
        style: const TextStyle(
          color: Color(0xff474d73),
          fontSize: 17,
          letterSpacing: 2,
        ),
        decoration: InputDecoration(
          hintText: label,
          hintStyle: const TextStyle(
            fontSize: 17,
            color: Color(0xff474d73),
          ),
          fillColor: const Color(0xff252847),
          filled: true,
          errorMaxLines: 1,
          isDense: true,
          // contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 30),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(50),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(50),
            borderSide: BorderSide.none,
          ),
          errorBorder: OutlineInputBorder(
            borderSide: BorderSide.none,
            borderRadius: BorderRadius.circular(50),
          ),
          errorStyle: const TextStyle(
            color: Colors.red,
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(50),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }
}
