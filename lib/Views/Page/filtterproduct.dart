import 'package:demo_interview/Route/base_routes.dart';
import 'package:flutter/material.dart';

class FilterProduct extends StatefulWidget {
  const FilterProduct({super.key});

  @override
  State<FilterProduct> createState() => _FilterProductState();
}

class _FilterProductState extends State<FilterProduct> {
  @override
  Widget build(BuildContext context) {
    final String categoryTitle =
        ModalRoute.of(context)!.settings.arguments as String? ??
        "Filter Product";

    return Scaffold(
      appBar: AppBar(
        title: Text(
          categoryTitle,
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color.fromARGB(255, 227, 207, 54),
      ),
      backgroundColor: const Color.fromARGB(255, 227, 207, 54),
      body: SafeArea(
        child: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10.0),
            child: Column(
              children: [
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [buildProductCard(), buildProductCard()],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget buildProductCard() {
    return Card(
      elevation: 0,
      color: Colors.grey[100],
      child: SizedBox(
        height: 320,
        width: 200,
        child: Padding(
          padding: const EdgeInsets.only(top: 5.0, bottom: 5.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 190,
                height: 190,
                decoration: BoxDecoration(
                  color: Colors.yellow,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Image.asset("icons/adwords.png", height: 40, width: 40),
              ),
              Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(5.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Product Name",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 5),
                        Text(
                          "\$99.00",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.orange,
                          ),
                        ),
                        SizedBox(height: 5),
                        Row(
                          children: [
                            customButton(
                              title: "Add To Cart",
                              onTap: () {
                                setState(() {
                                  Navigator.pushNamed(
                                    context,
                                    BaseRoute.addToCard,
                                  );
                                });
                              },
                              color: Colors.green,
                            ),
                            SizedBox(width: 20),
                            customButton(
                              title: "Buy",
                              onTap: () {
                                setState(() {
                                  Navigator.pushNamed(
                                    context,
                                    BaseRoute.productDetail,
                                  );
                                });
                              },
                              color: Colors.deepOrange,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget customButton({
    required String title,
    required Function onTap,
    required Color color,
  }) {
    return TextButton(
      onPressed: () {
        onTap();
      },
      style: TextButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        foregroundColor: Colors.white,
        backgroundColor: color,
      ),
      child: Text(
        title,
        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
      ),
    );
  }
}
