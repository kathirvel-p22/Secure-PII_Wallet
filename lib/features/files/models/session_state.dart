/// Session state for app lock/unlock
class SessionState {
  final bool locked;
  final int failedAttempts;
  final DateTime? lastUnlockAt;
  final DateTime? lockedUntil;

  SessionState({
    required this.locked,
    this.failedAttempts = 0,
    this.lastUnlockAt,
    this.lockedUntil,
  });

  SessionState copyWith({
    bool? locked,
    int? failedAttempts,
    DateTime? lastUnlockAt,
    DateTime? lockedUntil,
  }) {
    return SessionState(
      locked: locked ?? this.locked,
      failedAttempts: failedAttempts ?? this.failedAttempts,
      lastUnlockAt: lastUnlockAt ?? this.lastUnlockAt,
      lockedUntil: lockedUntil ?? this.lockedUntil,
    );
  }

  bool get isLocked {
    return locked || isTemporarilyLocked;
  }

  bool get isTemporarilyLocked {
    if (lockedUntil == null) return false;
    return DateTime.now().isBefore(lockedUntil!);
  }

  Duration? get remainingLockTime {
    if (!isTemporarilyLocked) return null;
    return lockedUntil!.difference(DateTime.now());
  }
}
