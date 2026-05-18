# MakerPanel Joystick Firmware (RP2350) — Copilot Instructions

## Project summary
This repository contains firmware for a USB HID joystick running on a SparkFun Pro Micro RP2350 board (`PICO_BOARD=sparkfun_promicro_rp2350`).

The firmware:
- Reads 3 analog axes from potentiometers using ADC
- Reads a top pushbutton with internal pull-up + debounce
- Applies per-axis calibration, optional inversion, deadzone, and smoothing
- Sends USB HID gamepad reports using TinyUSB

Primary source files:
- `joystick.cpp` — joystick logic, axis processing pipeline, HID report loop
- `usb_hid_descriptors.c` — USB device/HID descriptors and strings
- `tusb_config.h` — TinyUSB device configuration
- `CMakeLists.txt` — Pico SDK target and library linkage

## Hardware mapping
- X axis: `A0` / `GPIO26` / `ADC0`
- Y axis: `A1` / `GPIO27` / `ADC1`
- Yaw axis: `A2` / `GPIO28` / `ADC2`
- Button: `GPIO2` to GND (internal pull-up, active-low)

Pot wiring convention:
- Pot outer pins: `3V3` and `GND`
- Pot wiper: axis analog pin

## Build and run workflow
This project is built with Pico SDK + CMake/Ninja from VS Code tasks.

Expected tasks:
- **Compile Project**: builds in `build/` with Ninja
- **Run Project**: loads ELF with `picotool`
- Optional flash/reset tasks are available through OpenOCD

Important build details in `CMakeLists.txt`:
- Sources: `joystick.cpp`, `usb_hid_descriptors.c`
- Linked libs: `pico_stdlib`, `hardware_i2c`, `hardware_adc`, `tinyusb_device`, `tinyusb_board`
- USB stdio is disabled (`pico_enable_stdio_usb(... 0)`) because USB is used for HID

## Editing guidance for Copilot
When modifying this repo:
- Preserve USB HID behavior and descriptor compatibility
- Keep axis processing order: calibration -> inversion -> deadzone -> smoothing
- Keep axis range clamped to HID signed 8-bit (`-127..127`)
- Prefer compile-time tuning macros for behavior changes
- Avoid enabling CDC/stdout over USB unless explicitly requested
- Maintain current wiring assumptions unless user asks to remap pins

## Common tuning points
In `joystick.cpp`, tune these macros first:
- `AXIS_*_MIN_RAW`, `AXIS_*_CENTER_RAW`, `AXIS_*_MAX_RAW`
- `AXIS_*_INVERT`
- `AXIS_*_DEADZONE`
- `AXIS_SMOOTHING_FACTOR`
- `JOYSTICK_REPORT_MS`

## Output expectations
Firmware should enumerate as a USB HID gamepad and continuously report:
- X axis
- Y axis
- Yaw axis (mapped to Rz)
- Button 1 (top button)
