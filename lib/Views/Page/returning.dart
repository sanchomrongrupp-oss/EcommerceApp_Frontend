import 'package:flutter/material.dart';

class ReturningScreen extends StatefulWidget {
  const ReturningScreen({super.key});

  @override
  State<ReturningScreen> createState() => _ReturningScreenState();
}

class _ReturningScreenState extends State<ReturningScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const kMainColor = Color.fromARGB(255, 227, 207, 54);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text(
          "Returns & Refunds",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        backgroundColor: kMainColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.black,
          unselectedLabelColor: Colors.black54,
          indicatorColor: Colors.black,
          indicatorWeight: 3,
          tabs: const [
            Tab(text: "Active Returns"),
            Tab(text: "History"),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [_buildActiveReturns(), _buildReturnHistory()],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: kMainColor,
        onPressed: () {},
        label: const Text(
          "Start Return",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        icon: const Icon(Icons.add, color: Colors.black),
      ),
    );
  }

  Widget _buildActiveReturns() {
    // Mock data for active returns
    final activeReturns = [
      {
        "id": "RET-2401-08",
        "product": "Nike Air Max 270",
        "status": "In Transit",
        "step": 2, // 1: Requested, 2: Picked, 3: Refunded
        "price": "\$120.00",
        "image":
            "https://img.freepik.com/free-photo/running-shoes-white-background_10541-635.jpg",
      },
    ];

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: activeReturns.length,
      itemBuilder: (context, index) {
        return _ReturnCard(data: activeReturns[index], isActive: true);
      },
    );
  }

  Widget _buildReturnHistory() {
    // Mock data for return history
    final history = [
      {
        "id": "RET-2311-45",
        "product": "Gaming Mouse G-Pro",
        "status": "Refunded",
        "step": 3,
        "price": "\$55.00",
        "image":
            "https://img.freepik.com/free-photo/modern-gaming-mouse_23-2149229158.jpg",
      },
      {
        "id": "RET-2310-12",
        "product": "Wireless Keyboard",
        "status": "Rejected",
        "step": 3,
        "price": "\$89.99",
        "image":
            "https://img.freepik.com/free-photo/computer-keyboard-white-background_1203-3453.jpg",
      },
    ];

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: history.length,
      itemBuilder: (context, index) {
        return _ReturnCard(data: history[index], isActive: false);
      },
    );
  }
}

class _ReturnCard extends StatelessWidget {
  final Map<String, dynamic> data;
  final bool isActive;

  const _ReturnCard({required this.data, required this.isActive});

  @override
  Widget build(BuildContext context) {
    Color statusColor = data['status'] == 'Rejected'
        ? Colors.red
        : Colors.green;
    if (data['status'] == 'In Transit') statusColor = Colors.blue;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Return ID: ${data['id']}",
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    data['status'],
                    style: TextStyle(
                      color: statusColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    data['image'],
                    width: 60,
                    height: 60,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      width: 60,
                      height: 60,
                      color: Colors.grey[200],
                      child: const Icon(Icons.image),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        data['product'],
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        "Refund: ${data['price']}",
                        style: const TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (isActive) ...[
              const SizedBox(height: 20),
              _buildProgressTracker(data['step']),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () {},
                  style: OutlinedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    "View Details",
                    style: TextStyle(color: Colors.black),
                  ),
                ),
              ),
            ] else ...[
              const SizedBox(height: 16),
              const Divider(),
              TextButton(
                onPressed: () {},
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("Support Help", style: TextStyle(color: Colors.blue)),
                    Icon(Icons.chevron_right, color: Colors.blue, size: 20),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildProgressTracker(int currentStep) {
    return Row(
      children: [
        _buildStepIndicator("Requested", currentStep >= 1),
        _buildLine(currentStep >= 2),
        _buildStepIndicator("Picked", currentStep >= 2),
        _buildLine(currentStep >= 3),
        _buildStepIndicator("Refunded", currentStep >= 3),
      ],
    );
  }

  Widget _buildStepIndicator(String label, bool isDone) {
    return Column(
      children: [
        CircleAvatar(
          radius: 10,
          backgroundColor: isDone
              ? const Color.fromARGB(255, 227, 207, 54)
              : Colors.grey[300],
          child: isDone
              ? const Icon(Icons.check, size: 12, color: Colors.black)
              : null,
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: isDone ? Colors.black : Colors.grey,
          ),
        ),
      ],
    );
  }

  Widget _buildLine(bool isDone) {
    return Expanded(
      child: Container(
        height: 2,
        margin: const EdgeInsets.only(bottom: 15),
        color: isDone
            ? const Color.fromARGB(255, 227, 207, 54)
            : Colors.grey[300],
      ),
    );
  }
}
