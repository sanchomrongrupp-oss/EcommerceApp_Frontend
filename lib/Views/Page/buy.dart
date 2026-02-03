// ignore_for_file: prefer_const_constructors

import 'package:demo_interview/constant.dart';
import 'package:flutter/material.dart';

class Buyproduct extends StatefulWidget {
  const Buyproduct({super.key});

  @override
  State<Buyproduct> createState() => _BuyproductState();
}

class _BuyproductState extends State<Buyproduct> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "SHOPING",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color.fromARGB(255, 227, 207, 54),
      ),
      backgroundColor: const Color.fromARGB(255, 227, 207, 54),
      body: SafeArea(
          child: Padding(
        padding: const EdgeInsets.only(left: 10, right: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              height: 300,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(20)),
                  color: Colors.white),
            ),
            SizedBox(
              height: 10,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                kTextButton("S", () {}),
                kTextButton("X", () {}),
                kTextButton("XL", () {}),
                kTextButton("X2L", () {}),
                kTextButton("X3L", () {}),
              ],
            ),
            SizedBox(
              height: 10,
            ),
            Text(
              "Nike",
              style: TextStyle(
                fontSize: 40,
              ),
            ),
            Text(
              "Nike",
              style: TextStyle(
                fontSize: 25,
              ),
            ),
            Text(
              "Nike",
              style: TextStyle(
                fontSize: 18,
              ),
            ),
            Spacer(),
            Padding(
              padding: const EdgeInsets.only(left: 10, bottom: 10),
              child: Row(
                children: [
                  Container(
                    height: 50,
                    width: 235,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                      color: const Color.fromARGB(255, 230, 240, 36),
                    ),
                    child: TextButton(
                      onPressed: () {},
                      child: Text(
                        "Price",
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            color: Colors.black),
                      ),
                    ),
                  ),
                  Spacer(),
                  Container(
                    height: 50,
                    width: 150,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                      color: const Color.fromARGB(255, 72, 240, 77),
                    ),
                    child: TextButton(
                      onPressed: () {},
                      child: Text(
                        "Buy",
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            color: Colors.black),
                      ),
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      )),
    );
  }
}
