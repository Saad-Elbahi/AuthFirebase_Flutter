import 'package:atelier4_s_elbahi_iir5g5/produit.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:atelier4_s_elbahi_iir5g5/firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_ui_auth/firebase_ui_auth.dart';

class ListeProduit extends StatefulWidget {
  const ListeProduit({Key? key}) : super(key: key);

  @override
  _ListeProduiState createState() => _ListeProduiState();
}

class _ListeProduiState extends State<ListeProduit> {
  FirebaseFirestore db = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Product List'),
           backgroundColor: Color.fromARGB(255, 63, 181, 144),
        ),
        body: StreamBuilder<QuerySnapshot>(
          stream: db.collection("produits").snapshots(),
          builder:
              (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
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
        ));
  }
}

class ProduitItem extends StatelessWidget {
  final Produit produit;
  const ProduitItem({Key? key, required this.produit}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(produit.name),
      subtitle: Text(produit.marque),
      trailing: Text('${produit.prix} Mad'),
    );
  }
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  FirebaseUIAuth.configureProviders([
    EmailAuthProvider(),
  ]);
  runApp(const MaterialApp(
    home: ListeProduit(),
  ));
}
