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
  // Demo booking (later you will replace with Firebase data)
  late ReservationModel reservation;

  Timer? _timer;
  Duration timeLeft = Duration.zero;

  bool isCancelling = false;

  @override
  void initState() {
    super.initState();

    // Demo: booked 1 day ago (so cancel is still allowed)
    final bookedAt = DateTime.now().subtract(const Duration(days: 1));

    reservation = ReservationModel(
      bookingId: "BOOKING_001",
      hostelName: "Happy Stay Hostel",
      hostelBlock: "Block A",
      roomName: "Room 101 (Single Room)",
      bookedAt: bookedAt,
      status: ReservationStatus.active,
      imageUrl:
          "https://images.unsplash.com/photo-1505691938895-1758d7feb511?w=1200",
    );

    _startCountdown();
  }

  void _startCountdown() {
    _updateTimeLeft();

    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      _updateTimeLeft();
    });
  }

  void _updateTimeLeft() {
    final deadline = CancelUtils.cancelDeadline(reservation.bookedAt);

    final now = DateTime.now();
    final diff = deadline.difference(now);

    setState(() {
      timeLeft = diff.isNegative ? Duration.zero : diff;
    });
  }

  bool get canCancel {
    return CancelUtils.canCancel(reservation.bookedAt);
  }

  Future<void> _onCancelPressed() async {
  if (!canCancel || isCancelling) return;

  // Show our new dialog
  await showDialog(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return CancelReservationDialog(
        onConfirmCancel: () async {
          // This runs when user clicks "Yes, Cancel Reservation"
          setState(() => isCancelling = true);

          try {
            await CancelService.cancelReservation(
              bookingId: reservation.bookingId,
            );

            if (!mounted) return;

            setState(() {
              reservation = reservation.copyWith(status: ReservationStatus.cancelled);
            });

            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text("Reservation cancelled successfully."),
              ),
            );
          } catch (e) {
            if (!mounted) return;

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text("Cancel failed: $e"),
              ),
            );
          } finally {
            if (mounted) setState(() => isCancelling = false);
          }
        },
      );
    },
  );
}

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isCancelled = reservation.status == ReservationStatus.cancelled;

    return Scaffold(
      appBar: AppBar(
        title: const Text("User Dashboard"),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: CircleAvatar(
              backgroundColor: Colors.white,
              child: Padding(
                padding: const EdgeInsets.all(4),
                child: Image.network(
                  "https://upload.wikimedia.org/wikipedia/commons/5/5c/University_logo_example.png",
                  errorBuilder: (_, __, ___) =>
                      const Icon(Icons.school, color: Colors.green),
                ),
              ),
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        children: [
          // Profile top
          Column(
            children: [
              const SizedBox(height: 10),
              CircleAvatar(
                radius: 50,
                backgroundColor: Colors.green,
                child: CircleAvatar(
                  radius: 46,
                  backgroundImage: NetworkImage(
                    "https://images.unsplash.com/photo-1544723795-3fb6469f5b39?w=600",
                  ),
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                "Jane Doe",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 2),
              const Text(
                "janedoe@gmail.com",
                style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic),
              ),
              const SizedBox(height: 2),
              const Text(
                "08012345678",
                style: TextStyle(fontSize: 12),
              ),
              const SizedBox(height: 22),
            ],
          ),

          // Booked Rooms title
          const Text(
            "Booked Rooms",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Colors.green,
            ),
          ),
          const SizedBox(height: 10),

          // Hostel image card
          ClipRRect(
            borderRadius: BorderRadius.circular(18),
            child: Stack(
              children: [
                SizedBox(
                  height: 190,
                  width: double.infinity,
                  child: Image.network(
                    reservation.imageUrl,
                    fit: BoxFit.cover,
                  ),
                ),

                // left + right arrows
                Positioned(
                  left: 10,
                  top: 80,
                  child: _ArrowButton(icon: Icons.chevron_left),
                ),
                Positioned(
                  right: 10,
                  top: 80,
                  child: _ArrowButton(icon: Icons.chevron_right),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // Green booking info card
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            decoration: BoxDecoration(
              color: Colors.green,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Row(
              children: [
                // Left text
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        reservation.hostelName,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        reservation.roomName,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),

                // Right cancel button + timer
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    CancelButton(
                      enabled: canCancel && !isCancelled,
                      isLoading: isCancelling,
                      onPressed: _onCancelPressed,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      isCancelled
                          ? "Cancelled"
                          : canCancel
                              ? "${CancelUtils.formatDuration(timeLeft)} left"
                              : "Cancel expired",
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.white.withOpacity(0.85),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 18),

          // Order history
          const Text(
            "Order History",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Colors.green,
            ),
          ),
          const SizedBox(height: 10),

          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    "Placed an Order for ${reservation.roomName} in ${reservation.hostelName}",
                    style: const TextStyle(fontSize: 12),
                  ),
                ),
                TextButton(
                  onPressed: () {},
                  child: const Text(
                    "View More",
                    style: TextStyle(color: Colors.green),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ArrowButton extends StatelessWidget {
  final IconData icon;
  const _ArrowButton({required this.icon});

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: 16,
      backgroundColor: Colors.white.withOpacity(0.7),
      child: Icon(icon, color: Colors.black),
    );
  }
}
