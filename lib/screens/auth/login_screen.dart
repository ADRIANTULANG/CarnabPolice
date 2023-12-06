import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'package:sunspark/screens/auth/signup_screen.dart';
import 'package:sunspark/screens/mewhome_screen.dart';
import 'package:sunspark/widgets/button_widget.dart';
import 'package:sunspark/widgets/text_widget.dart';
import 'package:sunspark/widgets/textfield_widget.dart';

import '../../widgets/toast_widget.dart';

class LoginScreen extends StatefulWidget {
  final bool? inUser;

  LoginScreen({super.key, this.inUser = true});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final emailController = TextEditingController();

  final passwordController = TextEditingController();

  getHeight(percent) {
    var toDecimal = percent / 100;
    return MediaQuery.of(context).size.height * toDecimal;
  }

  getWidth(percent) {
    var toDecimal = percent / 100;
    return MediaQuery.of(context).size.width * toDecimal;
  }

  showInputEmail() async {
    TextEditingController email = TextEditingController();
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text("Enter email"),
            content: Container(
              height: getHeight(8),
              width: getWidth(80),
              child: Center(
                child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: TextField(
                      controller: email,
                      decoration: InputDecoration(
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.only(left: getWidth(3))),
                    )),
              ),
            ),
            actions: [
              TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    forgotPassword(email: email.text);
                  },
                  child: Text("Send Reset Email"))
            ],
          );
        });
  }

  forgotPassword({required String email}) async {
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);

      showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: Text("Message"),
              content: Container(
                height: getHeight(8),
                width: getWidth(80),
                child: Center(
                  child: Text("Password reset email sent to $email"),
                ),
              ),
              actions: [
                TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Text("Okay"))
              ],
            );
          });
    } on Exception catch (_) {
      showToast("Something went wrong $_");
    }
  }

  createLogs(
      {required String username,
      required String userid,
      required String log}) async {
    await FirebaseFirestore.instance.collection('logs').add({
      "dateTime": Timestamp.now(),
      "username": username,
      "userid": userid,
      "userDocReference":
          FirebaseFirestore.instance.collection('Officers').doc(userid),
      "logMessage": log
    });
  }

  login(context) async {
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: emailController.text, password: passwordController.text);
      if (FirebaseAuth.instance.currentUser != null) {
        var user = await FirebaseFirestore.instance
            .collection('Officers')
            .doc(FirebaseAuth.instance.currentUser!.uid)
            .get();

        if (user.exists) {
          var userDetails = user.data();
          if (userDetails!['status'] == "Active") {
            createLogs(
                username: userDetails['name'], userid: user.id, log: "Login");
            Navigator.of(context).pushReplacement(MaterialPageRoute(
                builder: (context) => NewHomeScreen(
                      inUser: widget.inUser,
                    )));
          } else {
            showToast("Account is currently inactive. Please try again later");
          }
        }
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        showToast("No user found with that username.");
      } else if (e.code == 'wrong-password') {
        showToast("Wrong password provided for that user.");
      } else if (e.code == 'invalid-email') {
        showToast("Invalid username provided.");
      } else if (e.code == 'user-disabled') {
        showToast("User account has been disabled.");
      } else {
        showToast("An error occurred: ${e.message}");
      }
    } on Exception catch (e) {
      showToast("An error occurred: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'assets/images/police.jpg',
                height: 150,
              ),
              const SizedBox(
                height: 5,
              ),
              TextBold(
                text: 'Police Officer Portal',
                fontSize: 18,
                color: Colors.black,
              ),
              const SizedBox(
                height: 10,
              ),
              const SizedBox(
                height: 50,
              ),
              TextFieldWidget(label: 'Email', controller: emailController),
              const SizedBox(
                height: 5,
              ),
              TextFieldWidget(
                  isObscure: true,
                  isPassword: true,
                  label: 'Password',
                  controller: passwordController),
              const SizedBox(
                height: 10,
              ),
              InkWell(
                onTap: () {
                  showInputEmail();
                },
                child: Padding(
                  padding:
                      EdgeInsets.only(left: getWidth(12), right: getWidth(12)),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: TextBold(
                        text: "Forgot password",
                        fontSize: 12,
                        color: Colors.lightBlue),
                  ),
                ),
              ),
              const SizedBox(
                height: 50,
              ),
              ButtonWidget(
                label: 'Login',
                onPressed: () {
                  login(context);
                },
              ),
              const SizedBox(
                height: 30,
              ),
              widget.inUser!
                  ? Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        TextRegular(
                          text: 'New to Carnab?',
                          fontSize: 14,
                          color: Colors.black,
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).push(MaterialPageRoute(
                                builder: (context) => SignupScreen()));
                          },
                          child: TextBold(
                            text: 'Register here',
                            fontSize: 14,
                            color: Colors.blue,
                          ),
                        ),
                      ],
                    )
                  : const SizedBox(),
            ],
          ),
        ),
      ),
    );
  }
}
