import 'dart:async';
import 'dart:convert';
import 'package:demo_interview/Class/home_iconcategory.dart';
import 'package:demo_interview/constant.dart';
import 'package:demo_interview/Route/base_routes.dart';
import 'package:demo_interview/Base_Url/base_url.dart';
import 'package:demo_interview/Controllers/wishlist_controller.dart';
import 'package:demo_interview/Controllers/cart_controller.dart';
import 'package:demo_interview/Controllers/profile_controller.dart';
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
  List<dynamic> _hotProducts = [];
  bool _isLoadingHotProducts = true;
  int _currentPage = 0;
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

  List<dynamic> _products = [];
  bool _isLoadingProducts = true;
  bool _isFetchingMore = false;
  int _productCurrentPage = 1;
  int _productLastPage = 1;
  late ScrollController _scrollController;
  final WishlistController wishlistController = Get.find();
  final CartController cartController = Get.find();
  final ProfileController profileController = Get.find();

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 0, viewportFraction: 0.9);

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
    profileController.fetchProfile();

    // Fetch Hot Products
    _fetchHotProducts();

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
      } else if (response.statusCode == 401) {
        BaseUrl.handleUnauthorized();
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

  Future<void> _fetchHotProducts() async {
    if (mounted) setState(() => _isLoadingHotProducts = true);

    try {
      final String? token = await BaseUrl.getToken();
      final response = await http
          .get(
            Uri.parse(BaseUrl.hotProductUrl),
            headers: {
              'Authorization': 'Bearer ${token ?? ""}',
              'Accept': 'application/json',
            },
          )
          .timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (mounted) {
          setState(() {
            _hotProducts = data['data'] ?? data['products'] ?? data;
            _isLoadingHotProducts = false;
          });
        }
      } else if (response.statusCode == 401) {
        BaseUrl.handleUnauthorized();
      } else {
        if (mounted) setState(() => _isLoadingHotProducts = false);
      }
    } catch (e) {
      debugPrint("Error fetching hot products: $e");
      if (mounted) setState(() => _isLoadingHotProducts = false);
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
    if (_hotProducts.isEmpty) return;
    _autoScrollTimer = Timer.periodic(const Duration(milliseconds: 2500), (
      timer,
    ) {
      if (_currentPage < _hotProducts.length - 1) {
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
      profileController.fetchProfile(),
      _fetchHotProducts(),
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
              buildHeader(context),
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
  Widget buildHeader(BuildContext context) {
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
                Obx(
                  () => AnimatedSwitcher(
                    duration: const Duration(milliseconds: 500),
                    child: Text(
                      profileController.isLoading.value
                          ? 'Hi...'
                          : 'Hi ${profileController.userName}!',
                      key: ValueKey(
                        profileController.isLoading.value
                            ? 'loading'
                            : 'loaded',
                      ),
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(
                            color: Colors.white,
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ),
                ),
                const Spacer(),
                InkWell(
                  onTap: () {
                    Navigator.pushNamed(context, BaseRoute.profile);
                  },
                  child: Obx(
                    () => profileController.isLoading.value
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
                                image:
                                    profileController.imageUrl.value.isNotEmpty
                                    ? NetworkImage(
                                        profileController.imageUrl.value,
                                      )
                                    : const AssetImage('icons/adwords.png')
                                          as ImageProvider,
                                fit: BoxFit.cover,
                              ),
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
    if (_isLoadingHotProducts) {
      return Shimmer.fromColors(
        baseColor: Colors.grey[300]!,
        highlightColor: Colors.grey[100]!,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Container(
            height: 220,
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              color: Colors.white,
            ),
          ),
        ),
      );
    }

    if (_hotProducts.isEmpty) return const SizedBox.shrink();

    return Column(
      children: [
        SizedBox(
          height: 220,
          width: double.infinity,
          child: PageView.builder(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() {
                _currentPage = index;
              });
              _startAutoScroll();
            },
            itemCount: _hotProducts.length,
            itemBuilder: (context, index) {
              final product = _hotProducts[index];
              final String? imageUrl =
                  product['image']?.toString() ??
                  product['image_url']?.toString() ??
                  product['product_image']?.toString();

              final String fullImageUrl = BaseUrl.getFullImageUrl(imageUrl);
              final String heroTag =
                  'hot_product_${product['id'] ?? product['_id'] ?? index}_$index';

              return AnimatedBuilder(
                animation: _pageController,
                builder: (context, child) {
                  double value = 1.0;
                  if (_pageController.position.haveDimensions) {
                    value = (_pageController.page! - index);
                    value = (1 - (value.abs() * 0.3)).clamp(0.0, 1.0);
                  } else {
                    // Handle initial state before first frame
                    value = index == _currentPage ? 1.0 : 0.8;
                  }

                  return Transform(
                    transform: Matrix4.identity()
                      ..setEntry(3, 2, 0.001) // perspective
                      ..rotateY(
                        (1 - value) *
                            (index > (_pageController.page ?? 0) ? -0.5 : 0.5),
                      )
                      ..scale(value),
                    alignment: Alignment.center,
                    child: child,
                  );
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 5,
                    vertical: 10,
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(28),
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.12),
                          offset: const Offset(0, 8),
                          blurRadius: 20,
                        ),
                      ],
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () => _navigateToProductDetail(product, heroTag),
                        borderRadius: BorderRadius.circular(28),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(28),
                          child: Stack(
                            fit: StackFit.expand,
                            children: [
                              Hero(
                                tag: heroTag,
                                child: fullImageUrl.isNotEmpty
                                    ? Image.network(
                                        fullImageUrl,
                                        fit: BoxFit.cover,
                                        errorBuilder:
                                            (context, error, stackTrace) =>
                                                const Icon(
                                                  Icons.broken_image,
                                                  size: 50,
                                                ),
                                      )
                                    : const Icon(Icons.image, size: 50),
                              ),
                              // Subtle Overlay for text readability
                              Container(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      Colors.black.withOpacity(0.5),
                                      Colors.transparent,
                                    ],
                                    begin: Alignment.bottomCenter,
                                    end: Alignment.topCenter,
                                  ),
                                ),
                              ),
                              Positioned(
                                left: 24,
                                bottom: 30,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    _buildPulsingBadge(),
                                    const SizedBox(height: 10),
                                    Text(
                                      product['title']?.toString() ??
                                          product['name']?.toString() ??
                                          "Special Offer",
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                        shadows: [
                                          Shadow(
                                            color: Colors.black45,
                                            offset: Offset(0, 2),
                                            blurRadius: 10,
                                          ),
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
            _hotProducts.length,
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
      onEnd: () {},
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
    return const SizedBox(
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
    );
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
            color: Colors.black.withOpacity(0.05),
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
                                id ?? "",
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
                                onTap: () {
                                  final String? productId =
                                      product['id']?.toString() ??
                                      product['_id']?.toString();
                                  if (productId != null) {
                                    Navigator.pushNamed(
                                      context,
                                      BaseRoute.addToCart,
                                    );
                                    cartController.addToCart(
                                      productId: productId,
                                      qty: 1,
                                    );
                                  }
                                },
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
          color: color.withOpacity(0.1),
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
