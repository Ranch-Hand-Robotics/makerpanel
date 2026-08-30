# Resolve bridge

DaVinci Resolve has no plugin API for transport or panel control — the
protocols used by the Speed Editor and similar surfaces are closed. The
supported extension point is the **DaVinci Resolve Scripting API**, so this
"plugin" is a host-side Python process.

## What the scripting API can and cannot do

| Can | Cannot |
|-----|--------|
| Read/set the playhead (`Get`/`SetCurrentTimecode`) | Start or stop playback |
| Read timeline name and frame rate | Scrub smoothly at high rates |
| Enumerate timeline items | Bind to a hardware panel natively |

Play/pause therefore falls back to sending a `space` keystroke to the focused
Resolve window (`transport.py`). Swap that module out for a different
mechanism if you prefer.

## Setup

Enable scripting in Resolve: **Preferences ▸ System ▸ General ▸
External scripting using = Local**.

```powershell
python -m venv .venv
.\.venv\Scripts\Activate.ps1
pip install -r requirements.txt
python resolve_bridge.py --port COM7
```

Omit `--port` to auto-detect by Espressif USB VID (`0x303A`).

## Tuning

`config.json` holds `fps_hint` and `shuttle_step_frames`. Playhead writes are
rate-limited to `PUSH_HZ` (20 Hz) in `resolve_bridge.py`; encoder detents
accumulate between pushes.

## Running from inside Resolve

Copy or symlink this folder into Resolve's `Scripts\Utility` directory to get
it in the **Workspace ▸ Scripts** menu. In that context `connect()` finds the
already-running app rather than attaching over the local socket.
