class CancelService {
  // Simulates cancelling a reservation (your teammate will add real Firebase code)
  static Future<void> cancelReservation({required String bookingId}) async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 1));
    
    print("Cancelled booking: $bookingId");
    // TODO: Add real Firebase/API cancellation logic here
  }
}