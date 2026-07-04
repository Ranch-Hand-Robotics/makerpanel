"""command_create_panel.py — MakerPanel panel sketch command.

Opens a FreeCAD task panel whose inputs mirror the MakerPanel panel settings,
then generates a 2D sketch on the active document XY plane.
"""

from __future__ import annotations

import os

import FreeCAD
import FreeCADGui as Gui

try:
    from PySide6 import QtWidgets
except ImportError:
    from PySide2 import QtWidgets

try:
    from ..lib import const
    from ..lib.panel_generator import create_makerpanel_sketch
except ImportError:
    from MakerPanel.lib import const
    from MakerPanel.lib.panel_generator import create_makerpanel_sketch

COMMAND_NAME = "MakerPanel_CreatePanel"
_ICON_PATH = os.path.join(os.path.dirname(os.path.dirname(__file__)), "resources", "icons", "makerpanel_panel.svg")
_HEIGHT_CHOICES = [(f"{label} ({height:.3f} mm)", height) for label, height in const.PANEL_HEIGHT_PRESETS]
_SLOT_STYLE_CHOICES = (("Oblong", "oblong"), ("Circular", "circle"))
_MOUNTING_DENSITY_CHOICES = (("Full", False), ("Minimal", True))
_REGISTERED = False


class CreatePanelCommand:
    """FreeCAD command wrapper for MakerPanel panel creation."""

    def GetResources(self):
        return {
            "MenuText": "Create Panel",
            "ToolTip": "Create a MakerPanel-compliant panel outline sketch.",
            "Pixmap": _ICON_PATH,
        }

    def Activated(self):
        Gui.Control.showDialog(_PanelTaskPanel())

    def IsActive(self):
        return FreeCAD.ActiveDocument is not None


class _PanelTaskPanel:
    """Qt task panel for MakerPanel panel sketch creation."""

    def __init__(self):
        self.form = QtWidgets.QWidget()
        self.form.setWindowTitle("Create Panel")

        layout = QtWidgets.QVBoxLayout(self.form)
        form_layout = QtWidgets.QFormLayout()
        layout.addLayout(form_layout)

        self.width_hp = QtWidgets.QSpinBox()
        self.width_hp.setRange(1, 64)
        self.width_hp.setValue(8)
        form_layout.addRow("Width (HP)", self.width_hp)

        self.height_preset = QtWidgets.QComboBox()
        for label, value in _HEIGHT_CHOICES:
            self.height_preset.addItem(label, value)
        self.height_preset.addItem("Custom", None)
        self.height_preset.setCurrentIndex(next(index for index, (label, _) in enumerate(_HEIGHT_CHOICES) if label.startswith("3U")))
        form_layout.addRow("Height", self.height_preset)

        self.custom_height_row = QtWidgets.QWidget()
        custom_layout = QtWidgets.QHBoxLayout(self.custom_height_row)
        custom_layout.setContentsMargins(0, 0, 0, 0)
        self.custom_height = QtWidgets.QDoubleSpinBox()
        self.custom_height.setRange(1.0, 1000.0)
        self.custom_height.setDecimals(3)
        self.custom_height.setSuffix(" mm")
        self.custom_height.setValue(const.PANEL_3U_HEIGHT)
        custom_layout.addWidget(self.custom_height)
        form_layout.addRow("Custom Height", self.custom_height_row)

        self.add_mounting_slots = QtWidgets.QCheckBox()
        self.add_mounting_slots.setChecked(True)
        form_layout.addRow("Add mounting slots", self.add_mounting_slots)

        self.slot_style = QtWidgets.QComboBox()
        for label, value in _SLOT_STYLE_CHOICES:
            self.slot_style.addItem(label, value)
        form_layout.addRow("Slot style", self.slot_style)

        self.mounting_density = QtWidgets.QComboBox()
        for label, value in _MOUNTING_DENSITY_CHOICES:
            self.mounting_density.addItem(label, value)
        form_layout.addRow("Mounting density", self.mounting_density)

        self.summary = QtWidgets.QLabel()
        self.summary.setWordWrap(True)
        layout.addWidget(self.summary)
        layout.addStretch(1)

        self.height_preset.currentIndexChanged.connect(self._update_ui)
        self.add_mounting_slots.toggled.connect(self._update_ui)
        self.width_hp.valueChanged.connect(self._update_summary)
        self.custom_height.valueChanged.connect(self._update_summary)
        self.slot_style.currentIndexChanged.connect(self._update_summary)
        self.mounting_density.currentIndexChanged.connect(self._update_summary)

        self._update_ui()

    def getStandardButtons(self):
        return int(QtWidgets.QDialogButtonBox.Ok | QtWidgets.QDialogButtonBox.Cancel)

    def reject(self):
        Gui.Control.closeDialog()
        return True

    def accept(self):
        doc = FreeCAD.ActiveDocument
        if doc is None:
            _show_error("No active document", "Open or create a FreeCAD document first.")
            return False

        try:
            create_makerpanel_sketch(
                doc,
                width_hp=self.width_hp.value(),
                height_mm=self._selected_height_mm(),
                add_mounting_slots=self.add_mounting_slots.isChecked(),
                slot_style=self.slot_style.currentData(),
                minimal_mounting=bool(self.mounting_density.currentData()),
            )
        except Exception as exc:
            _show_error("Create Panel failed", str(exc))
            return False

        if Gui.ActiveDocument is not None:
            Gui.SendMsgToActiveView("ViewFit")
        Gui.Control.closeDialog()
        return True

    def _selected_height_mm(self):
        preset_value = self.height_preset.currentData()
        return self.custom_height.value() if preset_value is None else float(preset_value)

    def _update_ui(self):
        use_custom = self.height_preset.currentData() is None
        self.custom_height_row.setVisible(use_custom)

        mounting_enabled = self.add_mounting_slots.isChecked()
        self.slot_style.setEnabled(mounting_enabled)
        self.mounting_density.setEnabled(mounting_enabled)
        self._update_summary()

    def _update_summary(self):
        width_mm = self.width_hp.value() * const.HP_UNIT
        self.summary.setText(
            f"Panel size: {width_mm:.2f} mm × {self._selected_height_mm():.3f} mm"
        )


def register_command():
    """Register the Create Panel command with FreeCADGui."""
    global _REGISTERED
    if _REGISTERED:
        return

    Gui.addCommand(COMMAND_NAME, CreatePanelCommand())
    _REGISTERED = True


def _show_error(title, message):
    QtWidgets.QMessageBox.critical(Gui.getMainWindow(), title, message)
    FreeCAD.Console.PrintError(f"{title}: {message}\n")
