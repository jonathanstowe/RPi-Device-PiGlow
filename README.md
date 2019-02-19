# RPi::Device::PiGlow

Interface for the [PiGlow](https://shop.pimoroni.com/products/piglow) device on the Raspberry Pi


## Synopsis

```perl6

    use RPi::Device::PiGlow;
    my $pg = RPi::Device::PiGlow.new();

    my $values = [0x01,0x02,0x04,0x08,0x10,0x18,0x20,0x30,0x40,0x50,0x60,0x70,0x80,0x90,0xA0,0xC0,0xE0,0xFF];
    $pg.enable-output;
    $pg.enable-all-leds;
    $pg.write-all-leds($values);
    sleep 10;
    $pg.reset;

```

See the [examples](examples) directory for more ways of using this.

## Description

The [PiGlow from Pimoroni](http://shop.pimoroni.com/products/piglow)
is a small board that plugs in to the Raspberry PI's GPIO header with
18 LEDs on that can be addressed individually via i²c.  This module
uses RPi::Device::SMBus to abstract the interface to the device so
that it can be controlled from a Perl programme.  It is assumed that
you have installed the OS packages required to make i2c work and have
configured and tested the i²c appropriately.  The only difference that
seems to affect the PiGlow device is that it only seems to be reported
by i2cdetect if you use the "quick write" probe flag:

   sudo i2cdetect -y -q 1

(assuming you have a Rev B. or version 2 Pi - if not you should supply
0 instead of 1.)  I have no way of knowing the compatibility of the
"quick write" with any other devices you may have plugged in to the Pi,
so I wouldn't recommend doing this with any other devices unless you know
that they won't be adversely affected by "quick write".  The PiGlow has
a fixed address anyway so the information isn't that useful.

A useful quick guide to setting up for the Rapberry Pi 2 can be found
at https://blog.robseder.com/2015/04/12/getting-a-piglow-to-work-with-a-raspberry-pi-2/ though
most of that will work for other versions.

With a more recent Raspbian install you may just be able to switch on 
the ```raspi-config``` program, via ```5. Interfacing Options```

## Installation

Assuming you have a working Rakudo Perl 6 installation you should be able to
install this with *zef* :

    # From the source directory
   
    zef install .

    # Remote installation

    zef install RPi::Device::PiGlow

## Support

Suggestions/patches are welcomed via github at:

https://github.com/jonathanstowe/RPi-Device-PiGlow/issues

Because there are limited ways to test this automatically without
physically observing the device, there may be untested bugs.

## Licence

This is free software.

Please see the [LICENCE](LICENCE) file in the distribution

© Jonathan Stowe 2016 - 2019
