import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hostel_reservation/app_theme.dart';
import 'package:hostel_reservation/widgets/app_footer.dart';
import 'package:hostel_reservation/screens/complaint_page.dart';
import 'package:hostel_reservation/screens/view_reviews_page.dart';

const _kGreyText = Color(0xFF757575);
const _kGreenLight = Color(0xFF4CAF50);
const _kGreenPale = Color(0xFFE8F5E9);
const _kDark = Color(0xFF1A1A1A);

class ReviewSelectionScreen extends StatelessWidget {
  final String? docId;
  final Map<String, dynamic>? bookingData;

  const ReviewSelectionScreen({
    Key? key,
    this.docId,
    this.bookingData,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;
    final firestore = FirebaseFirestore.instance;

    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      bottomNavigationBar: const AppFooter(),
      appBar: AppBar(
        title: const Text('Reviews'),
        backgroundColor: AppTheme.primaryColor,
      ),
      body: currentUser == null
          ? const Center(child: Text('Please log in to view reviews.'))
          : StreamBuilder<DocumentSnapshot>(
              stream: firestore
                  .collection('bookings')
                  .doc(docId)
                  .snapshots(),
              builder: (context, snap) {
                if (snap.hasError) {
                  return Center(child: Text('Error: ${snap.error}'));
                }

                if (snap.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final booking = snap.data?.data() as Map<String, dynamic>?;
                if (booking == null) {
                  return const Center(child: Text('Booking not found.'));
                }

                final hostelId = booking['hostelId'] as String?;
                final roomName = booking['roomName'] ?? 'Room';
                final status = booking['status'] ?? 'confirmed';
                final isActive = status != 'cancelled';

                return FutureBuilder<DocumentSnapshot>(
                  future: hostelId != null
                      ? firestore.collection('hostels').doc(hostelId).get()
                      : null,
                  builder: (context, hostelSnap) {
                    final hostelData =
                        hostelSnap.data?.data() as Map<String, dynamic>?;
                    final hostelName = hostelData?['name'] ?? 'Hostel';
                    final imageUrl = hostelData?['imageUrl'] as String?;

                    return SingleChildScrollView(
                      child: Column(
                        children: [
                          // Booking Card Header
                          Container(
                            margin: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isActive
                                    ? _kGreenLight
                                    : Colors.grey[300]!,
                                width: 1.5,
                              ),
                            ),
                            child: Row(
                              children: [
                                ClipRRect(
                                  borderRadius:
                                      const BorderRadius.horizontal(
                                    left: Radius.circular(10),
                                  ),
                                  child: imageUrl != null
                                      ? Image.network(
                                          imageUrl,
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
                                    padding:
                                        const EdgeInsets.symmetric(vertical: 10),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          hostelName,
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyMedium
                                              ?.copyWith(
                                                fontWeight: FontWeight.w700,
                                                color: _kDark,
                                              ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          roomName,
                                          style: const TextStyle(
                                            color: _kGreyText,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(right: 12),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: isActive
                                          ? _kGreenPale
                                          : Colors.grey[100],
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      status,
                                      style: TextStyle(
                                        color: isActive
                                            ? AppTheme.primaryColor
                                            : _kGreyText,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // Review Action Buttons
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Column(
                              children: [
                                // View Past Reviews Button
                                SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton.icon(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppTheme.primaryColor,
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 14,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(12),
                                      ),
                                    ),
                                    onPressed: () {
                                      Navigator.of(context).push(
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              ViewReviewsPage(
                                            docId: docId ?? '',
                                            bookingData: booking,
                                            hostelId: hostelId ?? '',
                                            hostelName: hostelName,
                                            roomName: roomName,
                                            imageUrl: imageUrl ?? '',
                                          ),
                                        ),
                                      );
                                    },
                                    icon: const Icon(Icons.rate_review),
                                    label: const Text('View Past Reviews'),
                                  ),
                                ),
                                const SizedBox(height: 12),

                                // Add New Review Button
                                SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton.icon(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: _kGreenLight,
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 14,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(12),
                                      ),
                                    ),
                                    onPressed: () {
                                      Navigator.of(context).push(
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              ComplaintPage(
                                            hostelId: hostelId ?? '',
                                            hostelName: hostelName,
                                            roomName: roomName,
                                            bookingId: docId ?? '',
                                            imageUrl: imageUrl ?? '',
                                            isReview: true,
                                          ),
                                        ),
                                      );
                                    },
                                    icon: const Icon(Icons.add_comment),
                                    label: const Text('Add New Review'),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
    );
  }
}
