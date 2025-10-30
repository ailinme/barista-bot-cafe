class RateLimiter {
  final int maxAttempts;
  final Duration window;
  final Duration lockout;

  int _attempts = 0;
  DateTime _windowStart = DateTime.fromMillisecondsSinceEpoch(0);
  DateTime? _lockedUntil;

  RateLimiter({this.maxAttempts = 5, this.window = const Duration(minutes: 1), this.lockout = const Duration(seconds: 30)});

  bool get isLocked {
    if (_lockedUntil == null) return false;
    if (DateTime.now().isAfter(_lockedUntil!)) {
      _lockedUntil = null;
      _attempts = 0;
      _windowStart = DateTime.now();
      return false;
    }
    return true;
  }

  Duration? timeRemaining() {
    if (!isLocked) return null;
    return _lockedUntil!.difference(DateTime.now());
  }

  void registerAttempt({required bool success}) {
    final now = DateTime.now();
    if (now.difference(_windowStart) > window) {
      _windowStart = now;
      _attempts = 0;
    }
    if (success) {
      _attempts = 0;
      _lockedUntil = null;
      return;
    }
    _attempts++;
    if (_attempts >= maxAttempts) {
      _lockedUntil = now.add(lockout);
    }
  }
}

