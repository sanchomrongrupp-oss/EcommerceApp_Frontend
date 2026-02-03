import 'package:demo_interview/constant.dart';
import 'package:demo_interview/Route/base_routes.dart';
import 'package:flutter/material.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  int _selectedFilterIndex = 0;
  bool _isFavorite = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            builheader(context),
            const SizedBox(height: 20),
            Column(
              children: [
                buildSectionTitle("Special Product"),
                const SizedBox(height: 5),
                buildHotproduct(),
                buildCategoryicon(),
              ],
            ),
            const SizedBox(height: 15),
            buildSectionTitle("Most Popular"),
            Column(children: [buildFilterButton(), buildProductList()]),
          ],
        ),
      ),
    );
  }

  //Header of App
  Widget builheader(BuildContext context) {
    return Stack(
      children: <Widget>[
        Container(
          height: 105,
          width: double.infinity,
          decoration: const BoxDecoration(
            color: Color.fromARGB(255, 227, 207, 54),
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(36),
              bottomRight: Radius.circular(36),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.only(left: 10, right: 10, bottom: 40),
            child: Row(
              children: [
                Text(
                  'Hi Rong!',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: Colors.white,
                    fontSize: 40,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                const CircleAvatar(
                  backgroundImage: AssetImage('icons/adwords.png'),
                  radius: 35,
                ),
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 75),
          child: Center(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              height: 54,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black26, // Added color for visibility
                    offset: Offset(0, 10),
                    blurRadius: 50, // Reduced blur radius for better effect
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.only(left: 10),
                child: TextField(
                  decoration: InputDecoration(
                    hintText: "Search",
                    hintStyle: const TextStyle(
                      color: Color.fromARGB(255, 194, 193, 193),
                    ),
                    border: InputBorder.none, // Removes default border
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    suffixIcon: Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Image.asset(
                        "icons/search.png",
                        height: 40,
                        width: 40,
                      ),
                    ),
                    contentPadding: const EdgeInsets.symmetric(vertical: 15),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  //New or Hor Product
  Widget buildHotproduct() {
    return SizedBox(
      height: 170, // Constrains ListView height
      width: double.infinity,
      child: ListView(
        scrollDirection: Axis.horizontal, // Enable horizontal scrolling
        children: List.generate(10, (index) {
          return Padding(
            padding: const EdgeInsets.only(left: 15),
            child: Container(
              width: 350, // Width of each container
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: const Color.fromARGB(255, 227, 207, 54), // Color
              ),
              child: Center(
                child: Text(
                  'Item $index', // Display item number (or use other dynamic content)
                  style: const TextStyle(color: Colors.white, fontSize: 16),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  //Menu category
  Widget buildCategoryicon() {
    List listTitle = [
      {"title": "Shirt"},
      {"title": "Trousers"},
      {"title": "Shoe"},
      {"title": "Bag"},
      {"title": "Chair"},
      {"title": "Table"},
      {"title": "Sofa"},
      {"title": "More"},
    ];
    List listIcon = [
      {"icon": "shirt.png"},
      {"icon": "trousers.png"},
      {"icon": "sport-shoe.png"},
      {"icon": "briefcase.png"},
      {"icon": "swivel-chair.png"},
      {"icon": "table.png"},
      {"icon": "sofa.png"},
      {"icon": "more.png"},
    ];
    return SizedBox(
      width: double.infinity,
      child: Wrap(
        spacing: 16,
        runSpacing: 10,
        children: [
          for (int i = 0; i < listTitle.length; i++)
            Padding(
              padding: const EdgeInsets.only(top: 15, left: 15, right: 15),
              child: Container(
                width: 70, // Set the width of the container
                height: 70, // Set the height of the container
                decoration: BoxDecoration(
                  color: const Color.fromARGB(255, 227, 207, 54),
                  borderRadius: BorderRadius.circular(35),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      onPressed: () {},
                      icon: Image.asset(
                        "icons/${listIcon[i]['icon']}",
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

  //Title Text
  Widget buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 15, right: 15),
      child: kRow(title),
    );
  }

  //Category filter
  Widget buildCategoryFilterList() {
    return SizedBox(
      height: 40,
      child: Center(child: Text("Categories cleared")),
    );
  }

  //Product list
  Widget buildProductGrid() {
    return Wrap(
      spacing: 8.0, // Horizontal space
      runSpacing: 8.0, // Vertical space
      children: const [Center(child: Text("Product list cleared"))],
    );
  }

  //Filter button Popular
  Widget buildFilterButton() {
    final List<String> listButton = [
      "All",
      "Shirt",
      "Trousers",
      "Shoe",
      "Bag",
      "Chair",
      "Table",
      "Sofa",
      "More",
    ];
    return Padding(
      padding: const EdgeInsets.only(left: 15, right: 15),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: listButton
              .asMap()
              .entries
              .map(
                (entry) => Padding(
                  padding: const EdgeInsets.only(right: 15),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _selectedFilterIndex == entry.key
                          ? const Color.fromARGB(255, 227, 207, 54)
                          : Colors.grey[200],
                      foregroundColor: _selectedFilterIndex == entry.key
                          ? Colors.white
                          : Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    onPressed: () {
                      setState(() {
                        _selectedFilterIndex = entry.key;
                      });
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

  //Product list Popular
  Widget buildProductList() {
    return Padding(
      padding: const EdgeInsets.all(15.0),
      child: GestureDetector(
        onTap: () {
          Navigator.pushNamed(context, BaseRoute.productDetail);
        },
        child: Container(
          height: 140,
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: const Color.fromARGB(255, 227, 207, 54),
          ),
          child: Row(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  height: 120,
                  width: 120,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: Colors.white,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Product Name",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      "\$100.00",
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              Spacer(),
              Padding(
                padding: EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    IconButton(
                      onPressed: () {
                        setState(() {
                          _isFavorite = !_isFavorite;
                        });
                      },
                      icon: Image.asset(
                        "icons/heart.png",
                        height: 25,
                        width: 25,
                        color: _isFavorite ? Colors.red : null,
                      ),
                    ),
                    Spacer(),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        fixedSize: Size(80, 40),
                      ),
                      onPressed: () {},
                      child: Text("Buy"),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
