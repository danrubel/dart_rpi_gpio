import 'dart:async';

import 'package:test/test.dart';

import '../example/debouncer.dart';

const testPinNum = 2;

void main() {
  var timeLimit = new Duration(milliseconds: 10);
  Completer<bool> completer;
  Completer cancelCompleter;
  var controller = new StreamController<bool>(onCancel: () {
    cancelCompleter.complete();
  });
  var debouncer = new Debouncer(false, 1);
  StreamSubscription subscription =
      controller.stream.transform(debouncer).listen((bool newValue) {
    completer.complete(newValue);
    completer = null;
  });

  test('one event', () async {
    completer = new Completer<bool>();
    controller.add(true);
    var future = completer.future.timeout(timeLimit);
    expect(await future, true);
  });

  test('two events ignored', () async {
    completer = new Completer<bool>();
    controller.add(false);
    controller.add(true);
    try {
      await completer.future.timeout(timeLimit);
      fail('expected timeout - should not be any events');
    } on TimeoutException {
      // Expected timeout... no events
    }
  });

  test('three events collapsed to one', () async {
    completer = new Completer<bool>();
    controller.add(false);
    controller.add(true);
    controller.add(false);
    // Expect one result ... no exceptions from additional events
    expect(await completer.future.timeout(timeLimit), false);
    await new Future.delayed(timeLimit);
  });

  test('cancel', () async {
    cancelCompleter = new Completer();
    subscription.cancel();
    await cancelCompleter.future.timeout(timeLimit);
  });
}
