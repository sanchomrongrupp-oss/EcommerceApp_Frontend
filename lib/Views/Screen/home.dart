import 'dart:async';
import 'package:demo_interview/constant.dart';
import 'package:demo_interview/Route/base_routes.dart';
import 'package:flutter/material.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> with TickerProviderStateMixin {
  int _selectedFilterIndex = 0;
  bool _isFavorite = false;

  late PageController _pageController;
  late AnimationController _rotationController;
  Timer? _autoScrollTimer;
  int _currentPage = 0;
  final int _hotItemsCount = 5;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 0);

    // Rotation Animation for product images
    _rotationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    )..repeat();

    // Auto-scroll Timer
    _startAutoScroll();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _rotationController.dispose();
    _autoScrollTimer?.cancel();
    super.dispose();
  }

  void _startAutoScroll() {
    _autoScrollTimer?.cancel();
    _autoScrollTimer = Timer.periodic(const Duration(milliseconds: 2500), (
      timer,
    ) {
      if (_currentPage < _hotItemsCount - 1) {
        _currentPage++;
      } else {
        _currentPage = 0;
      }

      if (_pageController.hasClients) {
        _pageController.animateToPage(
          _currentPage,
          duration: const Duration(milliseconds: 800),
          curve: Curves.easeInOut,
        );
      }
    });
  }

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
                InkWell(
                  onTap: () {
                    Navigator.pushNamed(context, BaseRoute.profile);
                  },
                  child: CircleAvatar(
                    backgroundImage: AssetImage('icons/adwords.png'),
                    radius: 35,
                  ),
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
      height: 180,
      width: double.infinity,
      child: PageView.builder(
        controller: _pageController,
        onPageChanged: (index) {
          setState(() {
            _currentPage = index;
          });
          _startAutoScroll(); // Reset timer on manual scroll
        },
        itemCount: _hotItemsCount,
        itemBuilder: (context, index) {
          return TweenAnimationBuilder(
            duration: Duration(milliseconds: 400),
            tween: Tween<double>(begin: 0.9, end: 1.0),
            builder: (context, double value, child) {
              return Transform.scale(scale: value, child: child);
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              child: Container(
                width: 320,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  gradient: LinearGradient(
                    colors: [
                      const Color.fromARGB(255, 227, 207, 54),
                      const Color.fromARGB(255, 245, 230, 100),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      offset: const Offset(0, 4),
                      blurRadius: 10,
                    ),
                  ],
                ),
                child: Stack(
                  children: [
                    Positioned(
                      right: -20,
                      bottom: -20,
                      child: Opacity(
                        opacity: 0.3,
                        child: Icon(
                          Icons.flash_on,
                          size: 150,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Row(
                        children: [
                          Expanded(
                            flex: 3,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                _buildPulsingBadge(),
                                const SizedBox(height: 8),
                                Text(
                                  "Special Edition ${index + 1}",
                                  style: const TextStyle(
                                    color: Colors.black,
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                const Text(
                                  "Limited Time Offer",
                                  style: TextStyle(
                                    color: Colors.black54,
                                    fontSize: 14,
                                  ),
                                ),
                                const SizedBox(height: 12),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildPulsingBadge() {
    return TweenAnimationBuilder(
      duration: const Duration(seconds: 1),
      tween: Tween<double>(begin: 0.8, end: 1.2),
      curve: Curves.easeInOut,
      builder: (context, double value, child) {
        return Transform.scale(
          scale: value,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.redAccent,
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Text(
              "HOT",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
        );
      },
      onEnd: () {
        // This is a simple trick to restart the animation without a controller
        // However, in a real app, a proper AnimationController is better for infinite loops.
      },
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
                      onPressed: () {
                        Navigator.pushNamed(
                          context,
                          BaseRoute.filterProduct,
                          arguments: listTitle[i]['title'],
                        );
                      },
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
                      onPressed: () {
                        setState(() {
                          Navigator.pushNamed(context, BaseRoute.productDetail);
                        });
                      },
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
