import '../models.dart';

const List<String> _months = [
  'Jan',
  'Feb',
  'Mar',
  'Apr',
  'May',
  'Jun',
  'Jul',
  'Aug',
  'Sep',
  'Oct',
  'Nov',
  'Dec',
];

String _two(int n) => n.toString().padLeft(2, '0');

String formatDate(DateTime d) => '${d.day} ${_months[d.month - 1]}';

String formatTime(DateTime d) => '${_two(d.hour)}:${_two(d.minute)}';

String formatDateTime(DateTime d) => '${formatDate(d)}, ${formatTime(d)}';

String formatDuration(Duration d) {
  if (d.inDays > 0) return '${d.inDays} d ${d.inHours.remainder(24)} h';
  if (d.inHours > 0) return '${d.inHours} h ${d.inMinutes.remainder(60)} min';

  return '${d.inMinutes} min';
}

String formatCountdown(Countdown c) => switch (c) {
  Upcoming(:final timeLeft) => 'Starts in ${formatDuration(timeLeft)}',
  Started(:final elapsed) => 'Started ${formatDuration(elapsed)} ago',
  Ended() => 'Ended',
};
