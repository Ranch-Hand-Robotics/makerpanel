"""
commandCreatePanel/entry.py — MakerPanel panel sketch command.

Registers the 'MakerPanel Panel' button in the Fusion 360 Create toolbar
panel (FusionSolidEnvironment → SolidCreatePanel).  When clicked it opens
a dialog whose inputs mirror the MakerPanel specification dimensions, then
generates a 2D sketch on the active component's XY plane.

Dialog layout:
  Info              — quick reference for HP / U dimensions
  Panel Dimensions  — width (HP integer), height preset + custom value
  Mounting          — add slots toggle + oblong vs circular style
  Settings          — save / reset / factory-reset defaults
  Preview           — live-preview toggle
"""

import adsk.core
import adsk.fusion
import traceback
import os

from ... import config
from ...lib import configUtils
from ...lib import fusion360utils as futil
from ...lib.ui.commandUiState import CommandUiState
from ...lib.makerpanelUtils import const
from ...lib.makerpanelUtils.panelGenerator import createMakerPanelSketch

# ---------------------------------------------------------------------------
# Command identity — shown in toolbar and dialog title bar
# ---------------------------------------------------------------------------
CMD_ID          = f'{config.COMPANY_NAME}_{config.ADDIN_NAME}_cmdPanel'
CMD_NAME        = 'MakerPanel Panel'
CMD_Description = 'Create a MakerPanel-compliant panel outline as a 2D sketch'

# Toolbar placement — same panel as Gridfinity uses
WORKSPACE_ID       = 'FusionSolidEnvironment'
PANEL_ID           = 'SketchPanel'
COMMAND_BESIDE_ID  = 'SketchCreate'

ICON_FOLDER        = ''
CONFIG_FOLDER_PATH = os.path.join(os.path.dirname(os.path.abspath(__file__)), 'commandConfig')
UI_DEFAULTS_PATH   = os.path.join(CONFIG_FOLDER_PATH, 'ui_input_defaults.json')

# ---------------------------------------------------------------------------
# Input / group IDs
# ---------------------------------------------------------------------------
INFO_GROUP          = 'info_group'
DIMENSIONS_GROUP    = 'dimensions_group'
MOUNTING_GROUP      = 'mounting_group'
INPUT_CHANGES_GROUP = 'input_changes_group'
PREVIEW_GROUP       = 'preview_group'

PANEL_WIDTH_HP_INPUT          = 'panel_width_hp'
PANEL_HEIGHT_PRESET_INPUT     = 'panel_height_preset'
PANEL_HEIGHT_CUSTOM_INPUT     = 'panel_height_custom'
PANEL_ADD_MOUNTING_SLOTS_INPUT = 'panel_add_mounting_slots'
PANEL_SLOT_STYLE_INPUT        = 'panel_slot_style'
PANEL_ACTUAL_DIMS_INPUT       = 'panel_actual_dims'   # read-only text
SHOW_PREVIEW_INPUT            = 'show_preview'

INPUT_CHANGES_SAVE_DEFAULTS   = 'input_changes_save'
INPUT_CHANGES_RESET_TO_DEFAULTS = 'input_changes_reset'
INPUT_CHANGES_RESET_TO_FACTORY  = 'input_changes_factory'

# Height preset option strings
HEIGHT_PRESET_1U     = '1U (44.45 mm)'
HEIGHT_PRESET_3U     = '3U Panel (128.5 mm)'
HEIGHT_PRESET_CUSTOM = 'Custom'

# Slot style option strings
SLOT_STYLE_OBLONG = 'Oblong (adjustment slots)'
SLOT_STYLE_CIRCLE = 'Circular (fixed holes)'

# ---------------------------------------------------------------------------
# Module-level state (survives between dialog opens)
# ---------------------------------------------------------------------------
uiState       = CommandUiState(CMD_NAME)
local_handlers: list = []
INPUTS_VALID  = True

app = adsk.core.Application.get()
ui  = app.userInterface


