import 'package:flutter/material.dart';

class AddToCard extends StatefulWidget {
  const AddToCard({super.key});

  @override
  State<AddToCard> createState() => _AddToCardState();
}

class _AddToCardState extends State<AddToCard> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Add To Cart"),
      ),
    );
  }
}