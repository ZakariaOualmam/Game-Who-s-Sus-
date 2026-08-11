/// A single vote cast by one player accusing another.
class Vote {
  Vote({required this.voterId, required this.targetId});

  final String voterId;
  final String targetId;
}
