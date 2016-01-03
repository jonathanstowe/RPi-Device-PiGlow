use v6;

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

}
# vim: expandtab shiftwidth=4 ft=perl6
