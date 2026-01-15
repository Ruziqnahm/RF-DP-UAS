import 'package:intl/intl.dart';

class DateFormatter {
  /// Format DateTime to Indonesian date
  /// Example: 2026-01-12 -> "12 Januari 2026"
  static String toIndonesianDate(DateTime date) {
    final months = [
      '', 'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
      'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
    ];
    
    return '${date.day} ${months[date.month]} ${date.year}';
  }

  /// Format DateTime to date and time
  /// Example: 2026-01-12 14:30 -> "12 Jan 2026, 14:30"
  static String toDateTimeString(DateTime date) {
    final dateFormat = DateFormat('dd MMM yyyy, HH:mm', 'id_ID');
    return dateFormat.format(date);
  }

  /// Format to short date
  /// Example: 2026-01-12 -> "12/01/2026"
  static String toShortDate(DateTime date) {
    final dateFormat = DateFormat('dd/MM/yyyy');
    return dateFormat.format(date);
  }

  /// Format to time only
  /// Example: 14:30:45 -> "14:30"
  static String toTimeString(DateTime date) {
    final timeFormat = DateFormat('HH:mm');
    return timeFormat.format(date);
  }

  /// Parse string to DateTime
  /// Supports: "2026-01-12T14:30:00.000000Z" or "2026-01-12"
  static DateTime? parseDate(String? dateString) {
    if (dateString == null || dateString.isEmpty) return null;
    
    try {
      return DateTime.parse(dateString);
    } catch (e) {
      return null;
    }
  }

  /// Get relative time
  /// Example: "2 jam yang lalu", "3 hari yang lalu"
  static String getRelativeTime(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 7) {
      return toIndonesianDate(date);
    } else if (difference.inDays > 0) {
      return '${difference.inDays} hari yang lalu';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} jam yang lalu';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} menit yang lalu';
    } else {
      return 'Baru saja';
    }
  }
}
