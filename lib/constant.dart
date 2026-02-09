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

// Any button
ElevatedButton kElevatedButton({
  required String label,
  required VoidCallback onPressed,
  IconData icon = Icons.login,
  Color backgroundColor = Colors.blue,
}) {
  return ElevatedButton(
    style: ElevatedButton.styleFrom(
      backgroundColor: backgroundColor,
      padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    ),
    onPressed: onPressed,
    child: Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        SizedBox(width: 10),
        Icon(icon, color: Colors.white, size: 20),
      ],
    ),
  );
}

// Reusable Input Decoration
InputDecoration kInputDecoration({
  String? hintText,
  Widget? prefixIcon,
  Widget? suffixIcon,
}) {
  return InputDecoration(
    hintText: hintText,
    prefixIcon: prefixIcon,
    suffixIcon: suffixIcon,
    filled: true,
    fillColor: Colors.white,
    contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(15),
      borderSide: BorderSide(color: Colors.grey.shade300),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(15),
      borderSide: const BorderSide(color: Colors.blue, width: 2),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(15),
      borderSide: const BorderSide(color: Colors.red),
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(15),
      borderSide: const BorderSide(color: Colors.red, width: 2),
    ),
  );
}

//any Row
Row kRow(String labe) {
  return Row(
    children: [
      Text(labe, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
    ],
  );
}

//Listview at home
Widget kListview(
  List<String> categories,
  int selectedIndex,
  Function(int) onTap,
) {
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
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: Colors.black,
      ),
    ),
  );
}
