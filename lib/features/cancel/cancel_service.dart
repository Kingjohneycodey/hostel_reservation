import 'package:cloud_firestore/cloud_firestore.dart';

class CancelService {
  static Future<void> cancelReservation({
    required String bookingId,
    required String paymentReference,
  }) async {
    final firestore = FirebaseFirestore.instance;

    // Update booking status
    await firestore.collection('bookings').doc(bookingId).update({
      'status': 'cancelled',
      'cancelledAt': FieldValue.serverTimestamp(),
    });

    // Simulate refund trigger
    await Future.delayed(const Duration(seconds: 1));
    print("Refund triggered for: $paymentReference");
  }
}