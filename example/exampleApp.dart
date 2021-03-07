import 'dart:async';

import 'package:rpi_gpio/gpio.dart';

import 'debouncer.dart';

const dutyCycleValues = [100, 50, 100, 25, 100, 10, 100];

Future runExample(Gpio gpio, {Duration blink, int debounce}) async {
  blink ??= const Duration(milliseconds: 500);
  debounce ??= 250;

  // Blink the LED 3 times for each PWM level
  final led = gpio.output(15);
  final pwmLed = gpio.pwm(12);
  for (var dutyCycle in dutyCycleValues) {
    pwmLed.dutyCycle = dutyCycle;
    print('PWM Led brightness $dutyCycle %');
    for (int count = 0; count < 3; ++count) {
      led.value = true;
      await Future.delayed(blink);
      led.value = false;
      await Future.delayed(blink);
    }
  }
  pwmLed.dutyCycle = 0; // off

  // Wait for the button to be pressed 3 times
  final button = gpio.input(11);
  bool lastValue = button.value;
  int count = 0;
  final completer = Completer();
  final subscription = button.values
      .transform(Debouncer(lastValue, debounce))
      .listen((bool newValue) {
    if (lastValue == true && !newValue) {
      ++count;
      if (count == 3) {
        completer.complete();
      }
    }
    led.value = lastValue = newValue;
  });
  print('Waiting for 3 button presses...');
  await completer.future;

  // Cleanup before exit
  await subscription.cancel();
  gpio.dispose();
  print('Complete');
}
