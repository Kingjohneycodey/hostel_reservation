import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hostel_reservation/app_theme.dart';
import 'package:hostel_reservation/widgets/app_footer.dart';

const _kGreyText = Color(0xFF757575);
const _kGreenLight = Color(0xFF4CAF50);
const _kGreenPale = Color(0xFFE8F5E9);
const _kDark = Color(0xFF1A1A1A);

class ViewReviewsPage extends StatefulWidget {
  final String docId;
  final Map<String, dynamic> bookingData;
  final String hostelId;
  final String hostelName;
  final String roomName;
  final String imageUrl;

  const ViewReviewsPage({
    Key? key,
    required this.docId,
    required this.bookingData,
    required this.hostelId,
    required this.hostelName,
    required this.roomName,
    required this.imageUrl,
  }) : super(key: key);

  @override
  _ViewReviewsPageState createState() => _ViewReviewsPageState();
}

class _ViewReviewsPageState extends State<ViewReviewsPage> {
  Future<Map<String, dynamic>?> _loadLocalReview() async {
    final prefs = await SharedPreferences.getInstance();
    final json = prefs.getString('review_${widget.docId}');
    if (json == null) return null;
    final data = jsonDecode(json) as Map<String, dynamic>;
    // convert date string back to DateTime if necessary
    if (data['date'] is String) {
      try {
        data['date'] = DateTime.parse(data['date'] as String);
      } catch (_) {}
    }
    return data;
  }

  @override
  Widget build(BuildContext context) {
    // Dummy reviews to display alongside any local review
    final List<Map<String, dynamic>> dummyReviews = [
      {
        'userName': 'John',
        'rating': 4.5,
        'text':
            'Great hostel with comfortable rooms and friendly staff. Highly recommended!',
        'date': DateTime.now().subtract(const Duration(days: 15)),
        'isDummy': true,
      },
      {
        'userName': 'Kamzi',
        'rating': 4.8,
        'text':
            'Excellent facilities and very clean. The common area is perfect for socializing.',
        'date': DateTime.now().subtract(const Duration(days: 10)),
        'isDummy': true,
      },
      {
        'userName': 'Daniel',
        'rating': 4.3,
        'text':
            'Good location, nice atmosphere. Could improve the WiFi speed a bit.',
        'date': DateTime.now().subtract(const Duration(days: 5)),
        'isDummy': true,
      },
    ];

    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      bottomNavigationBar: const AppFooter(),
      appBar: AppBar(
        title: const Text('Reviews'),
        backgroundColor: AppTheme.primaryColor,
      ),
      body: Column(
        children: [
          // Booking Header Card
          Container(
            margin: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: _kGreenLight,
                width: 1.5,
              ),
            ),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.horizontal(
                    left: Radius.circular(10),
                  ),
                  child: widget.imageUrl.isNotEmpty
                      ? Image.network(
                          widget.imageUrl,
                          width: 72,
                          height: 72,
                          fit: BoxFit.cover,
                        )
                      : Container(
                          width: 72,
                          height: 72,
                          color: _kGreenPale,
                          child: Icon(
                            Icons.hotel_rounded,
                            color: AppTheme.primaryColor,
                          ),
                        ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.hostelName,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: _kDark,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          widget.roomName,
                          style: const TextStyle(
                            color: _kGreyText,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Reviews List
          Expanded(
            child: FutureBuilder<Map<String, dynamic>?>(
              future: _loadLocalReview(),
              builder: (context, localSnap) {
                if (localSnap.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(
                      color: AppTheme.primaryColor,
                    ),
                  );
                }

                final localReview = localSnap.data;
                final allReviews = [
                  if (localReview != null) localReview,
                  ...dummyReviews,
                ];

                if (allReviews.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.rate_review_outlined,
                          size: 48,
                          color: _kGreenLight,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'No reviews yet',
                          style: Theme.of(context)
                              .textTheme
                              .bodyMedium
                              ?.copyWith(color: _kGreyText),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: allReviews.length,
                  itemBuilder: (context, index) {
                    final review = allReviews[index];
                    return _ReviewCard(
                      userName: review['userName'] as String,
                      rating: review['rating'] as double,
                      text: review['text'] as String,
                      date: review['date'] as DateTime,
                      isDummy: review['isDummy'] as bool,
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _ReviewCard extends StatelessWidget {
  final String userName;
  final double rating;
  final String text;
  final DateTime date;
  final bool isDummy;

  const _ReviewCard({
    required this.userName,
    required this.rating,
    required this.text,
    required this.date,
    required this.isDummy,
  });

  @override
  Widget build(BuildContext context) {
    final difference = DateTime.now().difference(date);
    String timeAgo;
    if (difference.inDays > 0) {
      timeAgo = '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      timeAgo = '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      timeAgo = '${difference.inMinutes}m ago';
    } else {
      timeAgo = 'just now';
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.surfaceLight,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDummy ? Colors.grey[200]! : _kGreenLight,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Avatar
              CircleAvatar(
                radius: 18,
                backgroundColor: AppTheme.primaryColor,
                child: Text(
                  userName.isNotEmpty ? userName[0].toUpperCase() : '?',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          userName,
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: _kDark,
                          ),
                        ),
                        if (isDummy)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.grey[200],
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Text(
                              'Sample',
                              style: TextStyle(
                                fontSize: 10,
                                color: _kGreyText,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      timeAgo,
                      style: const TextStyle(
                        color: _kGreyText,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Star Rating
          Row(
            children: [
              ..._buildStars(rating),
              const SizedBox(width: 6),
              Text(
                rating.toStringAsFixed(1),
                style: const TextStyle(
                  color: _kDark,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Review Text
          Text(
            text,
            style: const TextStyle(
              color: _kDark,
              fontSize: 13,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildStars(double rating) {
    int fullStars = rating.floor();
    bool hasHalf = (rating - fullStars) >= 0.5;
    const int totalStars = 5;
    List<Widget> stars = [];

    for (int i = 1; i <= totalStars; i++) {
      if (i <= fullStars) {
        stars.add(const Icon(Icons.star, size: 14, color: Colors.amber));
      } else if (i == fullStars + 1 && hasHalf) {
        stars.add(const Icon(Icons.star_half, size: 14, color: Colors.amber));
      } else {
        stars.add(const Icon(Icons.star_border, size: 14, color: Colors.amber));
      }
    }

    return stars;
  }
}
