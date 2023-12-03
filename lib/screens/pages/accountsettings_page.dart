import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:sunspark/screens/auth/landing_screen.dart';
import 'package:sunspark/widgets/text_widget.dart';
import 'package:sunspark/widgets/toast_widget.dart';

import '../../widgets/button_widget.dart';
import '../../widgets/textfield_widget.dart';

class AccountSettings extends StatefulWidget {
  const AccountSettings({super.key});

  @override
  State<AccountSettings> createState() => _AccountSettingsState();
}

class _AccountSettingsState extends State<AccountSettings> {
  getHeight(percent) {
    var toDecimal = percent / 100;
    return MediaQuery.of(context).size.height * toDecimal;
  }

  getWidth(percent) {
    var toDecimal = percent / 100;
    return MediaQuery.of(context).size.width * toDecimal;
  }

  updatePassword(
      {required String newPassword, required String oldPassword}) async {
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: FirebaseAuth.instance.currentUser!.email!,
        password: oldPassword,
      );
      await FirebaseAuth.instance.currentUser!.updatePassword(newPassword);
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (BuildContext context) => LandingScreen()),
        (Route<dynamic> route) => false,
      );
      showToast("Password successfully updated");
    } catch (e) {
      showToast("password is incorrect");
    }
  }

  forgotPassword() async {
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(
          email: FirebaseAuth.instance.currentUser!.email!);
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (BuildContext context) => LandingScreen()),
        (Route<dynamic> route) => false,
      );
      showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: Text("Message"),
              content: Container(
                height: getHeight(8),
                width: getWidth(80),
                child: Center(
                  child: Text(
                      "Password reset email sent to ${FirebaseAuth.instance.currentUser!.email!}"),
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

  TextEditingController oldPassword = TextEditingController();
  TextEditingController newPassword = TextEditingController();
  TextEditingController confirmNewPassword = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Text("Account Settings"),
        centerTitle: true,
      ),
      body: SizedBox(
        height: getHeight(100),
        width: getWidth(100),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              height: getHeight(5),
            ),
            TextFieldWidget(
              label: 'Current password',
              controller: oldPassword,
              isObscure: true,
              isPassword: true,
            ),
            SizedBox(
              height: getHeight(3),
            ),
            TextFieldWidget(
              label: 'New password',
              controller: newPassword,
              isObscure: true,
              isPassword: true,
            ),
            SizedBox(
              height: getHeight(3),
            ),
            TextFieldWidget(
              label: 'Corfirm new password',
              controller: confirmNewPassword,
              isObscure: true,
              isPassword: true,
            ),
            SizedBox(
              height: getHeight(5),
            ),
            ButtonWidget(
              label: 'Update password',
              onPressed: () {
                if (confirmNewPassword.text.isEmpty ||
                    oldPassword.text.isEmpty ||
                    newPassword.text.isEmpty) {
                  print("Called");
                  showToast("Missing input");
                } else {
                  if (confirmNewPassword.text == newPassword.text) {
                    updatePassword(
                        newPassword: newPassword.text,
                        oldPassword: oldPassword.text);
                  } else {
                    showToast("Password did not match");
                  }
                }
              },
            ),
            SizedBox(
              height: getHeight(2),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextRegular(
                  text: 'Forgot password?',
                  fontSize: 14,
                  color: Colors.black,
                ),
                TextButton(
                  onPressed: () {
                    forgotPassword();
                  },
                  child: TextBold(
                    text: 'Click here',
                    fontSize: 14,
                    color: Colors.blue,
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
