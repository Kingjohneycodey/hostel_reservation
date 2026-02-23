import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:hostel_reservation/app_theme.dart';
import 'package:hostel_reservation/widgets/app_footer.dart';

const _kGreyText = Color(0xFF757575);
const _kGreenLight = Color(0xFF4CAF50);
const _kGreenPale = Color(0xFFE8F5E9);
const _kDark = Color(0xFF1A1A1A);

class ComplaintFeedbackScreen extends StatefulWidget {
  const ComplaintFeedbackScreen({Key? key}) : super(key: key);

  @override
  State<ComplaintFeedbackScreen> createState() =>
      _ComplaintFeedbackScreenState();
}

class _ComplaintFeedbackScreenState extends State<ComplaintFeedbackScreen>
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
    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      bottomNavigationBar: const AppFooter(),
      appBar: AppBar(
        title: const Text('Complaints & Feedback'),
        backgroundColor: AppTheme.primaryColor,
      ),
      body: Column(
        children: [
          // Tab Bar
          Container(
            margin: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.surfaceLight,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.06),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: TabBar(
              controller: _tabController,
              indicator: BoxDecoration(
                color: AppTheme.primaryColor,
                borderRadius: BorderRadius.circular(10),
              ),
              indicatorSize: TabBarIndicatorSize.tab,
              labelColor: Colors.white,
              unselectedLabelColor: _kGreyText,
              labelStyle:
                  const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
              dividerColor: Colors.transparent,
              padding: const EdgeInsets.all(4),
              tabs: const [
                Tab(text: 'Make Complaint'),
                Tab(text: 'My Complaints'),
              ],
            ),
          ),
          // Tab Content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: const [
                _ComplaintTab(),
                _FeedbackTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ComplaintTab extends StatefulWidget {
  const _ComplaintTab();

  @override
  State<_ComplaintTab> createState() => _ComplaintTabState();
}

class _ComplaintTabState extends State<_ComplaintTab> {
  final _formKey = GlobalKey<FormState>();
  String _selectedCategory = 'Plumbing';
  String _complaintText = '';
  bool _isSubmitting = false;

  final List<String> _categories = [
    'Plumbing',
    'Electricity',
    'Maintenance',
    'Cleanliness',
    'Noise',
    'Water Supply',
    'Internet',
    'Other',
  ];

  Future<void> _submitComplaint() async {
    if (!_formKey.currentState!.validate()) return;

    _formKey.currentState!.save();
    setState(() => _isSubmitting = true);

    try {
      final prefs = await SharedPreferences.getInstance();
      final complaintsJson =
          prefs.getString('complaints') ?? '[]';
      final complaints =
          List<Map<String, dynamic>>.from(jsonDecode(complaintsJson));

      final complaint = {
        'id': DateTime.now().millisecondsSinceEpoch.toString(),
        'category': _selectedCategory,
        'text': _complaintText,
        'status': 'Pending',
        'createdAt': DateTime.now().toIso8601String(),
      };

      complaints.add(complaint);
      await prefs.setString('complaints', jsonEncode(complaints));

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Complaint made successfully!'),
            backgroundColor: AppTheme.primaryColor,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            duration: const Duration(seconds: 2),
          ),
        );

        // Reset form
        _formKey.currentState!.reset();
        setState(() {
          _selectedCategory = 'Plumbing';
          _complaintText = '';
        });
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
    return SingleChildScrollView(
      child: Container(
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 32),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              // Category
              Text(
                'Complaint Category',
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
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
                items: _categories
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

              // Description
              Text(
                'Description',
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
                  hintText: 'Describe your complaint...',
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
                    return 'Please describe your complaint';
                  }
                  if (value.trim().length < 10) {
                    return 'Description must be at least 10 characters';
                  }
                  return null;
                },
                onSaved: (value) {
                  _complaintText = value?.trim() ?? '';
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
                  onPressed: _isSubmitting ? null : _submitComplaint,
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
                      : const Text(
                        'Submit Complaint',
                        style: TextStyle(
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
    );
  }
}

class _FeedbackTab extends StatefulWidget {
  const _FeedbackTab();

  @override
  State<_FeedbackTab> createState() => _FeedbackTabState();
}

class _FeedbackTabState extends State<_FeedbackTab> {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<SharedPreferences>(
      future: SharedPreferences.getInstance(),
      builder: (context, snap) {
        if (!snap.hasData) {
          return const Center(
            child: CircularProgressIndicator(
              color: AppTheme.primaryColor,
            ),
          );
        }

        final prefs = snap.data!;
        final complaintsJson = prefs.getString('complaints') ?? '[]';
        final complaints = List<Map<String, dynamic>>.from(
          jsonDecode(complaintsJson).cast<Map<String, dynamic>>(),
        );

        if (complaints.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.checklist_outlined,
                  color: _kGreenLight,
                  size: 48,
                ),
                const SizedBox(height: 12),
                Text(
                  'No complaints yet',
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
          padding: const EdgeInsets.all(16),
          itemCount: complaints.length,
          itemBuilder: (context, index) {
            final complaint =
                complaints[complaints.length - 1 - index];
            return _ComplaintCard(complaint: complaint);
          },
        );
      },
    );
  }
}

class _ComplaintCard extends StatelessWidget {
  final Map<String, dynamic> complaint;

  const _ComplaintCard({required this.complaint});

  @override
  Widget build(BuildContext context) {
    final category = complaint['category'] as String? ?? 'Other';
    final text = complaint['text'] as String? ?? '';
    final status = complaint['status'] as String? ?? 'Pending';
    final createdAtString = complaint['createdAt'] as String?;
    
    DateTime? createdAt;
    if (createdAtString != null) {
      try {
        createdAt = DateTime.parse(createdAtString);
      } catch (_) {}
    }

    final difference = createdAt != null
        ? DateTime.now().difference(createdAt)
        : Duration.zero;
    
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

    final statusColor = status == 'Pending' ? Colors.orange : _kGreenLight;
    final statusIcon = status == 'Pending'
        ? Icons.schedule_rounded
        : Icons.check_circle_rounded;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.surfaceLight,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.grey[200]!,
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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      category,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: _kDark,
                      ),
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
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      statusIcon,
                      size: 14,
                      color: statusColor,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      status,
                      style: TextStyle(
                        color: statusColor,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
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
}
