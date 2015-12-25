library test.rpi_gpio;

import 'package:rpi_gpio/rpi_gpio.dart';
import 'package:test/test.dart';

import 'basic_test.dart' as basic;
import 'interrupts_test.dart' as interrupts;
import 'read_write_test.dart' as read;
import 'test_util.dart';

main() async {
  await setupHardware();
  runTests();
}

runTests() {
  basic.runTests();
  read.runTests();
  interrupts.runTests();

  test('pins used', () {
    // Ensure LEDs are off
    pin(1, Mode.output)..value = 0;
    pin(3, Mode.output)..value = 0;
    // Print pin state changes
    if (recording != null) recording.printUsage();
  });
}
