import 'package:flutter/material.dart';
import 'package:demo_interview/Route/base_routes.dart';

class HomeIconCategory extends StatelessWidget {
  final List<String> categoriesicon;
  final int selectedFilterIndex;
  final Function(int index, String category) onFilterChanged;

  const HomeIconCategory({
    super.key,
    required this.categoriesicon,
    required this.selectedFilterIndex,
    required this.onFilterChanged,
  });

  @override
  Widget build(BuildContext context) {
    final List<Map<String, String>> categoryData = [
      {"title": "Shirt", "icon": "shirt.png"},
      {"title": "Trousers", "icon": "trousers.png"},
      {"title": "Shoe", "icon": "sport-shoe.png"},
      {"title": "Bag", "icon": "briefcase.png"},
      {"title": "Chair", "icon": "swivel-chair.png"},
      {"title": "Table", "icon": "table.png"},
      {"title": "Sofa", "icon": "sofa.png"},
      {"title": "More", "icon": "more.png"},
    ];
    return SizedBox(
      width: double.infinity,
      child: Wrap(
        spacing: 8,
        runSpacing: 6,
        children: [
          for (int i = 0; i < categoryData.length; i++)
            Padding(
              padding: const EdgeInsets.only(top: 15, left: 15, right: 15),
              child: Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  color: selectedFilterIndex == i
                      ? const Color.fromARGB(255, 227, 207, 54)
                      : const Color.fromARGB(255, 227, 207, 54),
                  borderRadius: BorderRadius.circular(35),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      onPressed: () {
                        String title = categoryData[i]['title']!;

                        // Using the provided callback instead of setState locally
                        onFilterChanged(i, title);

                        Navigator.pushNamed(
                          context,
                          BaseRoute.filterProduct,
                          arguments: title,
                        ).then((_) {
                          // Reset to "All" category automatically when returning
                          onFilterChanged(0, 'All');
                        });
                      },
                      icon: Image.asset(
                        "icons/${categoryData[i]['icon']}",
                        height: 40,
                        width: 40,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
