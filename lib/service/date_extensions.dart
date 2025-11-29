// Create this file: lib/extensions/date_extension.dart

import 'package:intl/intl.dart';

extension DateFormatExtension on DateTime {
  /// Format: Jan 15, 2024 (always uses local date, no timezone shift)
  String toShortDate() {
    return DateFormat('MMM dd, yyyy').format(this);
  }

  /// Format: January 15, 2024
  String toLongDate() {
    return DateFormat('MMMM dd, yyyy').format(this);
  }

  /// Format: 15/01/2024
  String toSlashDate() {
    return DateFormat('dd/MM/yyyy').format(this);
  }

  /// Format: 01/15/2024 (US format)
  String toUSDate() {
    return DateFormat('MM/dd/yyyy').format(this);
  }

  /// Format: 2024-01-15 (Date only, no time component)
  String toISODate() {
    return DateFormat('yyyy-MM-dd').format(this);
  }

  /// Format: 15 Jan 2024
  String toDayMonthYear() {
    return DateFormat('dd MMM yyyy').format(this);
  }

  /// Format: Monday, January 15, 2024
  String toFullDate() {
    return DateFormat('EEEE, MMMM dd, yyyy').format(this);
  }

  /// Format: Mon, Jan 15
  String toShortDayDate() {
    return DateFormat('EEE, MMM dd').format(this);
  }

  /// Format: 3:30 PM
  String toTime() {
    return DateFormat('h:mm a').format(this);
  }

  /// Format: 15:30
  String toTime24() {
    return DateFormat('HH:mm').format(this);
  }

  /// Format: Jan 15, 2024 at 3:30 PM
  String toDateTimeShort() {
    return DateFormat('MMM dd, yyyy \'at\' h:mm a').format(this);
  }

  /// Format: January 15, 2024 at 3:30 PM
  String toDateTimeLong() {
    return DateFormat('MMMM dd, yyyy \'at\' h:mm a').format(this);
  }

  /// Format: 15/01/2024 15:30
  String toDateTimeSlash() {
    return DateFormat('dd/MM/yyyy HH:mm').format(this);
  }

  /// Relative time (e.g., "2 hours ago", "Just now")
  String toRelativeTime() {
    final now = DateTime.now();
    final difference = now.difference(this);

    if (difference.inSeconds < 60) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes} ${difference.inMinutes == 1 ? 'minute' : 'minutes'} ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} ${difference.inHours == 1 ? 'hour' : 'hours'} ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} ${difference.inDays == 1 ? 'day' : 'days'} ago';
    } else if (difference.inDays < 30) {
      final weeks = (difference.inDays / 7).floor();
      return '$weeks ${weeks == 1 ? 'week' : 'weeks'} ago';
    } else if (difference.inDays < 365) {
      final months = (difference.inDays / 30).floor();
      return '$months ${months == 1 ? 'month' : 'months'} ago';
    } else {
      final years = (difference.inDays / 365).floor();
      return '$years ${years == 1 ? 'year' : 'years'} ago';
    }
  }

  /// Get day name (e.g., "Monday")
  String toDayName() {
    return DateFormat('EEEE').format(this);
  }

  /// Get short day name (e.g., "Mon")
  String toShortDayName() {
    return DateFormat('EEE').format(this);
  }

  /// Get month name (e.g., "January")
  String toMonthName() {
    return DateFormat('MMMM').format(this);
  }

  /// Get short month name (e.g., "Jan")
  String toShortMonthName() {
    return DateFormat('MMM').format(this);
  }

  /// Check if date is today
  bool get isToday {
    final now = DateTime.now();
    return year == now.year && month == now.month && day == now.day;
  }

  /// Check if date is yesterday
  bool get isYesterday {
    final yesterday = DateTime.now().subtract(Duration(days: 1));
    return year == yesterday.year &&
        month == yesterday.month &&
        day == yesterday.day;
  }

  /// Check if date is tomorrow
  bool get isTomorrow {
    final tomorrow = DateTime.now().add(Duration(days: 1));
    return year == tomorrow.year &&
        month == tomorrow.month &&
        day == tomorrow.day;
  }

  /// Smart date formatter (Today, Yesterday, or date)
  String toSmartDate() {
    if (isToday) return 'Today';
    if (isYesterday) return 'Yesterday';
    if (isTomorrow) return 'Tomorrow';
    return toShortDate();
  }

  /// Convert to local date at midnight (removes time/timezone issues)
  DateTime toLocalDateOnly() {
    return DateTime(year, month, day);
  }
}

// ==========================================
// String Extension for Parsing
// ==========================================

