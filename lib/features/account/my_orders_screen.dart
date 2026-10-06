import 'package:cartiva/features/notifications/notifications_screen.dart';
import 'package:flutter/material.dart';

class Order {
  final String name;
  final String size;
  final String price;
  final String status;
  final String imageUrl;
  double? rating;

  Order({
    required this.name,
    required this.size,
    required this.price,
    required this.status,
    required this.imageUrl,
    this.rating,
  });
}

final ongoingOrders = <Order>[
  Order(
    name: 'Regular Fit Slogan',
    size: 'M',
    price: '1,190',
    status: 'In Transit',
    imageUrl: 'https://picsum.photos/seed/11/200/200',
  ),
  Order(
    name: 'Regular Fit Polo',
    size: 'L',
    price: '1,100',
    status: 'Picked',
    imageUrl: 'https://picsum.photos/seed/12/200/200',
  ),
  Order(
    name: 'Regular Fit Black',
    size: 'L',
    price: '1,690',
    status: 'In Transit',
    imageUrl: 'https://picsum.photos/seed/13/200/200',
  ),
  Order(
    name: 'Regular Fit V-Neck',
    size: 'S',
    price: '1,290',
    status: 'Packing',
    imageUrl: 'https://picsum.photos/seed/14/200/200',
  ),
  Order(
    name: 'Regular Fit Pink',
    size: 'M',
    price: '1,341',
    status: 'Picked',
    imageUrl: 'https://picsum.photos/seed/15/200/200',
  ),
];

final completedOrders = <Order>[
  Order(
    name: 'Regular Fit Slogan',
    size: 'M',
    price: '1,190',
    status: 'Completed',
    imageUrl: 'https://picsum.photos/seed/21/200/200',
  ),
  Order(
    name: 'Regular Fit Polo',
    size: 'L',
    price: '1,100',
    status: 'Completed',
    imageUrl: 'https://picsum.photos/seed/22/200/200',
    rating: 4.5,
  ),
  Order(
    name: 'Regular Fit Black',
    size: 'L',
    price: '1,690',
    status: 'Completed',
    imageUrl: 'https://picsum.photos/seed/23/200/200',
  ),
  Order(
    name: 'Regular Fit V-Neck',
    size: 'S',
    price: '1,290',
    status: 'Completed',
    imageUrl: 'https://picsum.photos/seed/24/200/200',
  ),
  Order(
    name: 'Regular Fit Pink',
    size: 'M',
    price: '1,341',
    status: 'Completed',
    imageUrl: 'https://picsum.photos/seed/25/200/200',
    rating: 3.5,
  ),
];

class MyOrdersScreen extends StatefulWidget {
  const MyOrdersScreen({super.key});

  @override
  State<MyOrdersScreen> createState() => _MyOrdersScreenState();
}

class _MyOrdersScreenState extends State<MyOrdersScreen> {
  Future<void> _openReviewSheet(Order order) async {
    final rating = await showModalBottomSheet<int>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      backgroundColor: Colors.white,
      builder: (_) => const ReviewSheet(),
    );

