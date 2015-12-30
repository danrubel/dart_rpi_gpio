library test.rpi_gpio.read_write;

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
  // This test assumes that [Mode.output] from wiringPi pin 1 (BMC_GPIO 18, Phys 12)
  // can be read as [Mode.input] on wiringPi pin 0 (BMC_GPIO 17, Phys 11).
  test('read/write digital', () {
    Pin sensorPin;
    Pin ledPin;

    testWriteRead() {
      assertValue(sensorPin, 0);
      for (int count = 0; count < 3; ++count) {
        ledPin.value = 1;
        assertValue(sensorPin, 1);
        ledPin.value = 0;
        assertValue(sensorPin, 0);
      }
    }

    sensorPin = pin(0, Mode.input)..pull = Pull.down;
    ledPin = pin(1, Mode.output)..value = 0;
    testWriteRead();

    sensorPin = pin(2, Mode.input)..pull = Pull.down;
    ledPin = pin(3, Mode.output)..value = 0;
    testWriteRead();
  });
}
