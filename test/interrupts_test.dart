library test.rpi_gpio.interrupts;

import 'dart:async';

import 'package:rpi_gpio/rpi_gpio.dart';
import 'package:test/test.dart';

import 'test_util.dart';

// Current test hardware configuration:
// pin 4 unconnected but with an internal pull up/down resistor setting
// pin 3 = an LED (1 = on, 0 = off)
// pin 2 = a photo resistor detecting the state of the LED on pin 3
// pin 1 = an LED (1 = on, 0 = off)
// pin 0 = a photo resistor detecting the state of the LED on pin 1

main() async {
  await setupHardware();
  runTests();
}

runTests() {
  // TODO fix so that this method need not be called
  Gpio.instance;

  // This test assumes that Mode.output from wiringPi pin 1 (BMC_GPIO 18, Phys 12)
  // can trigger an interrupt on wiringPi pin 0 (BMC_GPIO 17, Phys 11),
  // and Mode.output from wiringPi pin 3 (BMC_GPIO 22, Phys 15)
  // can be read as [Mode.input] on wiringPi pin 2  (BMC_GPIO 27, Phys 13).
  test('interrupts', () async {
    Pin sensorPin;
    Pin ledPin;

    testInterrupt() async {
      assertValue(sensorPin, 0);
      var expectedSensorValue;
      var completer;
      var subscription = sensorPin.events.listen((PinEvent event) {
        if (!identical(event.pin, sensorPin)) fail('expected sensor pin');
        if (event.value == expectedSensorValue) completer.complete();
      });

      // When LED turns on, assert that a sensor pin interrupt occurred
      // and that the sensor value is 1.
      expectedSensorValue = 1;
      var waitTime = new Duration(milliseconds: 100);
      completer = new Completer();
      var future = completer.future.timeout(waitTime).catchError((e) {
        subscription.cancel();
        throw 'Expected value $expectedSensorValue on $sensorPin\n$e';
      });
      ledPin.value = 1;
      await future;

      // When LED turns off, assert that a sensor pin interrupt occurred
      // and that the sensor value is 0.
      expectedSensorValue = 0;
      completer = new Completer();
      future = completer.future.timeout(waitTime).catchError((e) {
        subscription.cancel();
        throw 'Expected value $expectedSensorValue on $sensorPin\n$e';
      }).whenComplete(() {
        subscription.cancel();
      });
      ledPin.value = 0;
      await future;
    }

    // Instantiate high # pin to check disable interrupts bug is fixed
    // https://github.com/danrubel/rpi_gpio.dart/issues/7
    pin(10, Mode.input);

    sensorPin = pin(0, Mode.input)..pull = pullDown;
    ledPin = pin(1, Mode.output)..value = 0;
    await testInterrupt();

    sensorPin = pin(2, Mode.input)..pull = pullDown;
    ledPin = pin(3, Mode.output)..value = 0;
    await testInterrupt();
  });
}
