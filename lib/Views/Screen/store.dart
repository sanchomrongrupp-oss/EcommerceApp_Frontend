// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';

class Store extends StatefulWidget {
  const Store({super.key});

  @override
  State<Store> createState() => _StoreState();
}

class _StoreState extends State<Store> {
  int _selectedIndex = 0; // Track the selected button index

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 255, 255, 255),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Row(
              children: [
                // Active Button
                Expanded(
                  child: TextButton(
                    onPressed: () {
                      setState(() {
                        _selectedIndex = 0; // Update selected index
                      });
                    },
                    child: Column(
                      children: [
                        Text(
                          "Active",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: _selectedIndex == 0
                                ? Colors.black
                                : Colors.grey, // Change text color
                          ),
                        ),
                        Container(
                          height: 3,
                          width: double.infinity,
                          color: _selectedIndex == 0
                              ? Color.fromARGB(255, 227, 207, 54)
                              : Colors.transparent, // Change line color
                        ),
                      ],
                    ),
                  ),
                ),
                // Completed Button
                Expanded(
                  child: TextButton(
                    onPressed: () {
                      setState(() {
                        _selectedIndex = 1; // Update selected index
                      });
                    },
                    child: Column(
                      children: [
                        Text(
                          "Completed",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: _selectedIndex == 1
                                ? Colors.black
                                : Colors.grey, // Change text color
                          ),
                        ),
                        Container(
                          height: 3,
                          width: double.infinity,
                          color: _selectedIndex == 1
                              ? Color.fromARGB(255, 227, 207, 54)
                              : Colors.transparent, // Change line color
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
