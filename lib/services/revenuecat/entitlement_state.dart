enum EntitlementStatus { loading, free, pro, error }

class EntitlementState {
  const EntitlementState._({required this.status, this.errorMessage});

  const EntitlementState.loading() : this._(status: EntitlementStatus.loading);

  const EntitlementState.free() : this._(status: EntitlementStatus.free);

  const EntitlementState.pro() : this._(status: EntitlementStatus.pro);

  const EntitlementState.error(String message)
    : this._(status: EntitlementStatus.error, errorMessage: message);

  final EntitlementStatus status;
  final String? errorMessage;

  bool get isPro => status == EntitlementStatus.pro;
}
