import 'package:flutter/material.dart';

class HomeBottomFilterCategory extends StatelessWidget {
  final List<String> categories;
  final int selectedFilterIndex;
  final Function(int index, String category) onFilterChanged;

  const HomeBottomFilterCategory({
    super.key,
    required this.categories,
    required this.selectedFilterIndex,
    required this.onFilterChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 15, right: 15),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: categories
              .asMap()
              .entries
              .map(
                (entry) => Padding(
                  padding: const EdgeInsets.only(right: 15),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: selectedFilterIndex == entry.key
                          ? const Color.fromARGB(255, 227, 207, 54)
                          : Colors.grey[200],
                      foregroundColor: selectedFilterIndex == entry.key
                          ? Colors.white
                          : Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    onPressed: () {
                      if (selectedFilterIndex != entry.key) {
                        onFilterChanged(entry.key, entry.value);
                      }
                    },
                    child: Text(entry.value),
                  ),
                ),
              )
              .toList(),
        ),
      ),
    );
  }
}