import 'package:cloud_firestore/cloud_firestore.dart';

import 'Produit.dart';

class ProduitDao {
  final CollectionReference produitsCollection =
  FirebaseFirestore.instance.collection('produits');

  // Insérer un produit dans Firestore
  Future<void> insertProduit(Produit produit) async {
    await produitsCollection.add(produit.toJson());
  }

  // Mettre à jour un produit dans Firestore
  Future<void> updateProduit(Produit produit) async {
    await produitsCollection.doc(produit.id).update(produit.toJson());
  }

  // Supprimer un produit dans Firestore
  Future<void> deleteProduit(String produitId) async {
    await produitsCollection.doc(produitId).delete();
  }

  // Récupérer tous les produits depuis Firestore
  Stream<List<Produit>> getProduits() {
    return produitsCollection.snapshots().map(
          (snapshot) => snapshot.docs
          .map(
            (doc) => Produit.fromFirestore(doc),
      )
          .toList(),
    );
  }}