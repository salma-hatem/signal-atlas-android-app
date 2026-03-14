
// Convert timestamp to readable format
String formatTimestamp(DateTime timestamp, {String format = 'hms'}) {
  final duration = Duration(milliseconds: timestamp.millisecondsSinceEpoch.toInt());

  final hours = duration.inHours;
  final minutes = duration.inMinutes % 60;
  final seconds = duration.inSeconds % 60;

  switch (format) {
    case 's': // seconds only
      return '${duration.inSeconds}s';
    case 'ms': // minutes and seconds
      return '${duration.inMinutes}m ${seconds}s';
    case 'hms': // hours, minutes, seconds
      return '${hours}h ${minutes}m ${seconds}s';
    case 'hm': // hours and minutes
      return '${hours}h ${minutes}m';
    default:
      return '${hours}h ${minutes}m ${seconds}s';
  }
}

// Get hours, minutes, seconds, milliseconds from Timestamp
double getTimeFromTimestamp(DateTime timestamp, {String format = 'hms'}) {
  final duration = Duration(milliseconds: timestamp.millisecondsSinceEpoch.toInt());

  final hours = duration.inHours;
  final minutes = duration.inMinutes % 60;
  final seconds = duration.inSeconds % 60;

  switch (format) {
    case 's': // seconds
      return seconds.toDouble();
    case 'ms': // milliseconds
      return duration.inMilliseconds.toDouble();
    case 'm': // minutes
      return minutes.toDouble();
    case 'h': // hours
      return hours.toDouble();
    default:
      return hours.toDouble();
  }
}

// Get Relative time between 2 Timestamps
double getRelativeSeconds(DateTime timestamp, DateTime start) {
  return timestamp.difference(start).inSeconds.toDouble();
}

// Format seconds into mm:ss string
String formatSeconds(double seconds) {
  final mins = (seconds ~/ 60).toInt();
  final secs = (seconds % 60).toInt();
  return '${mins}m ${secs}s';
}

// Get Date from Timestamp
String getDateFromTimestamp(int timestamp, String period) {
  final date = DateTime.fromMillisecondsSinceEpoch(timestamp);

  switch (period) {
    case "Past 24h":
      final minute = date.minute.toString().padLeft(2, '0');
      return "${date.hour}";

    case "Past week":
      const days = [
        "Mon",
        "Tue",
        "Wed",
        "Thu",
        "Fri",
        "Sat",
        "Sun"
      ];
      return days[date.weekday - 1];

    case "Past month":
      return date.day.toString();

    default:
      return date.toString();
  }
}