extension StringToDateExtension on String {
  /// Parse string to DateTime (LOCAL timezone, date only)
  /// Supports: "2024-01-15", "2024-01-15T00:00:00Z", "15/01/2024", "01/15/2024"
  DateTime? toDateTime() {
    try {
      if (isEmpty) return null;

      // Remove 'Z' suffix and time components for date-only parsing
      String cleanDate = this;

      // Handle ISO format with time: "2024-01-15T00:00:00.000Z"
      if (contains('T')) {
        cleanDate = split('T')[0]; // Get only date part
      }

      // Try ISO format: "2024-01-15"
      if (contains('-')) {
        final parts = cleanDate.split('-');
        if (parts.length == 3) {
          return DateTime(
            int.parse(parts[0]), // year
            int.parse(parts[1]), // month
            int.parse(parts[2]), // day
          );
        }
      }

      // Try slash format: "15/01/2024" or "01/15/2024"
      if (contains('/')) {
        final parts = split('/');
        if (parts.length == 3) {
          // Detect format by checking if first part > 12
          if (int.parse(parts[0]) > 12) {
            // dd/MM/yyyy
            return DateTime(
              int.parse(parts[2]), // year
              int.parse(parts[1]), // month
              int.parse(parts[0]), // day
            );
          } else if (int.parse(parts[1]) > 12) {
            // MM/dd/yyyy
            return DateTime(
              int.parse(parts[2]), // year
              int.parse(parts[0]), // month
              int.parse(parts[1]), // day
            );
          } else {
            // Ambiguous, assume MM/dd/yyyy (US format)
            return DateTime(
              int.parse(parts[2]), // year
              int.parse(parts[0]), // month
              int.parse(parts[1]), // day
            );
          }
        }
      }

      return null;
    } catch (e) {
      return null;
    }
  }

  /// Parse UTC string to local DateTime (date only, no timezone shift)
  DateTime? toDateTimeFromUTC() {
    try {
      if (isEmpty) return null;

      // Parse the full datetime
      final utcDate = DateTime.parse(this);

      // Return date-only in LOCAL timezone (no time component)
      return DateTime(utcDate.year, utcDate.month, utcDate.day);
    } catch (e) {
      return null;
    }
  }

  /// Format date string to different format
  String reformatDate({
    String? inputFormat,
    String outputFormat = 'MMM dd, yyyy',
  }) {
    try {
      DateTime? date;
      if (inputFormat != null) {
        date = DateFormat(inputFormat).parse(this);
      } else {
        date = toDateTime();
      }

      if (date != null) {
        return DateFormat(outputFormat).format(date);
      }
      return this;
    } catch (e) {
      return this;
    }
  }
}

// ==========================================
// Helper Function for Your Controller
// ==========================================

/// Format DateTime string from API (handles timezone properly)
String? formatDateTime(String? dateString) {
  if (dateString == null || dateString.isEmpty) return null;

  try {
    // Parse the date (handles both UTC and local)
    final date = dateString.toDateTime();
    if (date != null) {
      // Return in MM/dd/yyyy format (or use any format you prefer)
      return date.toUSDate(); // or date.toSlashDate() for dd/MM/yyyy
    }
    return dateString;
  } catch (e) {
    return dateString;
  }
}

// ==========================================
// USAGE IN YOUR CONTROLLER
// ==========================================

/*

// In UserEditProfileScreenController:

void _prefillFormData() {
  final userProfile = userProfileController.userProfileModel.value;
  if (userProfile != null) {
    emailController.text = userProfile.email ?? '';
    nameController.text = userProfile.name ?? '';
    phoneNumberController.text = userProfile.phoneNumber ?? '';
    locationController.text = userProfile.location.en ?? '';

    // ✅ FIX: Use extension method
    dateOfBirthController.text = userProfile.dob?.toDateTime()?.toUSDate() ?? '';
    // or
    dateOfBirthController.text = userProfile.dob?.toDateTime()?.toSlashDate() ?? '';

    genderController.text = userProfile.gender.toUpperCase() ?? '';
  }
}

// When updating profile:
Future<bool> _updateProfileInfo() async {
  try {
    final String token = await SecureStorageService().read(
      AppConstants.accessToken,
    ) ?? '';

    // Parse the date to ensure proper format
    final dob = dateOfBirthController.text.toDateTime();

    final Map<String, dynamic> updateData = {
      'name': nameController.text.trim(),
      'phoneNumber': phoneNumberController.text.trim(),
      'location': locationController.text.trim(),
      'dob': dob?.toISODate() ?? dateOfBirthController.text.trim(), // Send as YYYY-MM-DD
      'gender': genderController.text.trim().toLowerCase(),
    };

    // ... rest of code
  } catch (e) {
    // handle error
  }
}

// In ProfileTab (Display):
ProfileTileModel(
  title: "Date of Birth",
  data: userProfileModel.value?.dob?.toDateTime()?.toShortDate() ?? 'N/A',
)

*/

// ==========================================
// QUICK REFERENCE
// ==========================================

/*

String formats:
- toShortDate()       → "Jan 15, 2024"
- toLongDate()        → "January 15, 2024"
- toSlashDate()       → "15/01/2024"
- toUSDate()          → "01/15/2024"
- toISODate()         → "2024-01-15"
- toDayMonthYear()    → "15 Jan 2024"

Parsing:
- "2024-01-15".toDateTime()                    → DateTime object
- "2024-01-15T00:00:00Z".toDateTime()         → DateTime object (strips time/timezone)
- "15/01/2024".toDateTime()                    → DateTime object
- "01/15/2024".toDateTime()                    → DateTime object

Display:
- DateTime.now().toShortDate()                 → "Jan 15, 2024"
- userProfile.dob?.toDateTime()?.toUSDate()    → "01/15/2024"

*/