import 'package:app1/services/add_user.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:app1/screens/auth/login_screen.dart';
import 'package:app1/screens/home_screen.dart';

import 'package:app1/utlis/colors.dart';
import 'package:app1/widgets/button_widget.dart';
import 'package:app1/widgets/text_widget.dart';
import 'package:app1/widgets/textfield_widget.dart';
import 'package:app1/widgets/toast_widget.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final id = TextEditingController();
  final password = TextEditingController();
  final name = TextEditingController();
  final confirmpassword = TextEditingController();

  bool remembered = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(
                height: 20,
              ),
              TextWidget(
                text: 'SIGNUP',
                fontSize: 48,
                fontFamily: 'Bold',
              ),
              const SizedBox(
                height: 20,
              ),
              TextFieldWidget(
                prefixIcon: Icons.person,
                width: 275,
                controller: name,
                label: 'Name',
              ),
              const SizedBox(
                height: 10,
              ),
              TextFieldWidget(
                prefixIcon: Icons.email,
                width: 275,
                controller: id,
                label: 'Email',
              ),
              const SizedBox(
                height: 10,
              ),
              Column(
                children: [
                  TextFieldWidget(
                    prefixIcon: Icons.lock,
                    width: 275,
                    isObscure: true,
                    showEye: true,
                    controller: password,
                    label: 'Password',
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  TextFieldWidget(
                    prefixIcon: Icons.lock,
                    width: 275,
                    isObscure: true,
                    showEye: true,
                    controller: confirmpassword,
                    label: 'Confirm Password',
                  ),
                ],
              ),
              const SizedBox(
                height: 30,
              ),
              ButtonWidget(
                width: 275,
                label: 'Signup',
                onPressed: () {
                  if (password.text == confirmpassword.text) {
                    register(context);
                  } else {
                    showToast('Password do not match!');
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  register(context) async {
    try {
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: id.text, password: password.text);

      addUser(name.text, id.text, password.text, 'Teachers');

      showToast('Account created succesfully!');

      Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const LoginScreen()));
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        showToast('The password provided is too weak.');
      } else if (e.code == 'email-already-in-use') {
        showToast('The account already exists for that email.');
      } else if (e.code == 'invalid-email') {
        showToast('The email address is not valid.');
      } else {
        showToast(e.toString());
      }
    } on Exception catch (e) {
      showToast("An error occurred: $e");
    }
  }
}
