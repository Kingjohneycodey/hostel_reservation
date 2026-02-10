import 'dart:async';

import 'package:flutter/material.dart';

import 'cancel_button.dart';
import 'cancel_dialog.dart';
import 'cancel_models.dart';
import 'cancel_service.dart';
import 'cancel_utils.dart';

class CancelDemoScreen extends StatefulWidget {
  const CancelDemoScreen({super.key});

  @override
  State<CancelDemoScreen> createState() => _CancelDemoScreenState();
}

class _CancelDemoScreenState extends State<CancelDemoScreen> {
  late Booking booking;
  Timer? _timer;

  @override
  void initState() {
    super.initState();

    // DEMO booking data (later can come from Firebase)
    booking = Booking(
      bookingId: 'BOOKING_001',
      hostelName: 'Tensai Hostel (Block A)',
      roomName: 'Room 12',
      bookedAt: DateTime.now(),
      cancelDeadline: DateTime.now().add(const Duration(days: 3)),
      status: BookingStatus.active,
    );

    // This timer refreshes the "time left" every second
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _handleCancelPressed() async {
    // 1) First check if cancellation is allowed
    final bool allowed = CancelUtils.canCancel(booking);

    if (!allowed) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Cancellation time has passed.'),
        ),
      );
      return;
    }

    // 2) Show confirmation dialog (from cancel_dialog.dart)
    final bool confirmed = await showCancelDialog(context);

    if (!confirmed) return;

    // 3) Call service (from cancel_service.dart)
    final bool success = await CancelService.cancelBooking(booking.bookingId);

    if (!mounted) return;

    if (success) {
      setState(() {
        booking = booking.copyWith(status: BookingStatus.cancelled);
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Reservation cancelled successfully!'),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to cancel. Try again.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool canCancel = CancelUtils.canCancel(booking);
    final Duration timeLeft = CancelUtils.timeLeft(booking);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Cancel Reservation (Demo)'),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _BookingCard(
            booking: booking,
            canCancel: canCancel,
            timeLeft: timeLeft,
            onCancelPressed: _handleCancelPressed,
          ),
          const SizedBox(height: 16),
          _NoteCard(),
        ],
      ),
    );
  }
}

class _BookingCard extends StatelessWidget {
  final Booking booking;
  final bool canCancel;
  final Duration timeLeft;
  final VoidCallback onCancelPressed;

  const _BookingCard({
    required this.booking,
    required this.canCancel,
    required this.timeLeft,
    required this.onCancelPressed,
  });

  @override
  Widget build(BuildContext context) {
    final String statusText = CancelUtils.statusText(booking.status);
    final Color statusColor = CancelUtils.statusColor(booking.status);

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.grey.shade300),
        boxShadow: [
          BoxShadow(
            blurRadius: 18,
            color: Colors.black.withOpacity(0.05),
            offset: const Offset(0, 8),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            booking.hostelName,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            booking.roomName,
            style: const TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 16),

          _InfoRow(
            label: "Booking ID",
            value: booking.bookingId,
          ),
          const SizedBox(height: 8),

          _InfoRow(
            label: "Booked At",
            value: CancelUtils.formatDateTime(booking.bookedAt),
          ),
          const SizedBox(height: 8),

          _InfoRow(
            label: "Cancel Deadline",
            value: CancelUtils.formatDateTime(booking.cancelDeadline),
          ),
          const SizedBox(height: 16),

          Row(
            children: [
              const Text(
                "Status:",
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
              const SizedBox(width: 8),
              Text(
                statusText,
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  color: statusColor,
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          Row(
            children: [
              const Icon(Icons.timer_outlined, size: 20),
              const SizedBox(width: 8),
              Text(
                "Time left: ${CancelUtils.formatDuration(timeLeft)}",
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),

          const SizedBox(height: 22),

          // ✅ This button comes from cancel_button.dart
          CancelButton(
            enabled: canCancel && booking.status == BookingStatus.active,
            onPressed: onCancelPressed,
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "$label:",
          style: const TextStyle(
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(fontSize: 15),
          ),
        ),
      ],
    );
  }
}

class _NoteCard extends StatelessWidget {
  const _NoteCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Text(
        "NOTE: This is a demo screen.\n"
        "Change bookedAt in code to test the 3-day cancellation rule.",
        style: TextStyle(
          fontSize: 14,
          height: 1.4,
        ),
      ),
    );
  }
}
