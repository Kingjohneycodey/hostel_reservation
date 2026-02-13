enum ReservationStatus { active, cancelled }

class ReservationModel {
  final String bookingId;
  final String hostelName;
  final String hostelBlock;
  final String roomName;
  final DateTime bookedAt;
  final ReservationStatus status;
  final String imageUrl;

  const ReservationModel({
    required this.bookingId,
    required this.hostelName,
    required this.hostelBlock,
    required this.roomName,
    required this.bookedAt,
    required this.status,
    required this.imageUrl,
  });

  ReservationModel copyWith({
    String? bookingId,
    String? hostelName,
    String? hostelBlock,
    String? roomName,
    DateTime? bookedAt,
    ReservationStatus? status,
    String? imageUrl,
  }) {
    return ReservationModel(
      bookingId: bookingId ?? this.bookingId,
      hostelName: hostelName ?? this.hostelName,
      hostelBlock: hostelBlock ?? this.hostelBlock,
      roomName: roomName ?? this.roomName,
      bookedAt: bookedAt ?? this.bookedAt,
      status: status ?? this.status,
      imageUrl: imageUrl ?? this.imageUrl,
    );
  }
}
