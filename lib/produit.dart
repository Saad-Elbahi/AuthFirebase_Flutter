import 'package:cloud_firestore/cloud_firestore.dart';
class Produit {
  String id;
  String name;
  String description;
  String marque;
  double prix;
  String photo;
  int qte;

  Produit({
    required this.id,
    required this.name,
    required this.description,
    required this.marque,
    required this.prix,
    required this.photo,
    required this.qte,
  });
 factory Produit.fromFirestore(DocumentSnapshot document) {
    Map<String, dynamic> data = document.data() as Map<String, dynamic>;

    return Produit(
      id: document.id,
      marque: data['marque'] ?? '',
      description: data['description'] ?? '',
      name: data['name'] ?? '',
      prix: (data['prix'] ?? 0).toDouble(),
      photo: data['photo'] ?? '',
      qte: data['quantite'] ?? 0,
    );
  }
}