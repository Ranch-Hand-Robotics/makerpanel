"""
Simple test driver for LilyGo T-Encoder-Pro without DaVinci Resolve.

Connects to the device via USB CDC, receives encoder/button input, and sends mock state.
Useful for verifying encoder tuning, button debouncing, and USB protocol before integrating with Resolve.

Usage:
    python test_driver.py --port COM7
    python test_driver.py  # auto-detect Espressif device
"""

import argparse
import json
import time
import sys

import serial
from serial.tools import list_ports

# Import protocol helpers from the davinci plugin
sys.path.insert(0, "plugins/davinci")
import protocol

ESPRESSIF_VID = 0x303A


def find_port(explicit: str | None) -> str:
    if explicit:
        return explicit
    for p in list_ports.comports():
        if p.vid == ESPRESSIF_VID:
            return p.device
    raise SystemExit("No T-Encoder Pro found. Pass --port COMx.")


def main():
    ap = argparse.ArgumentParser(description="Test driver for T-Encoder-Pro")
    ap.add_argument("--port", default=None, help="Serial port (e.g., COM7)")
    ap.add_argument("--baud", type=int, default=115200)
    args = ap.parse_args()

    port = find_port(args.port)
    ser = serial.Serial(port, args.baud, timeout=0.1)
    print(f"Connected to {port} at {args.baud} baud")
    print("Press Ctrl+C to exit\n")

    # Mock state: update this manually to send to device
    mock_state = {
        "tc": "01:00:00:00",
        "fps": 24,
        "play": False,
        "tl": "Test",
        "mode": "frame",
    }

    last_send = time.monotonic()
    frame_count = 0

    try:
        while True:
            # Read incoming messages
            line = ser.readline().decode("utf-8", "replace")
            m = protocol.Message.parse(line)

            if m:
                print(f"[RX] {m.type:8} {json.dumps(m.data)}")

                if m.type == "hello":
                    print("     → Device connected")
                    ser.write(protocol.msg("test driver connected"))

                elif m.type == "enc":
                    detents = int(m.data.get("d", 0))
                    print(
                        f"     → Encoder: {detents:+d} detent(s) "
                        f"({abs(detents) * 5}ms since last report)"
                    )

                elif m.type == "btn":
                    action = m.data.get("a")
                    sounds = {
                        "down": "◀ pressed",
                        "up": "  released",
                        "click": "⊙ click",
                        "long": "⊙⊙ long press",
                    }
                    print(f"     → Button: {sounds.get(action, action)}")

                elif m.type == "pong":
                    print("     → Pong")

            # Send mock state every ~100ms (10 Hz)
            now = time.monotonic()
            if now - last_send >= 0.1:
                ser.write(
                    protocol.state_msg(
                        mock_state["tc"],
                        mock_state["fps"],
                        mock_state["play"],
                        mock_state["tl"],
                        mock_state["mode"],
                    )
                )
                frame_count += 1
                if frame_count % 10 == 0:
                    print(f"[TX] state frame {frame_count}")
                last_send = now

    except KeyboardInterrupt:
        print("\nExiting...")
        ser.close()


if __name__ == "__main__":
    main()
