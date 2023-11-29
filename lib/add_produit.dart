import 'dart:io';
import 'package:atelier4_s_elbahi_iir5g5/produit.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

class AjoutProduitScreen extends StatefulWidget {
  @override
  _AjoutProduitScreenState createState() => _AjoutProduitScreenState();
}

class _AjoutProduitScreenState extends State<AjoutProduitScreen> {
  TextEditingController _marqueController = TextEditingController();
  TextEditingController _designationController = TextEditingController();
  TextEditingController _categorieController = TextEditingController();
  TextEditingController _prixController = TextEditingController();
  TextEditingController _quantiteController = TextEditingController();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  final CollectionReference _produitsCollection =
      FirebaseFirestore.instance.collection('produits');

  File? _image; // Variable pour stocker l'image sélectionnée

  // Fonction pour sélectionner une photo depuis la galerie
  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? pickedFile =
        await picker.pickImage(source: ImageSource.gallery);
    String assetImagePath =
        'assets/images/placeholder.jpg'; // Chemin de l'image par défaut
    File im = await getImageFileFromAssets("assets/images/placeholder.jpg");

    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    } else {
      setState(() {
        _image = im;
      });
    }
  }

  Future<File> getImageFileFromAssets(String assetPath) async {
    final ByteData data = await rootBundle.load(assetPath);
    final List<int> bytes = data.buffer.asUint8List();
    final tempDir = await getTemporaryDirectory();
    final File file = File('${tempDir.path}/temp_image.jpg');
    await file.writeAsBytes(bytes);
    return file;
  }

  Future<void> _ajouterProduit() async {
    try {
      DocumentReference documentReference = _produitsCollection.doc();

      String marque = _marqueController.text;
      String designation = _designationController.text;
      String categorie = _categorieController.text;
      double prix = double.parse(_prixController.text);
      int quantite = int.parse(_quantiteController.text);

      // Vérifiez si une image a été sélectionnée
      if (_image != null) {
        // Upload de la photo vers Cloud Storage
        Reference storageReference =
            _storage.ref().child(_image!.path.split('/').last);
        UploadTask uploadTask = storageReference.putFile(_image!);
        TaskSnapshot taskSnapshot = await uploadTask.whenComplete(() => null);
        String photoUrl = await taskSnapshot.ref.getDownloadURL();

        Produit nouveauProduit = Produit(
          id: documentReference.id,
          marque: marque,
          designation: designation,
          categorie: categorie,
          prix: prix,
          photo: photoUrl,
          quantite: quantite,
        );

        await documentReference.set(nouveauProduit.toJson());

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Produit ajouté avec succès')),
        );

        _marqueController.clear();
        _designationController.clear();
        _categorieController.clear();
        _prixController.clear();
        _quantiteController.clear();
        setState(() {
          _image = null; // Réinitialiser l'image après l'ajout du produit
        });
      } else {
        // Affichez un message d'erreur si aucune image n'a été sélectionnée
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Veuillez sélectionner une photo')),
        );
      }
    } catch (e) {
      print('Erreur lors de l\'ajout du produit : $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur lors de l\'ajout du produit')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Ajouter un produit'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Afficher l'image sélectionnée ou un conteneur vide si aucune image n'a été sélectionnée
              _image != null
                  ? Image.file(_image!)
                  : Container(
                      height: 100,
                      color: Colors
                          .grey), // Vous pouvez personnaliser la hauteur et la couleur du conteneur

              // Bouton pour sélectionner une photo
              ElevatedButton(
                onPressed: _pickImage,
                child: Text('Sélectionner une photo'),
              ),

              TextField(
                controller: _marqueController,
                decoration: InputDecoration(labelText: 'Marque'),
              ),
              TextField(
                controller: _designationController,
                decoration: InputDecoration(labelText: 'Désignation'),
              ),
              TextField(
                controller: _categorieController,
                decoration: InputDecoration(labelText: 'Catégorie'),
              ),
              TextField(
                controller: _prixController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: 'Prix'),
              ),
              TextField(
                controller: _quantiteController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: 'Quantité'),
              ),

              ElevatedButton(
                onPressed: _ajouterProduit,
                child: Text('Ajouter le produit'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
