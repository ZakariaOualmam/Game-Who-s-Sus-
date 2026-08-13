import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';

/// fake_cloud_firestore's dummy transaction applies `set`/`update`/`delete`
/// without awaiting the underlying writes, so queries issued immediately after
/// a transaction can observe stale data. This subclass flushes the event loop
/// after every transaction so tests stay deterministic.
class SettlingFirestore extends FakeFirebaseFirestore {
  SettlingFirestore();

  @override
  Future<T> runTransaction<T>(
    TransactionHandler<T> transactionHandler, {
    Duration timeout = const Duration(seconds: 30),
    int maxAttempts = 5,
  }) async {
    final result = await super.runTransaction<T>(
      transactionHandler,
      timeout: timeout,
      maxAttempts: maxAttempts,
    );

    for (var i = 0; i < 10; i++) {
      await Future<void>.delayed(Duration.zero);
    }

    return result;
  }
}
