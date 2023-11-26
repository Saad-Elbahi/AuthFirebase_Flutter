import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:atelier4_s_elbahi_iir5g5/firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_ui_auth/firebase_ui_auth.dart';

class ListeProdui extends StatefulWidget {
  const ListeProdui({Key? key}) : super(key: key);

  @override
  _ListeProduiState createState() => _ListeProduiState();
}

class _ListeProduiState extends State<ListeProdui> {
  FirebaseFirestore db = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Product List'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: db.collection('products').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final products = snapshot.data!.docs;
            return ListView.builder(
              itemCount: products.length,
              itemBuilder: (context, index) {
                final product = products[index].data() as Map<String, dynamic>;
                return ProduitItem(
                  productName: product['name'],
                  productPrice: product['price'],
                );
              },
            );
          } else if (snapshot.hasError) {
            return const Center(
              child: Text('Error loading products'),
            );
          } else {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
        },
      ),
    );
  }
}

class ProduitItem extends StatelessWidget {
  final String productName;
  final double productPrice;

  const ProduitItem({
    required this.productName,
    required this.productPrice,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(productName),
      subtitle: Text('Price: \$${productPrice.toStringAsFixed(2)}'),
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
    home: ListeProdui(),
  ));
}