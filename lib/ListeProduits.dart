import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class _ListeProduiState extends StatefulWidget {
   FirebaseFirestore db = FirebaseFirestore.instance;
  const _ListeProduiState({super.key});
  
  @override
  State<_ListeProduiState> createState() => __ListeProduiStateState( );
}

class __ListeProduiStateState extends State<_ListeProduiState> {
  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}