String durationFormat(double duration) {
  final int hours = duration ~/ 3600;
  final int minutes = (duration % 3600) ~/ 60;
  final int seconds = (duration % 60).toInt();

  if (hours > 0) {
    return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
}
