# Pico SDK Detail Map

Use this map to answer "where do I find details?" quickly.

## In This Workspace

- SDK root (generated in build tree):
  - `build/pico-sdk/`
- Core source mirror:
  - `build/pico-sdk/src/`
- Common module families:
  - `build/pico-sdk/src/common/`
  - `build/pico-sdk/src/rp2_common/`
  - `build/pico-sdk/src/rp2040/` (when present)
  - `build/pico-sdk/src/rp2350/`
- Build glue in project:
  - `pico_sdk_import.cmake`
  - `CMakeLists.txt`

## Typical "Where Is X?" Paths

- Standard runtime / convenience APIs:
  - `src/rp2_common/pico_stdlib/`
  - `src/common/pico_time/`, `src/common/pico_util/`, `src/common/pico_sync/`
- Peripherals (`hardware_*`):
  - `src/rp2_common/hardware_gpio/`
  - `src/rp2_common/hardware_adc/`
  - `src/rp2_common/hardware_pwm/`
  - `src/rp2_common/hardware_uart/`
  - `src/rp2_common/hardware_spi/`
  - `src/rp2_common/hardware_i2c/`
  - `src/rp2_common/hardware_pio/`
  - `src/rp2_common/hardware_dma/`
  - `src/rp2_common/hardware_irq/`
  - `src/rp2_common/hardware_timer/`
- Boot / flash / reset related:
  - `src/rp2_common/pico_bootrom/`
  - `src/rp2_common/hardware_flash/`
  - `src/rp2_common/hardware_watchdog/`

## Upstream Documentation

- Pico C/C++ SDK docs (latest):
  - https://www.raspberrypi.com/documentation/pico-sdk/
- Pico examples repository (API usage patterns):
  - https://github.com/raspberrypi/pico-examples
- Pico SDK repository (source of truth):
  - https://github.com/raspberrypi/pico-sdk

## Practical Navigation Heuristics

1. Start from the header for the API the user mentioned.
2. Jump to the module directory and find corresponding `*.c` implementation.
3. Check module `CMakeLists.txt` for compile-time options and dependencies.
4. Cross-check with examples for intended usage sequence.
5. Confirm chip-family specifics (`rp2040` vs `rp2350`) before giving final guidance.
