import 'package:flutter/material.dart';

class CancelReservationDialog extends StatelessWidget {
  final VoidCallback onConfirmCancel;

  const CancelReservationDialog({
    Key? key,
    required this.onConfirmCancel,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text(
        'Cancel Reservation?',
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 20,
        ),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Text(
            'Are you sure you want to cancel this reservation?',
            style: TextStyle(fontSize: 16),
          ),
          SizedBox(height: 12),
          Text(
            'This action cannot be undone.',
            style: TextStyle(
              fontSize: 14,
              color: Colors.green,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text(
            'Cancel',
            style: TextStyle(fontSize: 16),
          ),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.of(context).pop();
            onConfirmCancel();
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
            foregroundColor: Colors.white,
          ),
          child: const Text(
            'Yes, Cancel Reservation',
            style: TextStyle(fontSize: 16),
          ),
        ),
      ],
    );
  }
}