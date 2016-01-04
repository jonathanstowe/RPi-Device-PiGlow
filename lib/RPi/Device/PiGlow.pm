use v6;

=begin pod

=head1 NAME

RPi::Device::PiGlow - Interface to the PiGlow board using i2c

=head1 SYNOPSIS

=begin code

    use RPi::Device::PiGlow;
    my $pg = RPi::Device::PiGlow.new();

    my $values = [0x01,0x02,0x04,0x08,0x10,0x18,0x20,0x30,0x40,0x50,0x60,0x70,0x80,0x90,0xA0,0xC0,0xE0,0xFF];
    $pg.enable-output;
    $pg.enable-all-leds;
    $pg.write-all-leds($values);
    sleep 10;
    $pg.reset;

=end code

See the L<examples> directory for more ways of using this.

=head1 DESCRIPTION

The L<PiGlow from Pimoroni|http://shop.pimoroni.com/products/piglow>
is a small board that plugs in to the Raspberry PI's GPIO header with
18 LEDs on that can be addressed individually via i2c.  This module
uses L<RPi::Device::SMBus> to abstract the interface to the device so
that it can be controlled from a Perl programme.  It is assumed that
you have installed the OS packages required to make i2c work and have
configured and tested the i2c appropriately.  The only difference that
seems to affect the PiGlow device is that it only seems to be reported
by C<i2cdetect> if you use the "quick write" probe flag:

   sudo i2cdetect -y -q 1

(assuming you have a Rev B. Pi - if not you should supply 0 instead
of 1.)  I have no way of knowing the compatibility of the "quick write"
with any other devices you may have plugged in to the Pi, so I wouldn't
recommend doing this with any other devices unless you know that they
won't be adversely affected by "quick write".  The PiGlow has a fixed
address anyway so the information isn't that useful.

=end pod

class RPi::Device::PiGlow {
    use RPi::Device::SMBus;

    constant CMD_ENABLE_OUTPUT    = 0x00;
    constant CMD_ENABLE_LEDS      = 0x13;
    constant CMD_ENABLE_LEDS_1    = 0x13;
    constant CMD_ENABLE_LEDS_2    = 0x14;
    constant CMD_ENABLE_LEDS_3    = 0x15;
    constant CMD_SET_PWM_VALUES   = 0x01;
    constant CMD_SET_PWM_VALUE_1  = 0x01;
    constant CMD_SET_PWM_VALUE_2  = 0x02;
    constant CMD_SET_PWM_VALUE_3  = 0x03;
    constant CMD_SET_PWM_VALUE_4  = 0x04;
    constant CMD_SET_PWM_VALUE_5  = 0x05;
    constant CMD_SET_PWM_VALUE_6  = 0x06;
    constant CMD_SET_PWM_VALUE_7  = 0x07;
    constant CMD_SET_PWM_VALUE_8  = 0x08;
    constant CMD_SET_PWM_VALUE_9  = 0x09;
    constant CMD_SET_PWM_VALUE_10 = 0x0A;
    constant CMD_SET_PWM_VALUE_11 = 0x0B;
    constant CMD_SET_PWM_VALUE_12 = 0x0C;
    constant CMD_SET_PWM_VALUE_13 = 0x0D;
    constant CMD_SET_PWM_VALUE_14 = 0x0E;
    constant CMD_SET_PWM_VALUE_15 = 0x0F;
    constant CMD_SET_PWM_VALUE_16 = 0x10;
    constant CMD_SET_PWM_VALUE_17 = 0x11;
    constant CMD_SET_PWM_VALUE_18 = 0x12;
    constant CMD_UPDATE           = 0x16;
    constant CMD_RESET            = 0x17;

    constant NUM_LEDS             = 18;

    has RPi::Device::SMBus::DevicePath  $.i2c-bus-device-path = '/dev/i2c-1';
    has RPi::Device::SMBus::I2C-Address $.i2c-device-address  = 0x054;

    has RPi::Device::SMBus              $.device-smbus;

    method device-smbus() returns RPi::Device::SMBus handles <write-byte write-block-data> {
        if not $!device-smbus.defined {
            $!device-smbus = RPi::Device::SMBus.new(
                                                    address => $!i2c-device-address, 
                                                    device  =>  $!i2c-bus-device-path
                                                   );
        }
        $!device-smbus;
    }

    has @!led-bank-enable-registers = CMD_ENABLE_LEDS_1, CMD_ENABLE_LEDS_2, CMD_ENABLE_LEDS_3;

    method update() returns Int {
        self.write-byte(CMD_UPDATE, 0xFF);
    }

    method enable-all-leds() returns Int {
        self.write-block-data(CMD_ENABLE_LEDS, [0xFF, 0xFF, 0xFF]);
    }

    method write-all-leds(@values is copy, :$fix) returns Int {
        if $fix {
            @values = self.gamma-fix-values(@values);
        }
        self.write-block-data(CMD_SET_PWM_VALUES, @values);
        self.update;
    }

    method all-off() returns Int {

        my @vals = 0 xx NUM_LEDS;
        self.write-all-leds(@vals);
    }

    method set-leds(@leds, Int $value is copy ) {
        $value = self.map-gamma($value);
        for @leds -> $led {
            self.write-byte(self.get-led-register($led), $value);
        }
    }

