import 'dart:io';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

import 'Produit.dart';

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

  File? _image; // Variable to store the selected image

  // Function to pick a photo from the gallery
  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    try {
      final XFile? pickedFile = await picker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        setState(() {
          _image = File(pickedFile.path);
        });
      } else {
        print('No image selected.');
      }
    } catch (e) {
      print('Error picking image: $e');
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

      // Check if an image has been selected
      if (_image != null && _image!.existsSync()) {
        // Upload the photo to Cloud Storage
        Reference storageReference = _storage.ref().child(_image!.path.split('/').last);
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
          _image = null; // Reset the image after adding the product
        });
      } else {
        // Display an error message if no image is selected
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Veuillez sélectionner une photo')),
        );
      }
    } catch (e) {
      print('Error adding the product: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur lors de l\'ajout du produit')),
      );
    }
  }

  Widget _buildImageWidget() {
    if (_image != null) {
      return kIsWeb
          ? Image.network(_image!.path) // Use Image.network for web
          : Image.file(_image!); // Use Image.file for mobile
    } else {
      return Container(
        height: 100,
        color: Colors.grey,
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
              // Display the selected image or an empty container if no image is selected
              _buildImageWidget(),

              // Button to pick a photo
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
