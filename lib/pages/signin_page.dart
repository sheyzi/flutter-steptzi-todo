// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:steptzi_todo/pages/home.dart';
import 'package:steptzi_todo/pages/signup_page.dart';
import 'package:steptzi_todo/service/auth_service.dart';
import 'package:page_transition/page_transition.dart';

class SignInPage extends StatefulWidget {
  const SignInPage({Key? key}) : super(key: key);

  @override
  _SignInPageState createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool circuler = false;

  AuthClass authClass = AuthClass();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: SingleChildScrollView(
          child: Container(
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            color: Color(0xff212443),
            child: Padding(
              padding: const EdgeInsets.only(top: 20.0, left: 10, right: 10),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      height: 20,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: Text(
                        "Sign In",
                        style: TextStyle(
                          fontSize: 25,
                          color: Color(0xffd9dade),
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1,
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 35,
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        textItem(
                            label: "Email...", controller: _emailController),
                        SizedBox(
                          height: 15,
                        ),
                        textItem(
                            label: "Password...",
                            password: true,
                            controller: _passwordController),
                        SizedBox(
                          height: 15,
                        ),
                        colorButton(),
                        SizedBox(
                          height: 15,
                        ),
                        Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                "Don't have an account?",
                                style: TextStyle(
                                  color: Color(0xff474d73),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(
                                width: 5,
                              ),
                              TextButton(
                                onPressed: () {
                                  Navigator.push(
                                      context,
                                      PageTransition(
                                        type: PageTransitionType.rightToLeft,
                                        child: SignUpPage(),
                                      ));
                                },
                                child: Text(
                                  "Sign Up",
                                  style: TextStyle(
                                    color: Color(0xff44cd7d),
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                              )
                            ]),
                        SizedBox(
                          height: 10,
                        ),
                        Text(
                          "Forgot Password?",
                          style: TextStyle(
                            color: Color(0xff44cd7d),
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        Row(
                          children: [
                            Expanded(
                              child: Divider(
                                thickness: 1,
                                height: 40,
                                color: Color(0xff474d73),
                              ),
                            ),
                            SizedBox(width: 10),
                            Text(
                              "OR",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Color(0xff474d73),
                                fontSize: 18,
                              ),
                            ),
                            SizedBox(width: 10),
                            Expanded(
                              child: Divider(
                                thickness: 1,
                                height: 40,
                                color: Color(0xff474d73),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            buttonItem(
                                iconData: FaIcon(
                                  FontAwesomeIcons.googlePlusG,
                                  color: Color(0xff212444),
                                ),
                                onPressed: () async {
                                  await authClass.signInWithGoogle(context);
                                }),
                            SizedBox(
                              width: 15,
                            ),
                            buttonItem(
                                iconData: FaIcon(
                                  FontAwesomeIcons.phone,
                                  color: Color(0xff212444),
                                ),
                                onPressed: () {}),
                          ],
                        )
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
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

          try {
            await FirebaseAuth.instance.signInWithEmailAndPassword(
                email: _emailController.text,
                password: _passwordController.text);
            setState(() {
              circuler = false;
            });
            Navigator.pushAndRemoveUntil(
              context,
              PageTransition(
                type: PageTransitionType.fade,
                child: Home(),
              ),
              (route) => false,
            );
          } on FirebaseAuthException catch (e) {
            final SnackBar snackBar = SnackBar(
              content: Text("${e.message}"),
            );
            ScaffoldMessenger.of(context).showSnackBar(snackBar);
            setState(() {
              circuler = false;
            });
          } catch (e) {
            final SnackBar snackBar = SnackBar(
              content: Text("There was an error signing you into your account"),
            );
            ScaffoldMessenger.of(context).showSnackBar(snackBar);
            setState(() {
              circuler = false;
            });
          }
        }
      },
      style: ButtonStyle(
          minimumSize: MaterialStateProperty.all(
              Size(MediaQuery.of(context).size.width - 70, 55)),
          shape: MaterialStateProperty.all(
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(50))),
          backgroundColor: MaterialStateProperty.all(Color(0xff44cd7d))),
      child: circuler
          ? CircularProgressIndicator(
              color: Color(0xff212441),
            )
          : Text(
              "Sign In",
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
        style: TextStyle(
          color: Color(0xff474d73),
          fontSize: 17,
          letterSpacing: 2,
        ),
        decoration: InputDecoration(
          hintText: label,
          hintStyle: TextStyle(
            fontSize: 17,
            color: Color(0xff474d73),
          ),
          fillColor: Color(0xff252847),
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
          errorStyle: TextStyle(
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

  Widget buttonItem({required FaIcon iconData, required Function onPressed}) {
    return Center(
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          shape: CircleBorder(),
          primary: Color(0xffefefef),
          padding: EdgeInsets.all(15),
        ),
        onPressed: () {
          onPressed();
        },
        child: iconData,
      ),
    );
  }
}