# ---------------------------------------------------------------------------
# Lifecycle
# ---------------------------------------------------------------------------

def start():
    futil.log(f'{CMD_NAME} start')
    try:
        addinConfig = configUtils.readConfig(CONFIG_FOLDER_PATH)
        cmd_def = ui.commandDefinitions.itemById(CMD_ID)
        if not cmd_def:
            cmd_def = ui.commandDefinitions.addButtonDefinition(
                CMD_ID, CMD_NAME, CMD_Description, ICON_FOLDER)
            futil.add_handler(cmd_def.commandCreated, command_created)
            workspace = ui.workspaces.itemById(WORKSPACE_ID)
            panel     = workspace.toolbarPanels.itemById(PANEL_ID)
            control   = panel.controls.addCommand(cmd_def, COMMAND_BESIDE_ID, False)
            control.isPromoted = addinConfig['UI'].getboolean('is_promoted')
        initUiState()
    except Exception as err:
        futil.log(f'{CMD_NAME} start error: {err}')


def stop():
    futil.log(f'{CMD_NAME} stop')
    workspace = ui.workspaces.itemById(WORKSPACE_ID)
    panel     = workspace.toolbarPanels.itemById(PANEL_ID)
    command_control    = panel.controls.itemById(CMD_ID)
    command_definition = ui.commandDefinitions.itemById(CMD_ID)
    addinConfig = configUtils.readConfig(CONFIG_FOLDER_PATH)
    addinConfig['UI']['is_promoted'] = (
        'yes' if command_control and command_control.isPromoted else 'no')
    configUtils.writeConfig(addinConfig, CONFIG_FOLDER_PATH)
    if command_control:
        command_control.deleteMe()
    if command_definition:
        command_definition.deleteMe()


# ---------------------------------------------------------------------------
# UI state management
# ---------------------------------------------------------------------------

def initUiState():
    global uiState
    # Groups
    uiState.initValue(INFO_GROUP,          True, adsk.core.GroupCommandInput.classType())
    uiState.initValue(DIMENSIONS_GROUP,    True, adsk.core.GroupCommandInput.classType())
    uiState.initValue(MOUNTING_GROUP,      True, adsk.core.GroupCommandInput.classType())
    uiState.initValue(INPUT_CHANGES_GROUP, True, adsk.core.GroupCommandInput.classType())
    uiState.initValue(PREVIEW_GROUP,       True, adsk.core.GroupCommandInput.classType())
    # Inputs
    uiState.initValue(PANEL_WIDTH_HP_INPUT,          8,                        adsk.core.IntegerSpinnerCommandInput.classType())
    uiState.initValue(PANEL_HEIGHT_PRESET_INPUT,     HEIGHT_PRESET_3U,         adsk.core.DropDownCommandInput.classType())
    uiState.initValue(PANEL_HEIGHT_CUSTOM_INPUT,     const.PANEL_3U_HEIGHT,    adsk.core.ValueCommandInput.classType())
    uiState.initValue(PANEL_ADD_MOUNTING_SLOTS_INPUT, True,                    adsk.core.BoolValueCommandInput.classType())
    uiState.initValue(PANEL_SLOT_STYLE_INPUT,         SLOT_STYLE_OBLONG,       adsk.core.DropDownCommandInput.classType())
    uiState.initValue(SHOW_PREVIEW_INPUT,             True,                    adsk.core.BoolValueCommandInput.classType())

    # Restore previously saved defaults if available
    saved = configUtils.readJsonConfig(UI_DEFAULTS_PATH)
    if saved:
        try:
            uiState.initValues(saved)
        except Exception as err:
            futil.log(f'{CMD_NAME} could not restore saved defaults: {err}')


# ---------------------------------------------------------------------------
# Command-created: build the dialog
# ---------------------------------------------------------------------------

