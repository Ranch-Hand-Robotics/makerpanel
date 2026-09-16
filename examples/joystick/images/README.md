# Joystick wiring illustration

Open [ads1219-wiring.png](ads1219-wiring.png) for the complete wiring image.
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