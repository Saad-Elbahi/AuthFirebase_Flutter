
import 'package:atelier4_s_elbahi_iir5g5/login_ecran.dart';
import 'package:atelier4_s_elbahi_iir5g5/ListeProduits.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'Produit.dart';
import 'addproduit.dart';

class Auth extends StatelessWidget {
  const Auth({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (BuildContext context, AsyncSnapshot<User?> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const CircularProgressIndicator();
          } else {
            if (snapshot.hasData) {
              User user = snapshot.data!;
              return FutureBuilder<bool>(
                // Check if the user is an admin
                future: checkIfAdmin(user.email),
                builder: (BuildContext context, AsyncSnapshot<bool> adminSnapshot) {
                  if (adminSnapshot.connectionState == ConnectionState.waiting) {
                    return const CircularProgressIndicator();
                  } else {
                    bool isAdmin = adminSnapshot.data ?? false;
                    return isAdmin ? ListeProduit() : RegularUserListeProduit();
                  }
                },
              );
            } else {
              return const LoginEcran();
            }
          }
        },
      ),
    );
  }

  // Function to check if the user is an admin based on email
  Future<bool> checkIfAdmin(String? userEmail) async {
    // Replace the condition with your own logic to determine if the user is an admin
    // For example, check if the email contains a specific domain
    if (userEmail != null && userEmail.endsWith('@admin.com')) {
      return true;
    } else {
      return false;
    }
  }
}

class RegularUserListeProduit extends StatelessWidget {
  const RegularUserListeProduit({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Liste des produits'),
        backgroundColor: Color.fromARGB(255, 63, 181, 144),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection("produits").snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text('Une erreur est survenue'));
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          List<Produit> produits = snapshot.data!.docs.map((doc) {
            return Produit.fromFirestore(doc);
          }).toList();
          return ListView.builder(
            itemCount: produits.length,
            itemBuilder: (context, index) => UserProduitItem(produit: produits[index]),
          );
        },
      ),
      floatingActionButton: UserProfileButton(),
    );
  }
}

class UserProfileButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: () {
        // Navigate to user profile
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => UserProfileScreen()),
        );
      },
      child: Icon(Icons.person),
    );
  }
}


class UserProfileScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('User Profile'),
        backgroundColor: Color.fromARGB(255, 63, 181, 144),
      ),
      body: FutureBuilder<User>(
        // Fetch user data from Firestore and display email and role
        future: fetchUserData(),
        builder: (BuildContext context, AsyncSnapshot<User> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return CircularProgressIndicator();
          } else if (snapshot.hasData) {
            User user = snapshot.data!;
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Display user email
                  Text('User Email: ${user.email}'),
                  // Display user role
                  Text('Role: Regular User'),
                  // Logout button
                  ElevatedButton(
                    onPressed: () {
                      FirebaseAuth.instance.signOut();
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => LoginEcran()),
                      );
                    },
                    child: Text('Disconnect'),
                  ),
                ],
              ),
            );
          } else {
            return Center(
              child: Text('Failed to fetch user data.'),
            );
          }
        },
      ),
    );
  }

  // Function to fetch user data from Firestore
  Future<User> fetchUserData() async {
    User? currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      // Fetch additional user data from Firestore if needed
      // For simplicity, I'm returning the user directly
      return currentUser;
    } else {
      // Handle the case where the user is not found
      throw Exception('User not found');
    }
  }
}


