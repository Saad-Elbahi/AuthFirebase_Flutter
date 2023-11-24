import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LoginEcran extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Material(
      child: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return SignInScreen();
          } else {
            User? user = snapshot.data;
            return Container(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Email: ${user?.email}'),
                  ElevatedButton(
                    onPressed: () {
                      FirebaseAuth.instance.signOut();
                    },
                    child: Text('Se déconnecter'),
                  ),
                ],
              ),
            );
          }
        },
      ),
    );
  }
}


class SignInScreen extends StatelessWidget {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  void login(BuildContext context) async {
    try {
      UserCredential userCredential =
          await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailController.text,
        password: passwordController.text,
      );
      // Connexion réussie, faire quelque chose si nécessaire
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        print('Utilisateur non trouvé');
      } else if (e.code == 'wrong-password') {
        print('Mot de passe incorrect');
      }
    } catch (e) {
      print('Erreur de connexion : $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          TextField(
            controller: emailController,
            decoration: InputDecoration(
              labelText: 'Email',
            ),
          ),
          TextField(
            controller: emailController,
            decoration: InputDecoration(
              labelText: 'Email',
            ),
          ),
          TextField(
            controller: passwordController,
            decoration: InputDecoration(
              labelText: 'Mot de passe',
            ),
            obscureText: true,
          ),
          SizedBox(height: 16.0),
          ElevatedButton(
            onPressed: () {
              login(context);
            },
            child: Text('Se connecter'),
          ),
        ],
      ),
    );
  }
}