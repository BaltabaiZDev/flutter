/// Where a shift is in time, relative to "now".
sealed class Countdown {
  const Countdown();

  /// A shift lasts [length]; before the start it is upcoming, during it
  /// it has started, after it has ended.
  factory Countdown.of(DateTime startsAt, Duration length, DateTime now) {
    if (now.isBefore(startsAt)) return Upcoming(startsAt.difference(now));
    final elapsed = now.difference(startsAt);
    if (elapsed < length) return Started(elapsed);
    return const Ended();
  }
}

class Upcoming extends Countdown {
  const Upcoming(this.left);
  final Duration left;
}

class Started extends Countdown {
  const Started(this.elapsed);
  final Duration elapsed;
}

class Ended extends Countdown {
  const Ended();
}