    has @.led-table handles ( 'get-led-register' => 'AT-POS' ) = get-led-table();

    sub get-led-table() returns Array {
        return [
             CMD_SET_PWM_VALUE_7,
             CMD_SET_PWM_VALUE_8,
             CMD_SET_PWM_VALUE_9,
             CMD_SET_PWM_VALUE_6,
             CMD_SET_PWM_VALUE_5,
             CMD_SET_PWM_VALUE_10,
             CMD_SET_PWM_VALUE_18,
             CMD_SET_PWM_VALUE_17,
             CMD_SET_PWM_VALUE_16,
             CMD_SET_PWM_VALUE_14,
             CMD_SET_PWM_VALUE_12,
             CMD_SET_PWM_VALUE_11,
             CMD_SET_PWM_VALUE_1,
             CMD_SET_PWM_VALUE_2,
             CMD_SET_PWM_VALUE_3,
             CMD_SET_PWM_VALUE_4,
             CMD_SET_PWM_VALUE_15,
             CMD_SET_PWM_VALUE_13,
          ];
    }

    has @.ring-table;

    method ring-table() returns Array handles ( 'get-ring-leds' => 'AT-POS' ) {
        if @!ring-table.elems == 0 {
            for ^6 -> $led  {
                for ^3 -> $arm {
                    my $led-no = self.get-arm-leds($arm)[$led];
                    @!ring-table[$led].push($led-no);
                }
            }
        }
        return @!ring-table;
    }

    subset Ring of Int where { $_ >= 0 && $_ <= 5 };

    method set-ring(Ring $ring, $value) {
        my @ring-leds = self.get-ring-leds($ring);
        self.set-leds(@ring-leds, $value);
    }

    has @.arm-table handles ( 'get-arm-leds' => 'AT-POS' ) = get-arm-table();

    sub get-arm-table() returns Array {
        return [
                [0,1,2,3,4,5],
                [6,7,8,9,10,11],
                [12,13,14,15,16,17]
               ];
    }

    subset Arm of Int where { $_ >= 0 && $_ <= 2 };

    method set-arm(Arm $arm, $value ) {
        my @arm-leds = self.get-arm-leds($arm);
        self.set-leds(@arm-leds, $value);
    }

    has %.colour-table handles ( 'get-colour-leds' => 'AT-KEY', 'colours' => 'keys' ) = get-colour-table();

    sub get-colour-table() returns Hash {
        return {
                    white   => [5,11,17],
                    blue    => [4,10,16],
                    green   => [3,9,15],
                    yellow  => [2,8,14],
                    orange  => [1,7,13],
                    red     => [0,6,12]     ,
               };
    }

    subset Colour of Str where { get-colour-table{$_}:exists };

    method set-colour(Colour $colour, $value) {
        my @colour-leds = self.get-colour-leds($colour);
        self.set-leds(@colour-leds, $value);
    }

    has @.gamma-table handles ( 'map-gamma' => 'AT-POS' ) = get-gamma-table();

    sub get-gamma-table() returns Array {
        return [
            0,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,
            1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,
            1,   1,   1,   1,   2,   2,   2,   2,   2,   2,   2,   2,   2,   2,
            2,   2,   2,   2,   2,   2,   2,   2,   2,   3,   3,   3,   3,   3,
            3,   3,   3,   3,   3,   3,   3,   3,   4,   4,   4,   4,   4,   4,
            4,   4,   4,   4,   4,   5,   5,   5,   5,   5,   5,   5,   5,   6,
            6,   6,   6,   6,   6,   6,   7,   7,   7,   7,   7,   7,   8,   8,
            8,   8,   8,   8,   9,   9,   9,   9,   10,  10,  10,  10,  10,  11,
            11,  11,  11,  12,  12,  12,  13,  13,  13,  13,  14,  14,  14,  15,
            15,  15,  16,  16,  16,  17,  17,  18,  18,  18,  19,  19,  20,  20,
            20,  21,  21,  22,  22,  23,  23,  24,  24,  25,  26,  26,  27,  27,
            28,  29,  29,  30,  31,  31,  32,  33,  33,  34,  35,  36,  36,  37,
            38,  39,  40,  41,  42,  42,  43,  44,  45,  46,  47,  48,  50,  51,
            52,  53,  54,  55,  57,  58,  59,  60,  62,  63,  64,  66,  67,  69,
            70,  72,  74,  75,  77,  79,  80,  82,  84,  86,  88,  90,  91,  94,
            96,  98,  100, 102, 104, 107, 109, 111, 114, 116, 119, 122, 124, 127,
            130, 133, 136, 139, 142, 145, 148, 151, 155, 158, 161, 165, 169, 172,
            176, 180, 184, 188, 192, 196, 201, 205, 210, 214, 219, 224, 229, 234,
            239, 244, 250, 255,
        ];
    }

    method gamma-fix-values(@values is copy) returns Array {
        @values = @values.map({ self.map-gamma($_) });
        return @values;
    }

    method reset() returns Int {
        self.write-byte(CMD_RESET, 0xFF);
    }

}
# vim: expandtab shiftwidth=4 ft=perl6