def command_created(args: adsk.core.CommandCreatedEventArgs):
    futil.log(f'{CMD_NAME} command_created')
    global uiState

    args.command.setDialogInitialSize(360, 480)
    inputs = args.command.commandInputs
    defaultLengthUnits = app.activeProduct.unitsManager.defaultLengthUnits

    # --- Info group ---
    infoGroup = inputs.addGroupCommandInput(INFO_GROUP, 'Info')
    infoGroup.isExpanded = uiState.getState(INFO_GROUP)
    uiState.registerCommandInput(infoGroup)
    infoGroup.children.addTextBoxCommandInput(
        'info_text', '',
        '<b>MakerPanel</b>: 1 HP = 5.08 mm &nbsp;|&nbsp; '
        '1U = 44.45 mm &nbsp;|&nbsp; 3U Panel = 128.5 mm',
        2, True)

    # --- Dimensions group ---
    dimsGroup = inputs.addGroupCommandInput(DIMENSIONS_GROUP, 'Panel Dimensions')
    dimsGroup.isExpanded = uiState.getState(DIMENSIONS_GROUP)
    uiState.registerCommandInput(dimsGroup)

    widthInput = dimsGroup.children.addIntegerSpinnerCommandInput(
        PANEL_WIDTH_HP_INPUT, 'Width (HP)', 1, 64, 1,
        uiState.getState(PANEL_WIDTH_HP_INPUT))
    uiState.registerCommandInput(widthInput)

    heightPreset = dimsGroup.children.addDropDownCommandInput(
        PANEL_HEIGHT_PRESET_INPUT, 'Height',
        adsk.core.DropDownStyles.TextListDropDownStyle)
    current_preset = uiState.getState(PANEL_HEIGHT_PRESET_INPUT)
    heightPreset.listItems.add(HEIGHT_PRESET_1U,     current_preset == HEIGHT_PRESET_1U)
    heightPreset.listItems.add(HEIGHT_PRESET_3U,     current_preset == HEIGHT_PRESET_3U)
    heightPreset.listItems.add(HEIGHT_PRESET_CUSTOM, current_preset == HEIGHT_PRESET_CUSTOM)
    uiState.registerCommandInput(heightPreset)

    customHeight = dimsGroup.children.addValueInput(
        PANEL_HEIGHT_CUSTOM_INPUT, 'Custom Height',
        defaultLengthUnits,
        adsk.core.ValueInput.createByReal(uiState.getState(PANEL_HEIGHT_CUSTOM_INPUT)))
    customHeight.minimumValue    = 0.1
    customHeight.isMinimumInclusive = True
    customHeight.isVisible = (current_preset == HEIGHT_PRESET_CUSTOM)
    uiState.registerCommandInput(customHeight)

    # Read-only actual dimensions (not persisted in uiState)
    dimsGroup.children.addTextBoxCommandInput(
        PANEL_ACTUAL_DIMS_INPUT, '',
        _dims_text(uiState.getState(PANEL_WIDTH_HP_INPUT),
                   current_preset,
                   uiState.getState(PANEL_HEIGHT_CUSTOM_INPUT)),
        2, True)

    # --- Mounting group ---
    mountGroup = inputs.addGroupCommandInput(MOUNTING_GROUP, 'Mounting')
    mountGroup.isExpanded = uiState.getState(MOUNTING_GROUP)
    uiState.registerCommandInput(mountGroup)

    addSlotsInput = mountGroup.children.addBoolValueInput(
        PANEL_ADD_MOUNTING_SLOTS_INPUT, 'Add Mounting Slots', True, '',
        uiState.getState(PANEL_ADD_MOUNTING_SLOTS_INPUT))
    uiState.registerCommandInput(addSlotsInput)

    slotStyleInput = mountGroup.children.addDropDownCommandInput(
        PANEL_SLOT_STYLE_INPUT, 'Slot Style',
        adsk.core.DropDownStyles.TextListDropDownStyle)
    current_style = uiState.getState(PANEL_SLOT_STYLE_INPUT)
    slotStyleInput.listItems.add(SLOT_STYLE_OBLONG, current_style == SLOT_STYLE_OBLONG)
    slotStyleInput.listItems.add(SLOT_STYLE_CIRCLE, current_style == SLOT_STYLE_CIRCLE)
    slotStyleInput.isEnabled = uiState.getState(PANEL_ADD_MOUNTING_SLOTS_INPUT)
    uiState.registerCommandInput(slotStyleInput)

    # --- Save / reset buttons ---
    changesGroup = inputs.addGroupCommandInput(INPUT_CHANGES_GROUP, 'Settings')
    changesGroup.isExpanded = uiState.getState(INPUT_CHANGES_GROUP)
    uiState.registerCommandInput(changesGroup)
    save_btn = changesGroup.children.addBoolValueInput(
        INPUT_CHANGES_SAVE_DEFAULTS, 'Save as new defaults', False, '', False)
    save_btn.text = 'Save'
    reset_btn = changesGroup.children.addBoolValueInput(
        INPUT_CHANGES_RESET_TO_DEFAULTS, 'Reset to defaults', False, '', False)
    reset_btn.text = 'Reset'
    factory_btn = changesGroup.children.addBoolValueInput(
        INPUT_CHANGES_RESET_TO_FACTORY, 'Wipe saved settings', False, '', False)
    factory_btn.text = 'Factory Reset'

    # --- Preview ---
    previewGroup = inputs.addGroupCommandInput(PREVIEW_GROUP, 'Preview')
    previewGroup.isExpanded = uiState.getState(PREVIEW_GROUP)
    uiState.registerCommandInput(previewGroup)
    showPreview = previewGroup.children.addBoolValueInput(
        SHOW_PREVIEW_INPUT, 'Show live preview', True, '',
        uiState.getState(SHOW_PREVIEW_INPUT))
    showPreview.tooltip = 'Requires parametric (timeline) design mode.'
    uiState.registerCommandInput(showPreview)

    # Wire events
    futil.add_handler(args.command.execute,       command_execute,        local_handlers=local_handlers)
    futil.add_handler(args.command.inputChanged,  command_input_changed,  local_handlers=local_handlers)
    futil.add_handler(args.command.executePreview, command_preview,       local_handlers=local_handlers)
    futil.add_handler(args.command.validateInputs, command_validate,      local_handlers=local_handlers)
    futil.add_handler(args.command.destroy,        command_destroy,       local_handlers=local_handlers)


