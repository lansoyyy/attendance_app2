import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'package:app1/screens/auth/signup_screen.dart';
import 'package:app1/screens/home_screen.dart';
import 'package:app1/utlis/colors.dart';
import 'package:app1/widgets/button_widget.dart';
import 'package:app1/widgets/text_widget.dart';
import 'package:app1/widgets/textfield_widget.dart';
import 'package:app1/widgets/toast_widget.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final id = TextEditingController();
  final password = TextEditingController();

  bool isstudent = true;
  bool isteacher = false;
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
                height: 50,
              ),
              TextWidget(
                text: 'LOGIN',
                fontSize: 48,
                fontFamily: 'Bold',
              ),
              const SizedBox(
                height: 50,
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
                  Padding(
                    padding: const EdgeInsets.only(right: 40, left: 40),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Checkbox(
                              activeColor: primary,
                              value: remembered,
                              onChanged: (value) {
                                setState(() {
                                  remembered = value!;
                                });
                              },
                            ),
                            TextWidget(
                              text: 'Remember Me',
                              fontSize: 12,
                              color: primary,
                              fontFamily: 'Bold',
                            ),
                          ],
                        ),
                        TextButton(
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: ((context) {
                                final formKey = GlobalKey<FormState>();
                                final TextEditingController emailController =
                                    TextEditingController();

                                return AlertDialog(
                                  backgroundColor: primary,
                                  title: TextWidget(
                                    text: 'Forgot Password',
                                    fontSize: 14,
                                    color: Colors.white,
                                  ),
                                  content: Form(
                                    key: formKey,
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        TextFieldWidget(
                                          color: Colors.white,
                                          hint: 'Email',
                                          textCapitalization:
                                              TextCapitalization.none,
                                          inputType: TextInputType.emailAddress,
                                          label: 'Email',
                                          controller: emailController,
                                          validator: (value) {
                                            if (value == null ||
                                                value.isEmpty) {
                                              return 'Please enter an email address';
                                            }
                                            final emailRegex = RegExp(
                                                r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
                                            if (!emailRegex.hasMatch(value)) {
                                              return 'Please enter a valid email address';
                                            }
                                            return null;
                                          },
                                        ),
                                      ],
                                    ),
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: (() {
                                        Navigator.pop(context);
                                      }),
                                      child: TextWidget(
                                        text: 'Cancel',
                                        fontSize: 12,
                                        color: Colors.white,
                                      ),
                                    ),
                                    TextButton(
                                      onPressed: (() async {
                                        if (formKey.currentState!.validate()) {
                                          try {
                                            Navigator.pop(context);
                                            await FirebaseAuth.instance
                                                .sendPasswordResetEmail(
                                                    email:
                                                        emailController.text);
                                            showToast(
                                                'Password reset link sent to ${emailController.text}');
                                          } catch (e) {
                                            String errorMessage = '';

                                            if (e is FirebaseException) {
                                              switch (e.code) {
                                                case 'invalid-email':
                                                  errorMessage =
                                                      'The email address is invalid.';
                                                  break;
                                                case 'user-not-found':
                                                  errorMessage =
                                                      'The user associated with the email address is not found.';
                                                  break;
                                                default:
                                                  errorMessage =
                                                      'An error occurred while resetting the password.';
                                              }
                                            } else {
                                              errorMessage =
                                                  'An error occurred while resetting the password.';
                                            }

                                            showToast(errorMessage);
                                            Navigator.pop(context);
                                          }
                                        }
                                      }),
                                      child: TextWidget(
                                        text: 'Continue',
                                        fontSize: 14,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                );
                              }),
                            );
                          },
                          child: TextWidget(
                            text: 'Forgot Password?',
                            fontSize: 12,
                            color: primary,
                            fontFamily: 'Bold',
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(
                height: 30,
              ),
              ButtonWidget(
                width: 275,
                label: 'Login',
                onPressed: () {
                  login(context);
                },
              ),
              const SizedBox(
                height: 10,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextWidget(
                    text: "Don't have an account?",
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) => const SignupScreen()));
                    },
                    child: TextWidget(
                      text: "Create now",
                      fontSize: 12,
                      color: primary,
                      fontFamily: 'Bold',
                    ),
                  )
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  login(context) async {
    try {
      final user = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: id.text, password: password.text);

      showToast('Logged in succesfully!');
      Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const HomeScreen()));
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        showToast("No user found with that email.");
      } else if (e.code == 'wrong-password') {
        showToast("Wrong password provided for that user.");
      } else if (e.code == 'invalid-email') {
        showToast("Invalid email provided.");
      } else if (e.code == 'user-disabled') {
        showToast("User account has been disabled.");
      } else {
        showToast("An error occurred: ${e.message}");
      }
    } on Exception catch (e) {
      showToast("An error occurred: $e");
    }
  }
}
