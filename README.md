rpi_gpio is a Dart library for accessing the Raspberry Pi GPIO pins.

## Overview

 * [__Gpio__](lib/rpi_gpio.dart) provides a high level API for accessing
   the various General Purpose I/O pins on the Raspberry Pi.
 
 * [__RpiHardware__](lib/rpi_hardware.dart) provides a low level API
   for accessing the GPIO pins.

## Setup

The rpi_gpio library accesses the GPIO pins using a native library written
in C and built on top of the [wiringPi](http://wiringpi.com/) library.
For security reasons, authors cannot publish binary content
to [pub.dartlang.org](https://pub.dartlang.org/), so there are some extra
steps necessary to compile the native library on the RPi before this package
can be used.

1) Activate the rpi_gpio package using the
[pub global](https://www.dartlang.org/tools/pub/cmd/pub-global.html) command.
```
    pub global activate rpi_gpio
```

2) From your application directory (the application that references
the rpi_gpio package) run the following command to build the native library
```
    pub global run rpi_gpio:build_lib
```

## Example

 * A [simple example](example/pwm_motor_sample.dart) shows how to drive
   motors using the [high level GPIO library](lib/rpi_gpio.dart).
 
 * A simple [blinking LED example](example/hardware_blink_sample.dart)
   shows how to use the [low level hardware API](lib/rpi_hardware.dart).