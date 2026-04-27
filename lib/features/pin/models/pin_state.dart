class PinState {
  final bool isSetup;
  final int pinLength;
  final int failedAttempts;
  final DateTime? lockedUntil;

  const PinState({
    this.isSetup = false,
    this.pinLength = 4,
    this.failedAttempts = 0,
    this.lockedUntil,
  });

  PinState copyWith({
    bool? isSetup,
    int? pinLength,
    int? failedAttempts,
    DateTime? lockedUntil,
  }) {
    return PinState(
      isSetup: isSetup ?? this.isSetup,
      pinLength: pinLength ?? this.pinLength,
      failedAttempts: failedAttempts ?? this.failedAttempts,
      lockedUntil: lockedUntil ?? this.lockedUntil,
    );
  }

  bool get isLocked {
    if (lockedUntil == null) return false;
    return DateTime.now().isBefore(lockedUntil!);
  }

  Duration get lockTimeRemaining {
    if (!isLocked) return Duration.zero;
    return lockedUntil!.difference(DateTime.now());
  }
}