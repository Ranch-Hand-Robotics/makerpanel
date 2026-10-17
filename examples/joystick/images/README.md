# Joystick wiring illustration

Open [controller-wiring.png](controller-wiring.png) for the complete controller
diagram, or [controller-wiring.svg](controller-wiring.svg) to zoom without
losing detail. It is a standalone, original vector illustration with no
external image dependencies. It includes:

- SparkFun Pro Micro RP2350 front-view header map, with USB-C at the top.
- Qwiic cable: 3V3, GND, GPIO16/SDA and GPIO17/SCL.
- Both three-pot joysticks and their normally open top buttons.
- AIN1 button pull-up from REFP through 4.7 kohm, plus optional 100 nF filter.
- GPIO3 normally closed stop auxiliary contact and its 4.7 kohm pull-up.

Matching signal names are connected nets, not additional components.
Board drawings are simplified, not dimensionally accurate templates; Qwiic
connectors are drawn as whole keyed sockets, not individual pin diagrams.
Colors distinguish signals and do not specify joystick harness wire colors.

X/Y labels identify the original, unrotated potentiometers and wiring nets.
Both joysticks now mount 90 degrees right. Joystick 1 uses
**new X = old Y, new Y = -old X**. Joystick 2 includes a horizontal polarity
correction: **Rx = -old Y, Ry = -old X**. Only ADS horizontal output is
reversed relative to the initial rotation firmware. Do not swap the
diagram's wires as well. Twist and buttons are unchanged.

The Pro Micro header ordering was checked against the official component-side
photo (rotated conceptually so USB-C points up) and Eagle schematic:

- [SparkFun front-view reference](https://raw.githubusercontent.com/sparkfun/SparkFun_Pro_Micro_RP2350/main/docs/assets/img/Pro_Micro_RP2350-Front_Cropped.jpg)
- [SparkFun schematic](https://github.com/sparkfun/SparkFun_Pro_Micro_RP2350/blob/main/Hardware/SparkFun_ProMicro_RP2350.sch)
- [Pico SDK board definition](https://github.com/raspberrypi/pico-sdk/blob/master/src/boards/include/boards/sparkfun_promicro_rp2350.h)

The schematic and SDK agree on **GPIO16=SDA, GPIO17=SCL**. SparkFun's
hardware-overview prose reverses those two labels; the diagram follows the
schematic and firmware instead. The Pro Micro drawing is original artwork,
not a redistributed SparkFun photograph.

## ADS1219 photo detail

Open [ads1219-wiring.png](ads1219-wiring.png) for the ADC photo wiring detail.
The editable version is [ads1219-wiring.svg](ads1219-wiring.svg).
Keep `ads1219-board.jpg` beside it: the SVG references that local photograph.

The photograph is a full-board view of the same SparkFun ADS1219 board shown
in the user's cropped photo. It was cropped from SparkFun's front/back
illustration, without changing the board orientation. Colored leaders point
to the outer header row, not the adjacent ground/VDDA row. The symbol drawings
describe electrical connections, not physical joystick connector pin order.

Only one additional capacitor is shown: an optional 100 nF ceramic across
the second joystick's top button. Supply bypass capacitors are already on
this breakout. The firmware uses the external reference: REFP must connect
to the same 3.3 V supply as the potentiometers, and REFN to common ground.

## Attribution and license

Board photograph: SparkFun Electronics.
Changes: front-board crop and new joystick wiring annotations.
This adapted illustration is distributed under
[Creative Commons Attribution-ShareAlike 4.0](https://creativecommons.org/licenses/by-sa/4.0/).
No SparkFun endorsement is implied.

- [Original image](https://raw.githubusercontent.com/sparkfun/SparkFun_Qwiic_ADC_ADS1219/main/docs/assets/img/Qwiic_ADC_AS1219-Annotated.jpg)
- [Hardware overview and header description](https://github.com/sparkfun/SparkFun_Qwiic_ADC_ADS1219/blob/main/docs/hardware_overview.md)
- [SparkFun repository license](https://github.com/sparkfun/SparkFun_Qwiic_ADC_ADS1219/blob/main/LICENSE.md)