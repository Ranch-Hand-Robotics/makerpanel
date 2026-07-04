"""Workbench registration for MakerPanel FreeCAD tools."""

from __future__ import annotations

import os

import FreeCADGui as Gui

_WORKBENCH_COMMANDS = ["MakerPanel_CreatePanel", "MakerPanel_CreateRail"]


class MakerPanelWorkbench(Gui.Workbench):
    """FreeCAD workbench exposing MakerPanel sketch tools."""

    MenuText = "MakerPanel"
    ToolTip = "Create MakerPanel-compliant panel and rail sketches."
    Icon = os.path.join(
        os.path.dirname(__file__),
        "resources",
        "icons",
        "makerpanel_panel.svg",
    )

    def Initialize(self):
        try:
            from .commands import register_commands
        except ImportError:
            from MakerPanel.commands import register_commands

        register_commands()
        self.appendToolbar("MakerPanel Tools", _WORKBENCH_COMMANDS)
        self.appendMenu("MakerPanel", _WORKBENCH_COMMANDS)

    def Activated(self):
        return None

    def Deactivated(self):
        return None

    def GetClassName(self):
        return "Gui::PythonWorkbench"
