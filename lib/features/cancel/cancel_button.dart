import 'dart:async';
import 'package:flutter/material.dart';
import 'cancel_dialog.dart';
import 'cancel_service.dart';

class CancelButton extends StatefulWidget {
  final String bookingId;
  final String paymentReference;
  final bool isCancelled;
  final String roomName;
  final String hostelName;
  final String imageUrl;
  final double amount;
  final DateTime createdAt; // 🔥 ADD THIS

  const CancelButton({
    super.key,
    required this.bookingId,
    required this.paymentReference,
    required this.isCancelled,
    required this.roomName,
    required this.hostelName,
    required this.imageUrl,
    required this.amount,
    required this.createdAt,
  });

  @override
  State<CancelButton> createState() => _CancelButtonState();
}

class _CancelButtonState extends State<CancelButton> {
  Timer? timer;
  int remainingSeconds = 0;
  bool expired = false;
  bool cancelled = false;

  @override
  void initState() {
    super.initState();
    calculateRemainingTime();

    timer = Timer.periodic(const Duration(seconds: 1), (_) {
      calculateRemainingTime();
    });
  }

  void calculateRemainingTime() {
    final expiryTime = widget.createdAt.add(const Duration(minutes: 3));
    final now = DateTime.now();

    final difference = expiryTime.difference(now).inSeconds;

    if (difference <= 0) {
      setState(() {
        expired = true;
        remainingSeconds = 0;
      });
      timer?.cancel();
    } else {
      setState(() {
        remainingSeconds = difference;
      });
    }
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  String get timerText {
    final minutes = remainingSeconds ~/ 60;
    final seconds = remainingSeconds % 60;
    return "$minutes:${seconds.toString().padLeft(2, '0')}";
  }

  @override
  Widget build(BuildContext context) {
    final disabled = widget.isCancelled || cancelled || expired;

    Color backgroundColor;
    String buttonText;

    if (expired) {
      backgroundColor = Colors.grey;
      buttonText = "Expired";
    } else if (cancelled || widget.isCancelled) {
      backgroundColor = Colors.grey;
      buttonText = "Cancelled";
    } else {
      backgroundColor = Colors.red;
      buttonText = "Cancel Reservation";
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (!expired && !cancelled)
          Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Text(
              "Expires in $timerText",
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.red,
              ),
            ),
          ),

        AnimatedOpacity(
          duration: const Duration(milliseconds: 300),
          opacity: disabled ? 0.6 : 1,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: backgroundColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            onPressed: disabled
                ? null
                : () async {
                    final confirmed = await showCancelDialog(
                      context,
                      roomName: widget.roomName,
                      hostelName: widget.hostelName,
                      imageUrl: widget.imageUrl,
                      amount: widget.amount,
                    );

                    if (confirmed == true) {
                      await CancelService.cancelReservation(
                        bookingId: widget.bookingId,
                        paymentReference: widget.paymentReference,
                      );

                      setState(() {
                        cancelled = true;
                      });

                      timer?.cancel();
                    }
                  },
            child: Text(
              buttonText,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ],
    );
  }
}