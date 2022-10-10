import 'dart:io';
import 'dart:math';

import 'package:test/test.dart';

import '../bin/source/pool.dart';

class OmgError extends Error {}

void main() {
  test("one", () async {
    final r = Random();
    final pool = TaskPool<int>(concurrency: 4);
    final futures = List<Future<int>>.empty(growable: true);
    int maxEver = 0;
    for (int i = 0; i < 100; ++i) {
      futures.add(pool.run(() async {
        expect(pool.currentlyRunning, lessThanOrEqualTo(4));
        maxEver = max(maxEver, pool.currentlyRunning);
        sleep(Duration(milliseconds: r.nextInt(50)));

        if (i%4==0) {
          throw OmgError();
        }

        expect(pool.currentlyRunning, lessThanOrEqualTo(4));
        maxEver = max(maxEver, pool.currentlyRunning);
        return 3;
      }));
    }

    int success = 0;
    int errors = 0;

    for (final r in futures) {
      try {
        await r;
        success++;
      } on OmgError catch (_) {
        errors++;
      }
    }

    expect(errors, 25);
    expect(success, 75);
    expect(pool.currentlyRunning, 0);
  });
}
