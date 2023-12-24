import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class LoginEcran extends StatefulWidget {
  const LoginEcran({Key? key}) : super(key: key);

  @override
  State<LoginEcran> createState() => _LoginEcranState();
}

class _LoginEcranState extends State<LoginEcran> {
  final _formKey = GlobalKey<FormState>();
  bool isLoading = false;
  final TextEditingController _email = TextEditingController();
  final TextEditingController _password = TextEditingController();

  signInWithEmailAndPassword() async {
    try {
      setState(() {
        isLoading = true;
      });
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _email.text,
        password: _password.text,
      );
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Login successful")),
      );
      setState(() {
        isLoading = false;
      });
    } on FirebaseAuthException catch (user) {
      setState(() {
        isLoading = false;
      });
      if (user.code == 'user-not-found') {
        return ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("No user found")),
        );
      } else {
        return ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Wrong password or email")),
        );
      }
    } catch (excp) {
      print('Unexpected error: $excp');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Builder(
        builder: (BuildContext scaffoldContext) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                  const Icon(
                    Icons.lock,
                    size: 64,
                    color: Color.fromARGB(25, 60, 1, 1),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Connexion',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Form(
                    key: _formKey,
                    child: OverflowBar(
                      overflowSpacing: 20,
                      children: [
                        TextFormField(
                          controller: _email,
                          validator: (text) {
                            if (text == null || text.isEmpty) {
                              return 'Email is empty';
                            }
                            return null;
                          },
                          decoration: const InputDecoration(labelText: "Email"),
                        ),
                        TextFormField(
                          controller: _password,
                          validator: (text) {
                            if (text == null || text.isEmpty) {
                              return 'Password is empty';
                            }
                            return null;
                          },
                          obscureText: true,
                          decoration: const InputDecoration(labelText: "Password"),
                        ),
                        SizedBox(
                          width: double.infinity,
                          height: 45,
                          child: ElevatedButton(
                            onPressed: () {
                              if (_formKey.currentState!.validate()) {
                                signInWithEmailAndPassword();
                              }
                            },
                            child: isLoading
                                ? const Center(
                              child: CircularProgressIndicator(
                                color: Color.fromARGB(255, 63, 181, 144),
                              ),
                            )
                                : const Text("se connecter"),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );

  }
}