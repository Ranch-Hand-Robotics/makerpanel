"""command_create_rail.py — MakerRail sketch command.

Opens a FreeCAD task panel for configuring a MakerRail, then generates a 2D
sketch on the active document XY plane.
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
    from ..lib.rail_generator import create_makerrail_sketch
except ImportError:
    from MakerPanel.lib import const
    from MakerPanel.lib.rail_generator import create_makerrail_sketch

COMMAND_NAME = "MakerPanel_CreateRail"
_ICON_PATH = os.path.join(os.path.dirname(os.path.dirname(__file__)), "resources", "icons", "makerpanel_rail.svg")
_HOLE_CHOICES = (
    ("M3", const.RAIL_HOLE_DIAMETER_M3),
    ("M4", const.RAIL_HOLE_DIAMETER_M4),
    ("M5", const.RAIL_HOLE_DIAMETER_M5),
    ("M6", const.RAIL_HOLE_DIAMETER_M6),
)
_REGISTERED = False


class CreateRailCommand:
    """FreeCAD command wrapper for MakerRail creation."""

    def GetResources(self):
        return {
            "MenuText": "Create Rail",
            "ToolTip": "Create a MakerPanel-compliant MakerRail sketch.",
            "Pixmap": _ICON_PATH,
        }

    def Activated(self):
        Gui.Control.showDialog(_RailTaskPanel())

    def IsActive(self):
        return FreeCAD.ActiveDocument is not None


class _RailTaskPanel:
    """Qt task panel for MakerRail sketch creation."""

    def __init__(self):
        self.form = QtWidgets.QWidget()
        self.form.setWindowTitle("Create Rail")

        layout = QtWidgets.QVBoxLayout(self.form)
        form_layout = QtWidgets.QFormLayout()
        layout.addLayout(form_layout)

        self.width_hp = QtWidgets.QSpinBox()
        self.width_hp.setRange(1, 400)
        self.width_hp.setValue(20)
        form_layout.addRow("Width (HP)", self.width_hp)

        self.rail_height = QtWidgets.QDoubleSpinBox()
        self.rail_height.setRange(const.RAIL_SLOT_HEIGHT + 0.1, 1000.0)
        self.rail_height.setDecimals(3)
        self.rail_height.setSuffix(" mm")
        self.rail_height.setValue(const.RAIL_DEFAULT_HEIGHT)
        form_layout.addRow("Rail height", self.rail_height)

        self.use_custom_length = QtWidgets.QCheckBox()
        self.use_custom_length.setChecked(False)
        form_layout.addRow("Override length", self.use_custom_length)

        self.custom_length = QtWidgets.QDoubleSpinBox()
        self.custom_length.setRange(1.0, 5000.0)
        self.custom_length.setDecimals(3)
        self.custom_length.setSuffix(" mm")
        self.custom_length.setValue(self.width_hp.value() * const.HP_UNIT)
        form_layout.addRow("Custom length", self.custom_length)

        self.add_end_holes = QtWidgets.QCheckBox()
        self.add_end_holes.setChecked(True)
        form_layout.addRow("Add end holes", self.add_end_holes)

        self.hole_size = QtWidgets.QComboBox()
        for label, value in _HOLE_CHOICES:
            self.hole_size.addItem(label, value)
        form_layout.addRow("Hole size", self.hole_size)

        self.rotate_90 = QtWidgets.QCheckBox()
        self.rotate_90.setChecked(False)
        form_layout.addRow("Rotate 90°", self.rotate_90)

        self.summary = QtWidgets.QLabel()
        self.summary.setWordWrap(True)
        layout.addWidget(self.summary)
        layout.addStretch(1)

        self.use_custom_length.toggled.connect(self._update_ui)
        self.add_end_holes.toggled.connect(self._update_ui)
        self.width_hp.valueChanged.connect(self._width_changed)
        self.rail_height.valueChanged.connect(self._update_summary)
        self.custom_length.valueChanged.connect(self._update_summary)
        self.rotate_90.toggled.connect(self._update_summary)
        self.hole_size.currentIndexChanged.connect(self._update_summary)

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
            create_makerrail_sketch(
                doc,
                width_hp=self.width_hp.value(),
                rail_height_mm=self.rail_height.value(),
                custom_length_mm=self._selected_length_mm(),
                add_end_holes=self.add_end_holes.isChecked(),
                hole_diameter_mm=float(self.hole_size.currentData()),
                rotate90=self.rotate_90.isChecked(),
            )
        except Exception as exc:
            _show_error("Create Rail failed", str(exc))
            return False

        if Gui.ActiveDocument is not None:
            Gui.SendMsgToActiveView("ViewFit")
        Gui.Control.closeDialog()
        return True

    def _selected_length_mm(self):
        return self.custom_length.value() if self.use_custom_length.isChecked() else None

    def _width_changed(self):
        if not self.use_custom_length.isChecked():
            self.custom_length.setValue(self.width_hp.value() * const.HP_UNIT)
        self._update_summary()

    def _update_ui(self):
        custom_enabled = self.use_custom_length.isChecked()
        self.custom_length.setEnabled(custom_enabled)
        self.hole_size.setEnabled(self.add_end_holes.isChecked())
        self._update_summary()

    def _update_summary(self):
        length_mm = self.custom_length.value() if self.use_custom_length.isChecked() else self.width_hp.value() * const.HP_UNIT
        end_margin = self.rail_height.value() if self.add_end_holes.isChecked() else const.RAIL_SUPPORT_WIDTH
        available = length_mm - (2.0 * end_margin)
        min_pitch = const.RAIL_SLOT_MIN_WIDTH + const.RAIL_SUPPORT_WIDTH
        slot_count = max(0, int((available + const.RAIL_SUPPORT_WIDTH) / min_pitch))
        if slot_count == 0 and available > 0:
            slot_count = 1
        self.summary.setText(
            f"Rail size: {length_mm:.2f} mm × {self.rail_height.value():.3f} mm | Slots: {slot_count}"
        )


def register_command():
    """Register the Create Rail command with FreeCADGui."""
    global _REGISTERED
    if _REGISTERED:
        return

    Gui.addCommand(COMMAND_NAME, CreateRailCommand())
    _REGISTERED = True


def _show_error(title, message):
    QtWidgets.QMessageBox.critical(Gui.getMainWindow(), title, message)
    FreeCAD.Console.PrintError(f"{title}: {message}\n")
