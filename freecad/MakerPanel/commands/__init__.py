"""Command registration for the MakerPanel FreeCAD workbench."""

from __future__ import annotations

from .command_create_panel import COMMAND_NAME as COMMAND_CREATE_PANEL
from .command_create_panel import register_command as register_create_panel_command
from .command_create_rail import COMMAND_NAME as COMMAND_CREATE_RAIL
from .command_create_rail import register_command as register_create_rail_command

__all__ = [
    "COMMAND_CREATE_PANEL",
    "COMMAND_CREATE_RAIL",
    "register_commands",
]

_REGISTERED = False


def register_commands():
    """Register all MakerPanel workbench commands with FreeCADGui."""

    global _REGISTERED
    if _REGISTERED:
        return

    register_create_panel_command()
    register_create_rail_command()
    _REGISTERED = True
