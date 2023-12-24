
import 'package:atelier4_s_elbahi_iir5g5/Produit.dart';
import 'package:atelier4_s_elbahi_iir5g5/login_ecran.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_ui_auth/firebase_ui_auth.dart';

import 'addproduit.dart';
class ListeProduit extends StatefulWidget {
  const ListeProduit({Key? key}) : super(key: key);

  @override
  _ListeProduiState createState() => _ListeProduiState();
}

class _ListeProduiState extends State<ListeProduit> {
  FirebaseFirestore db = FirebaseFirestore.instance;
  bool isAdmin = true; // Replace with actual role-checking logic

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Liste des produits'),
        backgroundColor: Color.fromARGB(255, 63, 181, 144),
        leading: IconButton(
          icon: Icon(Icons.logout),
          onPressed: () {
            FirebaseAuth.instance.signOut();
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => LoginEcran()),
            );
          },
        ),
        actions: [
          if (isAdmin)
            IconButton(
              icon: Icon(Icons.add),
              onPressed: () {
                // Navigate to AjoutProduitScreen
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AjoutProduitScreen()),
                );
              },
            ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: db.collection("produits").snapshots(),
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
            itemBuilder: (context, index) => isAdmin
                ? AdminProduitItem(produit: produits[index])
                : UserProduitItem(produit: produits[index]),
          );
        },
      ),
    );
  }
}

class AdminProduitItem extends StatelessWidget {
  final Produit produit;

  const AdminProduitItem({Key? key, required this.produit}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(produit.designation),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(produit.marque),
          SizedBox(height: 8), // Adjust the spacing as needed
          Image.network(
            produit.photo, // Assuming 'photo' is the field for the image URL in your Produit class
            width: 100, // Adjust the width as needed
            height: 100, // Adjust the height as needed
            fit: BoxFit.cover, // Adjust the fit as needed
          ),
        ],
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: Icon(Icons.delete),
            onPressed: () {
              // Show a confirmation dialog before deleting
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: Text('Confirmation'),
                    content: Text('Voulez-vous vraiment supprimer ce produit ?'),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context); // Close the dialog
                        },
                        child: Text('Annuler'),
                      ),
                      TextButton(
                        onPressed: () {
                          // Perform deletion and close the dialog
                          deleteProduct(produit.id);
                          Navigator.pop(context);
                        },
                        child: Text('Supprimer'),
                      ),
                    ],
                  );
                },
              );
            },
          ),
          Text('${produit.prix} Mad'),
        ],
      ),
    );
  }

  // Function to delete a product by ID
  void deleteProduct(String productId) {
    FirebaseFirestore.instance.collection('produits').doc(productId).delete();
  }
}



class UserProduitItem extends StatefulWidget {
  final Produit produit;

  const UserProduitItem({Key? key, required this.produit}) : super(key: key);

  @override
  _UserProduitItemState createState() => _UserProduitItemState();
}

class _UserProduitItemState extends State<UserProduitItem> {
  bool isFavorite = false;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(widget.produit.designation),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(widget.produit.marque),
          SizedBox(height: 8),
          Image.network(
            widget.produit.photo,
            width: 100,
            height: 100,
            fit: BoxFit.cover,
          ),
        ],
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('${widget.produit.prix} Mad'),
          IconButton(
            icon: Icon(
              isFavorite ? Icons.favorite : Icons.favorite_border,
              color: isFavorite ? Colors.red : null,
            ),
            onPressed: () {
              setState(() {
                isFavorite = !isFavorite;
              });
            },
          ),
        ],
      ),
    );
  }
}