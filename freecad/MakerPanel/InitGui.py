"""FreeCAD GUI entry point for the MakerPanel workbench."""

from __future__ import annotations

import FreeCADGui as Gui

try:
    from .MakerPanelWorkbench import MakerPanelWorkbench
except ImportError:
    from MakerPanel.MakerPanelWorkbench import MakerPanelWorkbench

Gui.addWorkbench(MakerPanelWorkbench())
