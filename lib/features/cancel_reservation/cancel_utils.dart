class CancelUtils {
  // Returns the deadline for cancellation (24 hours after booking)
  static DateTime cancelDeadline(DateTime bookedAt) {
    return bookedAt.add(const Duration(hours: 24));
  }

  // Checks if cancellation is still allowed
  static bool canCancel(DateTime bookedAt) {
    final deadline = cancelDeadline(bookedAt);
    return DateTime.now().isBefore(deadline);
  }

  // Formats duration for display
  static String formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes % 60;
    return "${hours}h ${minutes}m";
  }
}