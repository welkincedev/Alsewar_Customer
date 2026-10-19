class BusinessHour {
  final int id;
  final int dayOfWeek;
  final String dayName;
  final String? openingTime;
  final String? closingTime;
  final bool isClosed;

  const BusinessHour({
    required this.id,
    required this.dayOfWeek,
    required this.dayName,
    this.openingTime,
    this.closingTime,
    this.isClosed = false,
  });

  /// Parse BusinessHour JSON handling nullable times and boolean values.
  factory BusinessHour.fromJson(Map<String, dynamic> json) {
    return BusinessHour(
      id: json['id'] is int
          ? json['id'] as int
          : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      dayOfWeek: json['day_of_week'] is int
          ? json['day_of_week'] as int
          : int.tryParse(json['day_of_week']?.toString() ?? '0') ?? 0,
      dayName: json['day_name']?.toString() ?? '',
      openingTime: json['opening_time']?.toString(),
      closingTime: json['closing_time']?.toString(),
      isClosed: json['is_closed'] is bool
          ? json['is_closed'] as bool
          : (json['is_closed']?.toString().toLowerCase() == 'true'),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'day_of_week': dayOfWeek,
      'day_name': dayName,
      'opening_time': openingTime,
      'closing_time': closingTime,
      'is_closed': isClosed,
    };
  }

  /// User-friendly formatted time string (e.g., "9:00 AM - 9:00 PM" or "Closed").
  String get formattedHours {
    if (isClosed ||
        openingTime == null ||
        closingTime == null ||
        openingTime!.isEmpty ||
        closingTime!.isEmpty) {
      return 'Closed';
    }
    return '${_formatTime(openingTime!)} - ${_formatTime(closingTime!)}';
  }

  static String _formatTime(String timeStr) {
    try {
      final parts = timeStr.split(':');
      if (parts.length < 2) return timeStr;
      int hour = int.parse(parts[0]);
      int minute = int.parse(parts[1]);
      final period = hour >= 12 ? 'PM' : 'AM';
      if (hour == 0) {
        hour = 12;
      } else if (hour > 12) {
        hour -= 12;
      }
      final minuteStr = minute.toString().padLeft(2, '0');
      return '$hour:$minuteStr $period';
    } catch (_) {
      return timeStr;
    }
  }
}
