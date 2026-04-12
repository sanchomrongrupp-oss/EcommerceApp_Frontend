import 'dart:async';
import 'dart:convert';
import 'package:demo_interview/Class/home_iconcategory.dart';
import 'package:demo_interview/constant.dart';
import 'package:demo_interview/Route/base_routes.dart';
import 'package:demo_interview/Base_Url/base_url.dart';
import 'package:demo_interview/Controllers/wishlist_controller.dart';
import 'package:demo_interview/Class/home_buttomfilltercategory.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:shimmer/shimmer.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> with TickerProviderStateMixin {
  int _selectedFilterIndex = 0;

  late PageController _pageController;
  late AnimationController _rotationController;
  Timer? _autoScrollTimer;
  int _currentPage = 0;
  final int _hotItemsCount = 10;
  final List<String> _categories = [
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

  List<String> get _categoriesicon => _categories.map((e) => "$e.png").toList();
  String _imageProfileUrl = "";
  String _firstName = "";
  String _lastName = "";
  String get _userName => "$_firstName $_lastName".trim().isEmpty
      ? "User"
      : "$_firstName $_lastName".trim();
  bool _isLoadingProfile = true;
  String wrapEvery15Words(String text) {
    List<String> words = text.split(' ');
    List<String> lines = [];

    for (int i = 0; i < words.length; i += 15) {
      int end = (i + 15 < words.length) ? i + 15 : words.length;
      lines.add(words.sublist(i, end).join(' '));
    }

    return lines.join('\n'); // insert newline after every 15 words
  }

  List<dynamic> _products = [];
  bool _isLoadingProducts = true;
  bool _isFetchingMore = false;
  int _productCurrentPage = 1;
  int _productLastPage = 1;
  late ScrollController _scrollController;
  final WishlistController wishlistController = Get.find();

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

    // Initialize Scroll Controller
    _scrollController = ScrollController()..addListener(_onScroll);

    // Fetch Profile
    _fetchProfile();

    // Fetch Products (initial page)
    _fetchProducts();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 200 &&
        !_isFetchingMore &&
        !_isLoadingProducts &&
        _productCurrentPage < _productLastPage) {
      _fetchProducts(page: _productCurrentPage + 1);
    }
  }

  Future<void> _fetchProducts({String? category, int page = 1}) async {
    if (page == 1) {
      if (mounted) setState(() => _isLoadingProducts = true);
      _productCurrentPage = 1;
    } else {
      if (mounted) setState(() => _isFetchingMore = true);
    }

    try {
      final String? token = await BaseUrl.getToken();
      String url = BaseUrl.productUrl;

      // Ensure we use the correct category
      String activeCategory =
          category ??
          _categories[_selectedFilterIndex > 0 ? _selectedFilterIndex : 0];

      if (activeCategory != "All") {
        url = "$url?category=${activeCategory.toLowerCase()}";
        url += "&per_page=10&page=$page";
      } else {
        url = "$url?per_page=10&page=$page";
      }

      debugPrint("Fetching products from: $url");

      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer ${token ?? ""}',
          'Accept': 'application/json',
        },
      );

      debugPrint("Products Status Code: ${response.statusCode}");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        debugPrint("Products Response: $data");

        if (mounted) {
          setState(() {
            // Robustly extract product list
            final dynamic rawProducts =
                data['data'] ?? data['products'] ?? data;
            List<dynamic> newProducts = [];
            if (rawProducts is List) {
              newProducts = rawProducts;
            } else if (rawProducts is Map && rawProducts['data'] is List) {
              newProducts = rawProducts['data'];
            }

            if (page == 1) {
              _products = newProducts;
            } else {
              _products.addAll(newProducts);
            }

            // Update pagination metadata
            final pagination = data['pagination'];
            if (pagination != null) {
              _productCurrentPage = pagination['current_page'] ?? page;
              _productLastPage = pagination['last_page'] ?? 1;
            }

            _isLoadingProducts = false;
            _isFetchingMore = false;
          });
        }
      } else {
        debugPrint("Products Error: ${response.body}");
        if (mounted) {
          setState(() {
            _isLoadingProducts = false;
            _isFetchingMore = false;
          });
        }
      }
    } catch (e) {
      debugPrint("Error fetching products: $e");
      if (mounted) {
        setState(() {
          _isLoadingProducts = false;
          _isFetchingMore = false;
        });
      }
    }
  }

  Future<void> _fetchProfile() async {
    try {
      final String? token = await BaseUrl.getToken();
      if (token == null) {
        debugPrint("No profile token found");
        setState(() => _isLoadingProfile = false);
        return;
      }

      debugPrint("Fetching profile from: ${BaseUrl.profileUrl}");

      final response = await http.get(
        Uri.parse(BaseUrl.profileUrl),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      debugPrint("Profile Status Code: ${response.statusCode}");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        debugPrint("Profile Response: $data");

        // Extract name based on common structures
        final userData = data['data']?['user'] ?? data['user'] ?? data['data'];
        if (userData != null) {
          setState(() {
            _firstName = userData['first_name']?.toString() ?? "";
            _lastName = userData['last_name']?.toString() ?? "";
            _imageProfileUrl =
                userData['profile_image_url']?.toString() ??
                (userData['profile_image'] != null
                    ? "${BaseUrl.baseUrl}${userData['profile_image']}"
                    : "");

            _isLoadingProfile = false;
          });
        } else {
          debugPrint("User data not found in profile response");
          setState(() => _isLoadingProfile = false);
        }
      } else {
        debugPrint("Profile Error: ${response.statusCode} - ${response.body}");
        setState(() => _isLoadingProfile = false);
      }
    } catch (e) {
      debugPrint("Profile Catch Error: $e");
      setState(() => _isLoadingProfile = false);
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    _rotationController.dispose();
    _scrollController.dispose();
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

  Future<void> _refreshData() async {
    if (!mounted) return;
    setState(() {
      _selectedFilterIndex = 0;
      _isLoadingProducts = true;
    });
    // fetch all items
    await Future.wait([
      _fetchProfile(),
      _fetchProducts(category: 'All', page: 1),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: _refreshData,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          controller: _scrollController,
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
                  HomeIconCategory(
                    categoriesicon: _categoriesicon,
                    selectedFilterIndex: _selectedFilterIndex,
                    onFilterChanged: (index, category) {
                      setState(() {
                        _selectedFilterIndex = index;
                        _isLoadingProducts = true;
                      });
                      _fetchProducts(category: category);
                    },
                  ),
                ],
              ),
              const SizedBox(height: 15),
              buildSectionTitle("Most Popular"),
              Column(
                children: [
                  HomeBottomFilterCategory(
                    categories: _categories,
                    selectedFilterIndex: _selectedFilterIndex,
                    onFilterChanged: (index, category) {
                      setState(() {
                        _selectedFilterIndex = index;
                        _isLoadingProducts = true;
                      });
                      _fetchProducts(category: category);
                    },
                  ),
                  buildProductList(),
                  if (_isFetchingMore)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 20),
                      child: Center(child: CircularProgressIndicator()),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  //Header of App
  Widget builheader(BuildContext context) {
    return Stack(
      children: <Widget>[
        Container(
          height: 140,
          width: double.infinity,
          decoration: const BoxDecoration(
            color: Color.fromARGB(255, 227, 207, 54),
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(36),
              bottomRight: Radius.circular(36),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.only(left: 15, right: 15, bottom: 45),
            child: Row(
              children: [
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 500),
                  child: Text(
                    _isLoadingProfile ? 'Hi...' : 'Hi $_userName!',
                    key: ValueKey(_isLoadingProfile ? 'loading' : 'loaded'),
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const Spacer(),
                InkWell(
                  onTap: () {
                    Navigator.pushNamed(context, BaseRoute.profile);
                  },
                  child: _isLoadingProfile
                      ? Shimmer.fromColors(
                          baseColor: Colors.grey[300]!,
                          highlightColor: Colors.grey[100]!,
                          child: Container(
                            height: 80,
                            width: 80,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white,
                            ),
                          ),
                        )
                      : Container(
                          height: 80,
                          width: 80,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white,
                            border: Border.all(color: Colors.white, width: 2),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                            image: DecorationImage(
                              image: _imageProfileUrl.isNotEmpty
                                  ? NetworkImage(_imageProfileUrl)
                                  : const AssetImage('icons/adwords.png')
                                        as ImageProvider,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                ),
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 105),
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
    if (_isLoadingProducts) {
      return Shimmer.fromColors(
        baseColor: Colors.grey[300]!,
        highlightColor: Colors.grey[100]!,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          child: Container(
            height: 180,
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              color: Colors.white,
            ),
          ),
        ),
      );
    }
    return Column(
      children: [
        SizedBox(
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
                duration: const Duration(milliseconds: 400),
                tween: Tween<double>(begin: 0.9, end: 1.0),
                builder: (context, double value, child) {
                  return Transform.scale(scale: value, child: child);
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  child: Container(
                    width: 320,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(24),
                      gradient: LinearGradient(
                        colors: const [
                          Color.fromARGB(255, 227, 207, 54),
                          Color.fromARGB(255, 245, 230, 100),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          offset: const Offset(0, 4),
                          blurRadius: 10,
                        ),
                      ],
                    ),
                    child: Stack(
                      children: [
                        const Positioned(
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
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            _hotItemsCount,
            (index) => AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: const EdgeInsets.symmetric(horizontal: 4),
              height: 8,
              width: _currentPage == index ? 24 : 8,
              decoration: BoxDecoration(
                color: _currentPage == index
                    ? const Color.fromARGB(255, 227, 207, 54)
                    : Colors.grey.shade300,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ),
      ],
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

  // Navigation helper
  void _navigateToProductDetail(dynamic product, String heroTag) {
    // Create a copy of the product map and add the heroTag
    Map<String, dynamic> productWithTag = Map.from(product);
    productWithTag['heroTag'] = heroTag;

    Navigator.pushNamed(
      context,
      BaseRoute.productDetail,
      arguments: productWithTag,
    ).then((_) {
      _refreshData();
    });
  }

  // Individual Product Item Builder
  Widget _buildProductItem(dynamic product, int index) {
    final String title =
        product['title']?.toString() ??
        product['name']?.toString() ??
        'Product Name';

    final String price =
        product['price']?.toString() ??
        product['base_price']?.toString() ??
        '0.00';

    final String? id = product['id']?.toString() ?? product['_id']?.toString();

    final String? imageUrl =
        product['image']?.toString() ??
        product['image_url']?.toString() ??
        product['product_image']?.toString();

    final String fullImageUrl = BaseUrl.getFullImageUrl(imageUrl);
    final String heroTag = 'home_product_${id ?? title}_$index';

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            offset: const Offset(0, 4),
            blurRadius: 12,
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () => _navigateToProductDetail(product, heroTag),
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Row(
              children: [
                /// ================= IMAGE =================
                Hero(
                  tag: heroTag,
                  child: Container(
                    height: 120,
                    width: 120,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      color: Colors.grey[100],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: fullImageUrl.isNotEmpty
                          ? Image.network(
                              fullImageUrl,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                                  const Center(
                                    child: Icon(
                                      Icons.broken_image,
                                      size: 40,
                                      color: Colors.grey,
                                    ),
                                  ),
                              loadingBuilder:
                                  (context, child, loadingProgress) {
                                    if (loadingProgress == null) return child;
                                    return const Center(
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                      ),
                                    );
                                  },
                            )
                          : const Center(
                              child: Icon(
                                Icons.image,
                                size: 40,
                                color: Colors.grey,
                              ),
                            ),
                    ),
                  ),
                ),

                const SizedBox(width: 15),

                /// ================= INFO SECTION =================
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                          ),
                          GestureDetector(
                            onTap: () =>
                                wishlistController.toggleFavorite(product),
                            child: Obx(() {
                              final bool isFav = wishlistController.isFavorite(
                                id,
                              );
                              return CircleAvatar(
                                backgroundColor: Colors.grey[100],
                                child: Icon(
                                  isFav
                                      ? Icons.favorite
                                      : Icons.favorite_border_outlined,
                                  color: isFav ? Colors.red : Colors.grey[400],
                                  size: 22,
                                ),
                              );
                            }),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "Latest Collection",
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[500],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "\$$price",
                            style: const TextStyle(
                              fontSize: 19,
                              fontWeight: FontWeight.w900,
                              color: Color.fromARGB(255, 227, 207, 54),
                            ),
                          ),
                          Row(
                            children: [
                              _buildActionIcon(
                                label: "Cart",
                                color: Colors.green,
                                onTap: () => Navigator.pushNamed(
                                  context,
                                  BaseRoute.addToCart,
                                  arguments: product,
                                ).then((_) => _refreshData()),
                              ),
                              const SizedBox(width: 8),
                              _buildActionIcon(
                                label: "Buy",
                                color: Colors.deepOrange,
                                onTap: () =>
                                    _navigateToProductDetail(product, heroTag),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActionIcon({
    required Color color,
    required VoidCallback onTap,
    required String label,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.bold,
            fontSize: 13,
          ),
        ),
      ),
    );
  }

  //Product list Popular
  Widget buildProductList() {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 600),
      child: _isLoadingProducts
          ? Column(
              key: const ValueKey('skeletons'),
              children: List.generate(6, (index) => _buildProductSkeleton()),
            )
          : _products.isEmpty
          ? const Padding(
              key: ValueKey('empty'),
              padding: EdgeInsets.all(20.0),
              child: Center(child: Text("No products found")),
            )
          : Column(
              key: const ValueKey('products'),
              children: _products.asMap().entries.map((entry) {
                return _buildProductItem(entry.value, entry.key);
              }).toList(),
            ),
    );
  }

  Widget _buildProductSkeleton() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 8.0),
        child: Container(
          height: 140,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: Colors.white,
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
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(top: 20, left: 10, right: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(height: 18, width: 140, color: Colors.white),
                      const SizedBox(height: 12),
                      Container(height: 20, width: 80, color: Colors.white),
                      const Spacer(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Container(height: 30, width: 60, color: Colors.white),
                          const SizedBox(width: 8),
                          Container(height: 30, width: 60, color: Colors.white),
                        ],
                      ),
                      const SizedBox(height: 10),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
