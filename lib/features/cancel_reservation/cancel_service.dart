import 'package:cloud_firestore/cloud_firestore.dart';

class CancelService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<String> cancelReservation({
    required String reservationId,
    required DateTime checkInDate,
    String? cancelReason,
  }) async {
    try {
      bool allowed = _canCancel(checkInDate);

      if (!allowed) {
        return "Cancellation period expired";
      }

      await _firestore.collection('reservations').doc(reservationId).update({
        'status': 'cancelled',
        'cancelledAt': Timestamp.now(),
        'cancelReason': cancelReason ?? "No reason provided",
      });

      return "success";
    } catch (e) {
      return e.toString();
    }
  }

  bool _canCancel(DateTime checkInDate) {
    DateTime now = DateTime.now();
    return now.isBefore(checkInDate);
  }
}
