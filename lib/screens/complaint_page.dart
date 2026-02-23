import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hostel_reservation/app_theme.dart';
import 'package:hostel_reservation/widgets/app_footer.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _kGreyText = Color(0xFF757575);
const _kGreenLight = Color(0xFF4CAF50);
const _kGreenPale = Color(0xFFE8F5E9);
const _kDark = Color(0xFF1A1A1A);

class ComplaintPage extends StatefulWidget {
  final String hostelId;
  final String hostelName;
  final String roomName;
  final String bookingId;
  final String imageUrl;
  final bool isReview;

  const ComplaintPage({
    Key? key,
    this.hostelId = '',
    this.hostelName = '',
    this.roomName = '',
    this.bookingId = '',
    this.imageUrl = '',
    this.isReview = false,
  }) : super(key: key);

  @override
  State<ComplaintPage> createState() => _ComplaintPageState();
}

class _ComplaintPageState extends State<ComplaintPage> {
  final _formKey = GlobalKey<FormState>();
  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  String _text = '';
  double _rating = 4.0;
  bool _isSubmitting = false;

  final List<String> _complaintCategories = [
    'Plumbing',
    'Electricity',
    'Maintenance',
    'Cleanliness',
    'Noise',
    'Other',
  ];

  String _selectedCategory = 'Plumbing';

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    _formKey.currentState!.save();
    setState(() => _isSubmitting = true);

    try {
      if (widget.isReview) {
        // Save review to Firebase
        await _firestore.collection('reviews').add({
          'hostelId': widget.hostelId,
          'hostelName': widget.hostelName,
          'roomName': widget.roomName,
          'bookingId': widget.bookingId,
          'userId': _auth.currentUser?.uid,
          'userName': _auth.currentUser?.displayName ?? 'Anonymous',
          'rating': _rating,
          'text': _text,
          'createdAt': FieldValue.serverTimestamp(),
        });

        // store a copy locally for offline review listing
        try {
          final prefs = await SharedPreferences.getInstance();
          final localData = jsonEncode({
            'userName': _auth.currentUser?.displayName ?? 'Anonymous',
            'rating': _rating,
            'text': _text,
            'date': DateTime.now().toIso8601String(),
            'isDummy': false,
          });
          await prefs.setString('review_${widget.bookingId}', localData);
        } catch (_) {}

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Review submitted successfully!'),
              backgroundColor: AppTheme.primaryColor,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          );
          Future.delayed(const Duration(seconds: 1), () {
            if (mounted) Navigator.pop(context);
          });
        }
      } else {
        // Save complaint to Firebase
        await _firestore.collection('complaints').add({
          'hostelId': widget.hostelId,
          'hostelName': widget.hostelName,
          'roomName': widget.roomName,
          'bookingId': widget.bookingId,
          'userId': _auth.currentUser?.uid,
          'category': _selectedCategory,
          'text': _text,
          'status': 'open',
          'createdAt': FieldValue.serverTimestamp(),
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Complaint submitted successfully!'),
              backgroundColor: AppTheme.primaryColor,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          );
          Future.delayed(const Duration(seconds: 1), () {
            if (mounted) Navigator.pop(context);
          });
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final title = widget.isReview ? 'Add Review' : 'Create Complaint';
    final buttonText = widget.isReview ? 'Submit Review' : 'Submit Complaint';

    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      bottomNavigationBar: const AppFooter(),
      appBar: AppBar(
        title: Text(title),
        backgroundColor: AppTheme.primaryColor,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Booking Header Card
            if (widget.imageUrl.isNotEmpty || widget.hostelName.isNotEmpty)
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
                    if (widget.imageUrl.isNotEmpty)
                      ClipRRect(
                        borderRadius: const BorderRadius.horizontal(
                          left: Radius.circular(10),
                        ),
                        child: Image.network(
                          widget.imageUrl,
                          width: 72,
                          height: 72,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              Container(
                            width: 72,
                            height: 72,
                            color: _kGreenPale,
                            child: Icon(
                              Icons.hotel_rounded,
                              color: AppTheme.primaryColor,
                            ),
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

            // Form
            Container(
              margin: const EdgeInsets.fromLTRB(16, 0, 16, 32),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.surfaceLight,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Rating Section (only for reviews)
                    if (widget.isReview) ...[
                      Text(
                        'Rating',
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: _kDark,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ...[1.0, 2.0, 3.0, 4.0, 5.0].map((value) {
                            return GestureDetector(
                              onTap: () {
                                setState(() => _rating = value);
                              },
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                ),
                                child: Icon(
                                  _rating >= value
                                      ? Icons.star
                                      : Icons.star_border,
                                  color: Colors.amber,
                                  size: 32,
                                ),
                              ),
                            );
                          }).toList(),
                        ],
                      ),
                      const SizedBox(height: 20),
                    ],

                    // Category Dropdown (only for complaints)
                    if (!widget.isReview) ...[
                      Text(
                        'Category',
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: _kDark,
                        ),
                      ),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<String>(
                        value: _selectedCategory,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          filled: true,
                          fillColor: AppTheme.backgroundLight,
                        ),
                        items: _complaintCategories
                            .map((cat) => DropdownMenuItem(
                              value: cat,
                              child: Text(cat),
                            ))
                            .toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedCategory = value!;
                          });
                        },
                      ),
                      const SizedBox(height: 20),
                    ],

                    // Content Text Field
                    Text(
                      widget.isReview ? 'Your Review' : 'Your ${_selectedCategory}',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: _kDark,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      maxLines: 5,
                      maxLength: 500,
                      decoration: InputDecoration(
                        hintText: widget.isReview
                            ? 'Share your experience...'
                            : 'Describe your ${_selectedCategory.toLowerCase()}...',
                        hintStyle: const TextStyle(
                          color: _kGreyText,
                          fontSize: 13,
                        ),
                        filled: true,
                        fillColor: AppTheme.backgroundLight,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: AppTheme.primaryColor,
                            width: 1.5,
                          ),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter your ${widget.isReview ? 'review' : 'complaint'}';
                        }
                        return null;
                      },
                      onSaved: (value) {
                        _text = value?.trim() ?? '';
                      },
                    ),
                    const SizedBox(height: 20),

                    // Submit Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryColor,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: _isSubmitting ? null : _submitForm,
                        child: _isSubmitting
                            ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.white,
                                ),
                              ),
                            )
                            : Text(
                              buttonText,
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
