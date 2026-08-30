# T-Encoder-Pro → DaVinci Resolve dial

Turns a LilyGo T-Encoder-Pro into a jog/shuttle dial for the DaVinci Resolve
timeline, with the puck's AMOLED showing the current timecode.

```
T-Encoder-Pro (ESP32-S3)  ──USB CDC, JSON lines──▶  resolve_bridge.py  ──▶  Resolve
   encoder + button                                  (host, Python)      scripting API
   390x390 SH8601A AMOLED  ◀──── state pushes ─────
```

The host is the source of truth for timecode; the device only reports input
deltas and renders whatever state it was last handed. This avoids drift.

| Path | Contents |
|------|----------|
| `firmware/` | PlatformIO project for the ESP32-S3 |
| `plugins/davinci/` | Python bridge driving the Resolve scripting API |

## Protocol v1

Newline-delimited JSON over USB CDC. See `plugins/davinci/protocol.py` and
`firmware/include/protocol.h`.

**Device → host:** `hello`, `enc` (detent delta), `btn` (`down`/`up`/`click`/`long`), `pong`

**Host → device:** `state` (timecode/fps/playing/timeline/mode), `msg`, `setmode`, `ping`

If the device sees no host traffic for 2 s it displays `OFFLINE`.

## Controls

Short press toggles play/pause. Long press cycles the mode:
`frame` → `sec` → `shuttle` → `clip`.

## Pinmap

| Function | Pin |
|---|---|
| Encoder A / B | IO1 / IO2 |
| Encoder button | IO0 (also BOOT) |
| Buzzer | IO17 |
| LCD CS / RST / SCLK / VCI_EN | IO10 / IO4 / IO12 / IO3 |
| LCD SDIO0..3 | IO11 / IO13 / IO7 / IO14 |
| Touch SDA / SCL / RST / INT | IO5 / IO6 / IO8 / IO9 |
| Qwiic SDA / SCL | IO16 / IO15 |

## Build

```powershell
Set-Location firmware
& "$env:USERPROFILE\.platformio\penv\Scripts\pio.exe" run --target upload
```

Hold the encoder button while tapping RESET to enter the ROM bootloader
(the button is on IO0/BOOT). The firmware ignores a press that is already held
at startup so this does not register as a click.

## Tuning

Watch raw `enc` messages in the serial monitor and adjust `COUNTS_PER_DETENT`
in `firmware/src/encoder.cpp` until one physical click yields exactly `"d":±1`.
