//-----------STRING-----------\\
// ignore_for_file: prefer_interpolation_to_compose_strings, prefer_const_constructors

// import 'package:flutter/material.dart';

import 'package:flutter/material.dart';

const baseURL = "http://192.168.1.146:8000/api";
const signinURL = baseURL + "/login";
const signupURL = baseURL + "/register";
const signoutURL = baseURL + "/logout";
const userURL = baseURL + "/profile";
const productURL = baseURL + "/productlist";
const categoryURL = baseURL + "/categorylist";

//-----------ERROR-----------\\
const serverError = "Server error";
const unauthorized = "Unautthorized";
const somethingwentWrong = "Something Went Wrong, try again!";

InputDecoration kInputDecoration(String label) {
  return InputDecoration(
      border: OutlineInputBorder(),
      labelText: label,
      hintStyle: TextStyle(
        color: Colors.black,
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
      filled: true,
      fillColor: Colors.white);
}

// any button
ElevatedButton kElevatedButton(String label, Function onPressed) {
  return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.blue, // <-- set your background color here
        padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20), // optional: round corners
        ),
      ),
      onPressed: () => onPressed(),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            label,
            style: TextStyle(
                color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
          ),
          SizedBox(
            width: 10,
          ),
          Icon(
            Icons.login,
            color: Colors.white,
            size: 20,
          )
        ],
      ));
}

//any Row
Row kRow(String labe) {
  return Row(
    children: [
      Text(
        labe,
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
    ],
  );
}

//Listview at home
Widget kListview(
    List<String> categories, int selectedIndex, Function(int) onTap) {
  return SizedBox(
    height: 40,
    child: ListView.builder(
      scrollDirection: Axis.horizontal,
      itemCount: categories.length,
      itemBuilder: (context, index) {
        final label = categories[index];
        final isSelected = index == selectedIndex;

        return Padding(
          padding: EdgeInsets.only(left: index == 0 ? 15 : 10),
          child: TextButton(
            onPressed: () => onTap(index),
            style: TextButton.styleFrom(
              backgroundColor: isSelected
                  ? const Color.fromARGB(255, 227, 207, 54)
                  : Colors.transparent,
              side: const BorderSide(color: Colors.black, width: 2),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ),
        );
      },
    ),
  );
}

TextButton kTextButton(String label, Function onPressed) {
  return TextButton(
      onPressed: () => onPressed(),
      child: Text(
        label,
        style: TextStyle(
            fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black),
      ));
}
