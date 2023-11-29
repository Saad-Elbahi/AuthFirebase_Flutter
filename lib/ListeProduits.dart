import 'package:atelier4_s_elbahi_iir5g5/produit.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
class ListProduits extends StatefulWidget {
  const ListProduits({super.key});

  @override
  State<ListProduits> createState() => _ListProduitsState();
}

class _ListProduitsState extends State<ListProduits> {
  FirebaseFirestore db = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Liste des produits'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: db.collection('produits').snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          //    DocumentReference docRef =
          //        FirebaseFirestore.instance.collection('produits').doc("id");
          //   docRef = FirebaseFirestore.instance.doc("/produits/id");
          // docRef.get().then((value) => doc = value.get("marque"));
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
            itemBuilder: (context, index) => ProduitItem(
              produit: produits[index],
            ),
          );
        },
      ),
    );
  }
}

class ProduitItem extends StatelessWidget {
  ProduitItem({Key? key, required this.produit}) : super(key: key);

  final Produit produit;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Image.network(produit.photo),
        ListTile(
          title: Text(produit.designation),
          subtitle: Text(produit.marque),
          trailing: Text('${produit.prix}'),
        ),
      ],
    );
  }
}



//FirebaseFirestore.instance.collection('produits').doc(produitId).delete();
/*
 FirebaseFirestore.instance.collection('produits').add({
      'marque': marqueController.text,
      'designation': designationController.text,
      'categorie': categorieController.text,
      'prix': double.parse(prixController.text),
      'photoUrl': photoUrlController.text,
      'quantite': int.parse(quantiteController.text),
    });
    */

/*
FirebaseFirestore.instance.collection('produits').add({
      'marque': "Hello",
      'designation': "Classic",
      'categorie': 'cat',
      'prix': 55,
      'photoUrl': "",
      'quantite': 155
    });
    */