# ---------------------------------------------------------------------------
# Event handlers
# ---------------------------------------------------------------------------

def command_execute(args: adsk.core.CommandEventArgs):
    futil.log(f'{CMD_NAME} execute')
    _generate_panel(args)


def command_preview(args: adsk.core.CommandEventArgs):
    futil.log(f'{CMD_NAME} preview')
    inputs     = args.command.commandInputs
    show_input = inputs.itemById(SHOW_PREVIEW_INPUT)
    if show_input and show_input.value and INPUTS_VALID:
        _generate_panel(args)


def command_input_changed(args: adsk.core.InputChangedEventArgs):
    changed = args.input
    global uiState

    # Button actions (not real value inputs)
    if changed.id == INPUT_CHANGES_SAVE_DEFAULTS:
        configUtils.dumpJsonConfig(UI_DEFAULTS_PATH, uiState.toDict(
            ignoreKeys=[PANEL_ACTUAL_DIMS_INPUT,
                        INPUT_CHANGES_SAVE_DEFAULTS,
                        INPUT_CHANGES_RESET_TO_DEFAULTS,
                        INPUT_CHANGES_RESET_TO_FACTORY]))
        return
    if changed.id == INPUT_CHANGES_RESET_TO_DEFAULTS:
        initUiState()
        uiState.forceUIRefresh()
        return
    if changed.id == INPUT_CHANGES_RESET_TO_FACTORY:
        configUtils.deleteConfigFile(UI_DEFAULTS_PATH)
        initUiState()
        uiState.forceUIRefresh()
        return

    uiState.onInputUpdate(changed)

    # Re-register children when a group is expanded
    if isinstance(changed, adsk.core.GroupCommandInput) and changed.isExpanded:
        for inp in changed.children:
            uiState.registerCommandInput(inp)
        uiState.forceUIRefresh()

    inputs = args.inputs

    # Show / hide custom height
    if changed.id == PANEL_HEIGHT_PRESET_INPUT:
        custom = inputs.itemById(PANEL_HEIGHT_CUSTOM_INPUT)
        if custom:
            custom.isVisible = (uiState.getState(PANEL_HEIGHT_PRESET_INPUT) == HEIGHT_PRESET_CUSTOM)

    # Enable / disable slot style
    if changed.id == PANEL_ADD_MOUNTING_SLOTS_INPUT:
        style = inputs.itemById(PANEL_SLOT_STYLE_INPUT)
        if style:
            style.isEnabled = uiState.getState(PANEL_ADD_MOUNTING_SLOTS_INPUT)

    # Refresh the read-only dimensions text
    dims_box = inputs.itemById(PANEL_ACTUAL_DIMS_INPUT)
    if dims_box:
        dims_box.formattedText = _dims_text(
            uiState.getState(PANEL_WIDTH_HP_INPUT),
            uiState.getState(PANEL_HEIGHT_PRESET_INPUT),
            uiState.getState(PANEL_HEIGHT_CUSTOM_INPUT))

    futil.log(f'{CMD_NAME} input changed: {changed.id}')


