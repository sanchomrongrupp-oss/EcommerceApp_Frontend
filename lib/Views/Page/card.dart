import 'package:flutter/material.dart';

class CheckOut extends StatelessWidget {
  CheckOut({super.key});

  final TextEditingController cardNumberController = TextEditingController();
  final TextEditingController monthController = TextEditingController();
  final TextEditingController yearController = TextEditingController();
  final TextEditingController cvvController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 227, 207, 54),
      body: Padding(
        padding: const EdgeInsets.only(left: 10, right: 10, top: 8, bottom: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Add Your Cards",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(
              height: 20,
            ),
            Container(
              height: 220,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: Colors.blue,
              ),
            ),
            const SizedBox(
              height: 40,
            ),
            Container(
                height: 200,
                width: double.infinity,
                decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(20)),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: [
                      buildInput("Number", "Requierd"),
                      const SizedBox(
                        height: 10,
                      ),
                      buildInput("Expires", "MM/YYYY"),
                      const SizedBox(
                        height: 10,
                      ),
                      buildInput("CVV", "Security code"),
                    ],
                  ),
                )),
            const SizedBox(
              height: 10,
            ),
            const SizedBox(
              height: 70,
            ),
            buildTextButton(() {}, "SUBMIT")
          ],
        ),
      ),
    );
  }

  //Class Input Some Information
  Widget buildInput(String label, labelcenter) {
    return Row(children: [
      Text(
        label,
        style: const TextStyle(
            fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
      ),
      Expanded(
        child: TextField(
          keyboardType: TextInputType.number,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
          decoration: InputDecoration(
            hintText: labelcenter,
            hintStyle: const TextStyle(
              color: Colors.white54,
            ),
            border: InputBorder.none, // Disable underline
            enabledBorder: InputBorder.none, // Disable underline when enabled
            focusedBorder: InputBorder.none, // Disable underline when focused
          ),
        ),
      ),
    ]);
  }

  //Class Buttom
  Widget buildTextButton(Function onPressed, String label) {
    return Container(
      height: 56,
      width: double.infinity,
      decoration: BoxDecoration(
          color: Colors.blue, borderRadius: BorderRadius.circular(20)),
      child: TextButton(
        onPressed: () => onPressed(),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              label,
              style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black),
            ),
          ],
        ),
      ),
    );
  }
}
