"""Playback control via keystrokes; the scripting API cannot start playback."""
from __future__ import annotations

try:
    import keyboard  # type: ignore
except ImportError:
    keyboard = None


class Transport:
    def __init__(self) -> None:
        self.playing = False

    def toggle_play(self) -> bool:
        if keyboard is not None:
            keyboard.send("space")
            self.playing = not self.playing
        return self.playing