def command_validate(args: adsk.core.ValidateInputsEventArgs):
    global INPUTS_VALID
    hp = uiState.getState(PANEL_WIDTH_HP_INPUT)
    h  = _height_cm(uiState.getState(PANEL_HEIGHT_PRESET_INPUT),
                    uiState.getState(PANEL_HEIGHT_CUSTOM_INPUT))
    INPUTS_VALID = hp >= 1 and h > 0
    args.areInputsValid = INPUTS_VALID


def command_destroy(args: adsk.core.CommandEventArgs):
    futil.log(f'{CMD_NAME} destroy')
    global local_handlers
    local_handlers = []


# ---------------------------------------------------------------------------
# Geometry generation
# ---------------------------------------------------------------------------

def _generate_panel(args: adsk.core.CommandEventArgs):
    try:
        des = adsk.fusion.Design.cast(app.activeProduct)
        if not des:
            ui.messageBox('A Fusion 360 design must be active.')
            return
        component = des.activeComponent

        hp         = uiState.getState(PANEL_WIDTH_HP_INPUT)
        preset     = uiState.getState(PANEL_HEIGHT_PRESET_INPUT)
        custom_cm  = uiState.getState(PANEL_HEIGHT_CUSTOM_INPUT)
        height_mm  = _height_cm(preset, custom_cm) * 10.0
        add_slots  = uiState.getState(PANEL_ADD_MOUNTING_SLOTS_INPUT)
        style_name = uiState.getState(PANEL_SLOT_STYLE_INPUT)
        style      = 'oblong' if style_name == SLOT_STYLE_OBLONG else 'circle'

        createMakerPanelSketch(
            component,
            widthHp=hp,
            heightMm=height_mm,
            addMountingSlots=add_slots,
            slotStyle=style,
        )
    except Exception as err:
        args.executeFailed = True
        args.executeFailedMessage = f'{err}\n{traceback.format_exc()}'
        futil.log(f'{CMD_NAME} generation error: {err}')


# ---------------------------------------------------------------------------
# Helpers
# ---------------------------------------------------------------------------

def _height_cm(preset: str, custom_cm: float) -> float:
    if preset == HEIGHT_PRESET_1U:
        return const.PANEL_1U_HEIGHT
    if preset == HEIGHT_PRESET_3U:
        return const.PANEL_3U_HEIGHT
    return custom_cm


def _dims_text(hp: int, preset: str, custom_cm: float) -> str:
    w_mm = hp * const.HP_UNIT * 10.0
    h_mm = _height_cm(preset, custom_cm) * 10.0
    return f'Width: {w_mm:.2f} mm ({hp} HP)     Height: {h_mm:.2f} mm'
