import 'package:flutter_test/flutter_test.dart';

StreamMatcher expectNext<T>(Function(T value) matcher) {
  return StreamMatcher((queue) async {
    final next = await queue.next;
    matcher(next);
  }, "expectNext");
}