    if (rating != null && mounted) {
      setState(() => order.rating = rating.toDouble());
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      initialIndex: 1,
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            tooltip: 'Back',
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.maybePop(context),
          ),
          title: const Text(
            'My Orders',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700),
          ),
          centerTitle: true,
          actions: [
            IconButton(
              tooltip: 'Notifications',
              icon: const Icon(Icons.notifications_none),
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const NotificationsScreen(),
                  ),
                );
              },
            ),
          ],
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.transparent,
        ),
        body: Column(
          children: [
            const OrdersTabBar(),
            Expanded(
              child: TabBarView(
                children: [
                  OrdersList(
                    orders: ongoingOrders,
                    emptyTitle: 'No Ongoing Orders!',
                    emptyMessage: "You don't have any ongoing orders\nat this time.",
                  ),
                  CompletedOrdersList(
                    orders: completedOrders,
                    onLeaveReview: _openReviewSheet,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class OrdersTabBar extends StatelessWidget {
  const OrdersTabBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(24, 8, 24, 16),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: const Color(0xFFE8E8E8),
        borderRadius: BorderRadius.circular(12),
      ),
      child: TabBar(
        indicator: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        dividerColor: Colors.transparent,
        overlayColor: WidgetStateProperty.all(Colors.transparent),
        labelColor: Colors.black,
        unselectedLabelColor: Colors.grey,
        labelStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        tabs: const [
          Tab(text: 'Ongoing'),
          Tab(text: 'Completed'),
        ],
      ),
    );
  }
}

class OrdersList extends StatelessWidget {
  final List<Order> orders;
  final String emptyTitle;
  final String emptyMessage;

  const OrdersList({
    super.key,
    required this.orders,
    required this.emptyTitle,
    required this.emptyMessage,
  });

  @override
  Widget build(BuildContext context) {
    if (orders.isEmpty) {
      return EmptyOrders(title: emptyTitle, message: emptyMessage);
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
      itemCount: orders.length,
      separatorBuilder: (_, _) => const SizedBox(height: 16),
      itemBuilder: (context, index) => OrderCard(order: orders[index]),
    );
  }
}

class CompletedOrdersList extends StatelessWidget {
  final List<Order> orders;
  final ValueChanged<Order> onLeaveReview;

  const CompletedOrdersList({
    super.key,
    required this.orders,
    required this.onLeaveReview,
  });

  @override
  Widget build(BuildContext context) {
    if (orders.isEmpty) {
      return const EmptyOrders(
        title: 'No Completed Orders!',
        message: "You don't have any completed orders\nat this time.",
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
      itemCount: orders.length,
      separatorBuilder: (_, _) => const SizedBox(height: 16),
      itemBuilder: (context, index) {
        final order = orders[index];
        return CompletedOrderCard(
          order: order,
          onLeaveReview: () => onLeaveReview(order),
        );
      },
    );
  }
}

class OrderCard extends StatelessWidget {
  final Order order;

  const OrderCard({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFE5E5E5)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: Image.network(
              order.imageUrl,
              width: 80,
              height: 76,
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) => Container(
                width: 80,
                height: 76,
                color: const Color(0xFFF1F1F1),
                child: const Icon(
                  Icons.image_not_supported_outlined,
                  color: Colors.grey,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        order.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    StatusChip(label: order.status),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  'Size ${order.size}',
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '\$ ${order.price}',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    FilledButton(
                      onPressed: () {},
                      style: FilledButton.styleFrom(
                        backgroundColor: const Color(0xFF1A1A1A),
                        foregroundColor: Colors.white,
                        minimumSize: Size.zero,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 10,
                        ),
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                      child: const Text(
                        'Track Order',
                        style: TextStyle(fontSize: 11),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class StatusChip extends StatelessWidget {
  final String label;

  const StatusChip({super.key, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(left: 8),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFEDEDED),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(label, style: const TextStyle(fontSize: 10)),
    );
  }
}

class CompletedOrderCard extends StatelessWidget {
  final Order order;
  final VoidCallback onLeaveReview;

  const CompletedOrderCard({
    super.key,
    required this.order,
    required this.onLeaveReview,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFE5E5E5)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          OrderImage(imageUrl: order.imageUrl),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        order.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const CompletedChip(),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  'Size ${order.size}',
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '\$ ${order.price}',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    if (order.rating == null)
                      SmallActionButton(
                        label: 'Leave Review',
                        onPressed: onLeaveReview,
                      )
                    else
                      RatingBadge(rating: order.rating!),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class OrderImage extends StatelessWidget {
  final String imageUrl;

  const OrderImage({super.key, required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(4),
      child: Image.network(
        imageUrl,
        width: 80,
        height: 76,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => Container(
          width: 80,
          height: 76,
          color: const Color(0xFFF1F1F1),
          child: const Icon(Icons.image_not_supported_outlined, color: Colors.grey),
        ),
      ),
    );
  }
}

class SmallActionButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;

  const SmallActionButton({
    super.key,
    required this.label,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return FilledButton(
      onPressed: onPressed,
      style: FilledButton.styleFrom(
        backgroundColor: const Color(0xFF1A1A1A),
        foregroundColor: Colors.white,
        minimumSize: Size.zero,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
      ),
      child: Text(label, style: const TextStyle(fontSize: 11)),
    );
  }
}

class CompletedChip extends StatelessWidget {
  const CompletedChip({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(left: 8),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFE3F5E3),
        borderRadius: BorderRadius.circular(4),
      ),
      child: const Text(
        'Completed',
        style: TextStyle(fontSize: 10, color: Color(0xFF2E9E3E)),
      ),
    );
  }
}

class RatingBadge extends StatelessWidget {
  final double rating;

  const RatingBadge({super.key, required this.rating});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFFDDDDDD)),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.star, size: 14, color: Colors.orange),
          const SizedBox(width: 4),
          Text(
            '${rating.toStringAsFixed(1)}/5',
            style: const TextStyle(fontSize: 11),
          ),
        ],
      ),
    );
  }
}

class ReviewSheet extends StatefulWidget {
  const ReviewSheet({super.key});

  @override
  State<ReviewSheet> createState() => _ReviewSheetState();
}

class _ReviewSheetState extends State<ReviewSheet> {
  int _rating = 0;
  final _reviewController = TextEditingController();

  @override
  void dispose() {
    _reviewController.dispose();
    super.dispose();
  }

  void _submit() {
    debugPrint('Rating: $_rating, Review: ${_reviewController.text}');
    Navigator.pop(context, _rating);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Leave a Review',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
              ),
              IconButton(
                tooltip: 'Close',
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const Divider(height: 1),
          const SizedBox(height: 16),
          const Text(
            'How was your order?',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 4),
          const Text(
            'Please give your rating and also your review.',
            style: TextStyle(fontSize: 13, color: Colors.grey),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(5, (index) {
              final starNumber = index + 1;
              return IconButton(
                tooltip: '$starNumber star${starNumber == 1 ? '' : 's'}',
                iconSize: 40,
                color: Colors.orange,
                icon: Icon(
                  starNumber <= _rating ? Icons.star : Icons.star_border,
                ),
                onPressed: () => setState(() => _rating = starNumber),
              );
            }),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _reviewController,
            maxLines: 4,
            decoration: InputDecoration(
              hintText: 'Write your review...',
              hintStyle: const TextStyle(color: Colors.grey),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Color(0xFFDDDDDD)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Color(0xFFDDDDDD)),
              ),
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: _rating == 0 ? null : _submit,
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF1A1A1A),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('Submit', style: TextStyle(fontSize: 16)),
            ),
          ),
        ],
      ),
    );
  }
}

class EmptyOrders extends StatelessWidget {
  final String title;
  final String message;

  const EmptyOrders({
    super.key,
    required this.title,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.inventory_2_outlined,
            size: 64,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey.shade500,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}