"""Wire protocol v1 helpers (newline-delimited JSON over USB CDC)."""
from __future__ import annotations

import json
from dataclasses import dataclass

PROTO_VERSION = 1
MODES = ("frame", "sec", "shuttle", "clip")


@dataclass
class Message:
    type: str
    data: dict

    @staticmethod
    def parse(line: str) -> "Message | None":
        line = line.strip()
        if not line:
            return None
        try:
            obj = json.loads(line)
        except json.JSONDecodeError:
            return None
        if not isinstance(obj, dict) or "t" not in obj:
            return None
        return Message(obj["t"], obj)


def encode(**fields) -> bytes:
    return (json.dumps(fields, separators=(",", ":")) + "\n").encode("utf-8")


def state_msg(tc: str, fps: int, playing: bool, timeline: str, mode: str) -> bytes:
    return encode(t="state", tc=tc, fps=fps, play=playing, tl=timeline[:31], mode=mode)


def msg(text: str) -> bytes:
    return encode(t="msg", s=text[:31])
