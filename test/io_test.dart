import 'dart:async';

import 'package:rpi_gpio/gpio.dart';
import 'package:rpi_gpio/rpi_gpio.dart';
import 'package:test/test.dart';

import 'test_util.dart';

main() {
  gpio = RpiGpio();
  runTests();
  test('dispose', () => gpio.dispose());
}

runTests() {
  // Current test hardware configuration:
  // pin 16 = output connected to a relay input
  //   true = LED off and relay open
  //   false  = LED on and relay closed
  // pin 40 = input (pull up) connected to relay (normally open) output
  //   relay common connected to GND
  const outputPhysicalPin = 16;
  const inputPhysicalPin = 40;

  const delay = Duration(milliseconds: 200);
  const timeout = Duration(seconds: 2);

  GpioOutput outputPin;
  GpioInput inputPin;

  test('setup', () {
    outputPin = gpio.output(outputPhysicalPin);
    inputPin = gpio.input(inputPhysicalPin, Pull.up);
  });

  test('exceptions', () async {
    // Cannot reallocate pins
    expectThrows(() => gpio.output(outputPhysicalPin));
    expectThrows(() => gpio.input(outputPhysicalPin));
    expectThrows(() => gpio.input(outputPhysicalPin, Pull.up));
    expectThrows(() => gpio.output(inputPhysicalPin));
    expectThrows(() => gpio.input(inputPhysicalPin));
    expectThrows(() => gpio.input(inputPhysicalPin, Pull.down));
  });

  test('blink', () async {
    for (int count = 0; count < 3; ++count) {
      outputPin.value = false; // relay on
      await Future.delayed(Duration(milliseconds: 500));
      outputPin.value = true; // relay off
      await Future.delayed(Duration(milliseconds: 500));
    }
  });

  test('current value', () async {
    for (int count = 0; count < 2; ++count) {
      outputPin.value = false; // relay on
      await waitForInputValue(inputPin, false);
      await Future.delayed(delay);
      outputPin.value = true; // relay off
      await waitForInputValue(inputPin, true);
      await Future.delayed(delay);
    }
  });

  StreamSubscription<bool> subscription;

  test('values stream', () async {
    Completer<bool> completer = Completer<bool>();
    subscription = inputPin.values.listen((bool newValue) {
      completer.complete(newValue);
    });
    // values should send the current value when starting to listen
    expect(await completer.future.timeout(timeout), true);

    for (int count = 0; count < 2; ++count) {
      completer = Completer<bool>();
      outputPin.value = false; // relay on
      expect(await completer.future.timeout(timeout), false);
      await Future.delayed(delay);
      completer = Completer<bool>();
      outputPin.value = true; // relay off
      expect(await completer.future.timeout(timeout), true);
      await Future.delayed(delay);
    }
  });

  tearDownAll(() {
    subscription?.cancel();
    outputPin.value = true; // relay off
  });
}

waitForInputValue(GpioInput pin, bool expectedValue) async {
  final start = nowMillis;
  while (nowMillis - start < 2000) {
    if (pin.value == expectedValue) return;
    await Future.delayed(Duration(milliseconds: 10));
  }
  throw 'timeout';
}
