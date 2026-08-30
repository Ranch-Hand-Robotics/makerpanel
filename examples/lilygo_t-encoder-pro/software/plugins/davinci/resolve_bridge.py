"""
MakerPanel T-Encoder Pro -> DaVinci Resolve bridge.

    python resolve_bridge.py --port COM7

Drop this folder into Resolve's Scripts/Utility directory to launch it from
Workspace > Scripts instead.
"""
from __future__ import annotations

import argparse
import itertools
import json
import os
import time

import serial
from serial.tools import list_ports

import protocol
from protocol import MODES
from resolve_api import ResolveTimeline, connect
from transport import Transport

PUSH_HZ = 20
ESPRESSIF_VID = 0x303A


def find_port(explicit: str | None) -> str:
    if explicit:
        return explicit
    for p in list_ports.comports():
        if p.vid == ESPRESSIF_VID:
            return p.device
    raise SystemExit("No T-Encoder Pro found. Pass --port COMx.")


def load_config() -> dict:
    path = os.path.join(os.path.dirname(__file__), "config.json")
    if os.path.exists(path):
        with open(path, "r", encoding="utf-8") as fh:
            return json.load(fh)
    return {}


def frames_for(mode: str, detents: int, fps: int, cfg: dict) -> int:
    if mode == "sec":
        return detents * fps
    if mode == "shuttle":
        return detents * int(cfg.get("shuttle_step_frames", 8))
    if mode == "clip":
        return detents * fps * 2
    return detents


def main() -> None:
    ap = argparse.ArgumentParser()
    ap.add_argument("--port", default=None)
    args = ap.parse_args()

    cfg = load_config()
    mode_cycle = itertools.cycle(MODES)
    mode = next(mode_cycle)

    resolve = connect()
    if resolve is None:
        raise SystemExit("Could not attach to DaVinci Resolve. Is it running?")
    timeline = ResolveTimeline(resolve)
    transport = Transport()

    port = find_port(args.port)
    ser = serial.Serial(port, 115200, timeout=0.02)
    print(f"Bridge running on {port}")

    pending_frames = 0
    last_push = 0.0
    fps = int(cfg.get("fps_hint", 24))

    while True:
        m = protocol.Message.parse(ser.readline().decode("utf-8", "replace"))

        if m and m.type == "enc":
            pending_frames += frames_for(mode, int(m.data.get("d", 0)), fps, cfg)
        elif m and m.type == "btn":
            action = m.data.get("a")
            if action == "click":
                transport.toggle_play()
            elif action == "long":
                mode = next(mode_cycle)
        elif m and m.type == "hello":
            ser.write(protocol.msg("connected"))

        now = time.monotonic()
        if now - last_push < 1.0 / PUSH_HZ:
            continue
        last_push = now

        if pending_frames:
            timeline.nudge_frames(pending_frames)
            pending_frames = 0

        snap = timeline.snapshot()
        if snap:
            fps = snap["fps"]
            ser.write(
                protocol.state_msg(
                    snap["tc"], fps, transport.playing, snap["name"], mode
                )
            )
        else:
            ser.write(protocol.msg("no timeline"))


if __name__ == "__main__":
    main()
