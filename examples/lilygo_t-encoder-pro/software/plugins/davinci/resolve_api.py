"""Thin wrapper over the DaVinci Resolve scripting API."""
from __future__ import annotations

import os
import sys

_WIN_MODULES = (
    r"C:\ProgramData\Blackmagic Design\DaVinci Resolve"
    r"\Support\Developer\Scripting\Modules"
)


def _bootstrap_path() -> None:
    api = os.environ.get("RESOLVE_SCRIPT_API")
    candidates = [os.path.join(api, "Modules")] if api else []
    candidates.append(_WIN_MODULES)
    for c in candidates:
        if c and os.path.isdir(c) and c not in sys.path:
            sys.path.append(c)


def connect():
    _bootstrap_path()
    import DaVinciResolveScript as dvr  # type: ignore

    return dvr.scriptapp("Resolve")


def _tc_to_frames(tc: str, fps: int) -> int:
    h, m, s, f = (int(p) for p in tc.replace(";", ":").split(":"))
    return ((h * 60 + m) * 60 + s) * fps + f


def _tc_add(tc: str, frames: int, fps: int) -> str:
    total = max(_tc_to_frames(tc, fps) + frames, 0)
    f = total % fps
    total //= fps
    return f"{total // 3600:02d}:{(total // 60) % 60:02d}:{total % 60:02d}:{f:02d}"


class ResolveTimeline:
    """Timecode read/write against whatever timeline is currently open."""

    def __init__(self, resolve):
        self.resolve = resolve

    def _timeline(self):
        pm = self.resolve.GetProjectManager()
        proj = pm.GetCurrentProject() if pm else None
        return proj.GetCurrentTimeline() if proj else None

    @staticmethod
    def _fps(tl) -> int:
        return int(float(tl.GetSetting("timelineFrameRate") or 24))

    def snapshot(self) -> dict | None:
        tl = self._timeline()
        if tl is None:
            return None
        return {
            "tc": tl.GetCurrentTimecode(),
            "fps": self._fps(tl),
            "name": tl.GetName(),
        }

    def nudge_frames(self, frames: int) -> str | None:
        """Move the playhead by N frames. Returns the new timecode."""
        tl = self._timeline()
        if tl is None or frames == 0:
            return None
        new = _tc_add(tl.GetCurrentTimecode(), frames, self._fps(tl))
        tl.SetCurrentTimecode(new)
        return new
