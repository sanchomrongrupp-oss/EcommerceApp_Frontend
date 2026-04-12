import 'package:flutter/material.dart';

class CheckOut extends StatelessWidget {
  CheckOut({super.key});

  final TextEditingController cardNumberController = TextEditingController();
  final TextEditingController monthController = TextEditingController();
  final TextEditingController yearController = TextEditingController();
  final TextEditingController cvvController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    // Retrieve product arguments
    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    final String title = args?['title']?.toString() ?? "Product Name";
    final String image = args?['image']?.toString() ?? "";
    final double price = args?['price'] != null
        ? double.parse(args!['price'].toString())
        : 0.0;
    final int qty = args?['qty'] ?? 1;
    final double total = price * qty;
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
            const SizedBox(height: 20),
            Container(
              height: 220,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: Colors.blue.withOpacity(0.1),
                border: Border.all(color: Colors.blue.withOpacity(0.3)),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    // Product Image
                    ClipRRect(
                      borderRadius: BorderRadius.circular(15),
                      child: Container(
                        width: 120,
                        height: 120,
                        color: Colors.white,
                        child: image.isNotEmpty
                            ? Image.network(
                                image,
                                fit: BoxFit.contain,
                                errorBuilder: (context, error, stackTrace) =>
                                    const Icon(Icons.shopping_bag, size: 50),
                              )
                            : const Icon(Icons.shopping_bag, size: 50),
                      ),
                    ),
                    const SizedBox(width: 20),
                    // Product Info
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            title,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 10),
                          Text(
                            "QTY: $qty",
                            style: TextStyle(color: Colors.grey[700]),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            "\$${total.toStringAsFixed(2)}",
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w900,
                              color: Colors.blue,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 40),
            Container(
              height: 200,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    buildInput("Number", "Requierd", cardNumberController),
                    const SizedBox(height: 10),
                    buildInput("Expires", "MM/YYYY", monthController),
                    const SizedBox(height: 10),
                    buildInput("CVV", "Security code", cvvController),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 10),
            const SizedBox(height: 70),
            buildTextButton(() {}, "SUBMIT"),
          ],
        ),
      ),
    );
  }

  //Class Input Some Information
  Widget buildInput(
    String label,
    String labelcenter,
    TextEditingController controller,
  ) {
    return Row(
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        Expanded(
          child: TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            decoration: InputDecoration(
              hintText: labelcenter,
              hintStyle: const TextStyle(color: Colors.white54),
              border: InputBorder.none, // Disable underline
              enabledBorder: InputBorder.none, // Disable underline when enabled
              focusedBorder: InputBorder.none, // Disable underline when focused
            ),
          ),
        ),
      ],
    );
  }

  //Class Buttom
  Widget buildTextButton(Function onPressed, String label) {
    return Container(
      height: 56,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.blue,
        borderRadius: BorderRadius.circular(20),
      ),
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
                color: Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
