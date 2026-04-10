"""
commandCreateRail/entry.py — MakerRail sketch command.

Registers the 'MakerPanel Rail' button in the Fusion 360 Create toolbar
panel (FusionSolidEnvironment → SolidCreatePanel).  When clicked it opens
a dialog for configuring a MakerRail per the spec, then generates a 2D
sketch on the active component's XY plane.

Dialog layout:
  Info             — quick reference for slot/support dimensions
  Rail Dimensions  — U count, rail height, optional custom total length
  Features         — end mounting holes toggle
  Settings         — save / reset / factory-reset defaults
  Preview          — live-preview toggle
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
from ...lib.makerpanelUtils.railGenerator import createMakerRailSketch

# ---------------------------------------------------------------------------
# Command identity
# ---------------------------------------------------------------------------
CMD_ID          = f'{config.COMPANY_NAME}_{config.ADDIN_NAME}_cmdRail'
CMD_NAME        = 'MakerPanel Rail'
CMD_Description = 'Create a MakerPanel-compliant rail 2D sketch'

WORKSPACE_ID      = 'FusionSolidEnvironment'
PANEL_ID          = 'SketchPanel'
COMMAND_BESIDE_ID = 'SketchCreate'

ICON_FOLDER        = ''
CONFIG_FOLDER_PATH = os.path.join(os.path.dirname(os.path.abspath(__file__)), 'commandConfig')
UI_DEFAULTS_PATH   = os.path.join(CONFIG_FOLDER_PATH, 'ui_input_defaults.json')

# ---------------------------------------------------------------------------
# Input / group IDs
# ---------------------------------------------------------------------------
INFO_GROUP          = 'rail_info_group'
DIMENSIONS_GROUP    = 'rail_dimensions_group'
FEATURES_GROUP      = 'rail_features_group'
INPUT_CHANGES_GROUP = 'rail_input_changes_group'
PREVIEW_GROUP       = 'rail_preview_group'

RAIL_WIDTH_HP_INPUT           = 'rail_width_hp'
RAIL_HEIGHT_INPUT             = 'rail_height'
RAIL_USE_CUSTOM_LENGTH_INPUT  = 'rail_use_custom_length'
RAIL_CUSTOM_LENGTH_INPUT      = 'rail_custom_length'
RAIL_ADD_END_HOLES_INPUT      = 'rail_add_end_holes'
RAIL_HOLE_SIZE_INPUT          = 'rail_hole_size'
RAIL_ROTATE_90_INPUT          = 'rail_rotate_90'
RAIL_ACTUAL_DIMS_INPUT        = 'rail_actual_dims'   # read-only text
SHOW_PREVIEW_INPUT            = 'rail_show_preview'

HOLE_M3 = 'M3 (3.5 mm)'
HOLE_M4 = 'M4 (4.3 mm)'
HOLE_M5 = 'M5 (5.3 mm)'
HOLE_M6 = 'M6 (6.4 mm)'

HOLE_DIAMETERS_MM = {
    HOLE_M3: 3.5,
    HOLE_M4: 4.3,
    HOLE_M5: 5.3,
    HOLE_M6: 6.4,
}

INPUT_CHANGES_SAVE_DEFAULTS     = 'rail_changes_save'
INPUT_CHANGES_RESET_TO_DEFAULTS = 'rail_changes_reset'
INPUT_CHANGES_RESET_TO_FACTORY  = 'rail_changes_factory'

# ---------------------------------------------------------------------------
# Module-level state
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
    uiState.initValue(FEATURES_GROUP,      True, adsk.core.GroupCommandInput.classType())
    uiState.initValue(INPUT_CHANGES_GROUP, True, adsk.core.GroupCommandInput.classType())
    uiState.initValue(PREVIEW_GROUP,       True, adsk.core.GroupCommandInput.classType())
    # Inputs — rail height and custom length stored in cm (Fusion internal)
    uiState.initValue(RAIL_WIDTH_HP_INPUT,          20,                         adsk.core.IntegerSpinnerCommandInput.classType())
    uiState.initValue(RAIL_HEIGHT_INPUT,            const.RAIL_DEFAULT_HEIGHT,  adsk.core.ValueCommandInput.classType())
    uiState.initValue(RAIL_USE_CUSTOM_LENGTH_INPUT, False,                      adsk.core.BoolValueCommandInput.classType())
    uiState.initValue(RAIL_CUSTOM_LENGTH_INPUT,     const.RAIL_3U_SPACING,      adsk.core.ValueCommandInput.classType())
    uiState.initValue(RAIL_ADD_END_HOLES_INPUT,     True,    adsk.core.BoolValueCommandInput.classType())
    uiState.initValue(RAIL_HOLE_SIZE_INPUT,         HOLE_M3, adsk.core.DropDownCommandInput.classType())
    uiState.initValue(RAIL_ROTATE_90_INPUT,         False,   adsk.core.BoolValueCommandInput.classType())
    uiState.initValue(SHOW_PREVIEW_INPUT,           True,    adsk.core.BoolValueCommandInput.classType())

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
        'rail_info_text', '',
        '<b>MakerRail</b>: 1 HP = 5.08 mm | '
        'slot min width = 5.75 HP | '
        'support = 3 mm | pattern: [support][slot]…[support]',
        2, True)

    # --- Dimensions group ---
    dimsGroup = inputs.addGroupCommandInput(DIMENSIONS_GROUP, 'Rail Dimensions')
    dimsGroup.isExpanded = uiState.getState(DIMENSIONS_GROUP)
    uiState.registerCommandInput(dimsGroup)

    widthHpInput = dimsGroup.children.addIntegerSpinnerCommandInput(
        RAIL_WIDTH_HP_INPUT, 'Width (HP)', 1, 400, 1,
        uiState.getState(RAIL_WIDTH_HP_INPUT))
    widthHpInput.tooltip = 'Rail length in Horizontal Pitch units (1 HP = 5.08 mm)'    
    uiState.registerCommandInput(widthHpInput)

    heightInput = dimsGroup.children.addValueInput(
        RAIL_HEIGHT_INPUT, 'Rail Strip Height',
        defaultLengthUnits,
        adsk.core.ValueInput.createByReal(uiState.getState(RAIL_HEIGHT_INPUT)))
    heightInput.minimumValue    = 0.1
    heightInput.isMinimumInclusive = True
    heightInput.tooltip = 'Physical height of the rail strip (must exceed slot height of 6.2 mm)'
    uiState.registerCommandInput(heightInput)

    useCustomLength = dimsGroup.children.addBoolValueInput(
        RAIL_USE_CUSTOM_LENGTH_INPUT, 'Override Total Length', True, '',
        uiState.getState(RAIL_USE_CUSTOM_LENGTH_INPUT))
    useCustomLength.tooltip = 'Override the calculated length with a custom value'
    uiState.registerCommandInput(useCustomLength)

    customLengthInput = dimsGroup.children.addValueInput(
        RAIL_CUSTOM_LENGTH_INPUT, 'Custom Total Length',
        defaultLengthUnits,
        adsk.core.ValueInput.createByReal(uiState.getState(RAIL_CUSTOM_LENGTH_INPUT)))
    customLengthInput.minimumValue    = 0.1
    customLengthInput.isMinimumInclusive = True
    customLengthInput.isEnabled = uiState.getState(RAIL_USE_CUSTOM_LENGTH_INPUT)
    uiState.registerCommandInput(customLengthInput)

    # Read-only dimensions summary
    dimsGroup.children.addTextBoxCommandInput(
        RAIL_ACTUAL_DIMS_INPUT, '',
        _dims_text(uiState.getState(RAIL_WIDTH_HP_INPUT),
                   uiState.getState(RAIL_HEIGHT_INPUT),
                   uiState.getState(RAIL_USE_CUSTOM_LENGTH_INPUT),
                   uiState.getState(RAIL_CUSTOM_LENGTH_INPUT),
                   uiState.getState(RAIL_ADD_END_HOLES_INPUT)),
        3, True)

    # --- Features group ---
    featGroup = inputs.addGroupCommandInput(FEATURES_GROUP, 'Features')
    featGroup.isExpanded = uiState.getState(FEATURES_GROUP)
    uiState.registerCommandInput(featGroup)

    endHolesInput = featGroup.children.addBoolValueInput(
        RAIL_ADD_END_HOLES_INPUT, 'Add End Mounting Holes', True, '',
        uiState.getState(RAIL_ADD_END_HOLES_INPUT))
    endHolesInput.tooltip = 'Add clearance holes centred in the support webs at each end of the rail'
    uiState.registerCommandInput(endHolesInput)

    holeSizeInput = featGroup.children.addDropDownCommandInput(
        RAIL_HOLE_SIZE_INPUT, 'Screw Size',
        adsk.core.DropDownStyles.TextListDropDownStyle)
    current_hole = uiState.getState(RAIL_HOLE_SIZE_INPUT)
    for opt in (HOLE_M3, HOLE_M4, HOLE_M5, HOLE_M6):
        holeSizeInput.listItems.add(opt, current_hole == opt)
    holeSizeInput.isEnabled = uiState.getState(RAIL_ADD_END_HOLES_INPUT)
    uiState.registerCommandInput(holeSizeInput)

    rotate90Input = featGroup.children.addBoolValueInput(
        RAIL_ROTATE_90_INPUT, '90 Degree (vertical)', True, '',
        uiState.getState(RAIL_ROTATE_90_INPUT))
    rotate90Input.tooltip = 'Draw the rail vertically (length along the Y axis)'
    uiState.registerCommandInput(rotate90Input)

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
    futil.add_handler(args.command.execute,        command_execute,       local_handlers=local_handlers)
    futil.add_handler(args.command.inputChanged,   command_input_changed, local_handlers=local_handlers)
    futil.add_handler(args.command.executePreview, command_preview,       local_handlers=local_handlers)
    futil.add_handler(args.command.validateInputs, command_validate,      local_handlers=local_handlers)
    futil.add_handler(args.command.destroy,        command_destroy,       local_handlers=local_handlers)


# ---------------------------------------------------------------------------
# Event handlers
# ---------------------------------------------------------------------------

def command_execute(args: adsk.core.CommandEventArgs):
    futil.log(f'{CMD_NAME} execute')
    _generate_rail(args)


def command_preview(args: adsk.core.CommandEventArgs):
    futil.log(f'{CMD_NAME} preview')
    inputs     = args.command.commandInputs
    show_input = inputs.itemById(SHOW_PREVIEW_INPUT)
    if show_input and show_input.value and INPUTS_VALID:
        _generate_rail(args)


def command_input_changed(args: adsk.core.InputChangedEventArgs):
    changed = args.input
    global uiState

    if changed.id == INPUT_CHANGES_SAVE_DEFAULTS:
        configUtils.dumpJsonConfig(UI_DEFAULTS_PATH, uiState.toDict(
            ignoreKeys=[RAIL_ACTUAL_DIMS_INPUT,
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

    if isinstance(changed, adsk.core.GroupCommandInput) and changed.isExpanded:
        for inp in changed.children:
            uiState.registerCommandInput(inp)
        uiState.forceUIRefresh()

    inputs = args.inputs

    # Enable / disable hole size dropdown when end holes toggled
    if changed.id == RAIL_ADD_END_HOLES_INPUT:
        hole_size = inputs.itemById(RAIL_HOLE_SIZE_INPUT)
        if hole_size:
            hole_size.isEnabled = uiState.getState(RAIL_ADD_END_HOLES_INPUT)

    # Enable / disable custom length field
    if changed.id == RAIL_USE_CUSTOM_LENGTH_INPUT:
        cl = inputs.itemById(RAIL_CUSTOM_LENGTH_INPUT)
        if cl:
            cl.isEnabled = uiState.getState(RAIL_USE_CUSTOM_LENGTH_INPUT)

    # Refresh dimensions summary
    dims_box = inputs.itemById(RAIL_ACTUAL_DIMS_INPUT)
    if dims_box:
        dims_box.formattedText = _dims_text(
            uiState.getState(RAIL_WIDTH_HP_INPUT),
            uiState.getState(RAIL_HEIGHT_INPUT),
            uiState.getState(RAIL_USE_CUSTOM_LENGTH_INPUT),
            uiState.getState(RAIL_CUSTOM_LENGTH_INPUT),
            uiState.getState(RAIL_ADD_END_HOLES_INPUT))

    futil.log(f'{CMD_NAME} input changed: {changed.id}')


def command_validate(args: adsk.core.ValidateInputsEventArgs):
    global INPUTS_VALID
    hp        = uiState.getState(RAIL_WIDTH_HP_INPUT)
    h_cm      = uiState.getState(RAIL_HEIGHT_INPUT)
    use_cust  = uiState.getState(RAIL_USE_CUSTOM_LENGTH_INPUT)
    cust_cm   = uiState.getState(RAIL_CUSTOM_LENGTH_INPUT)

    INPUTS_VALID = (
        hp >= 1
        and h_cm > const.RAIL_SLOT_HEIGHT
        and (not use_cust or cust_cm > 0)
    )
    args.areInputsValid = INPUTS_VALID


def command_destroy(args: adsk.core.CommandEventArgs):
    futil.log(f'{CMD_NAME} destroy')
    global local_handlers
    local_handlers = []


# ---------------------------------------------------------------------------
# Geometry generation
# ---------------------------------------------------------------------------

def _generate_rail(args: adsk.core.CommandEventArgs):
    try:
        des = adsk.fusion.Design.cast(app.activeProduct)
        if not des:
            ui.messageBox('A Fusion 360 design must be active.')
            return
        component = des.activeComponent

        width_hp       = uiState.getState(RAIL_WIDTH_HP_INPUT)
        height_cm      = uiState.getState(RAIL_HEIGHT_INPUT)
        height_mm      = height_cm * 10.0
        use_custom     = uiState.getState(RAIL_USE_CUSTOM_LENGTH_INPUT)
        custom_cm      = uiState.getState(RAIL_CUSTOM_LENGTH_INPUT)
        custom_mm      = custom_cm * 10.0 if use_custom else None
        add_end_holes      = uiState.getState(RAIL_ADD_END_HOLES_INPUT)
        hole_size_name     = uiState.getState(RAIL_HOLE_SIZE_INPUT)
        hole_diameter_mm   = HOLE_DIAMETERS_MM.get(hole_size_name, 3.5)
        rotate90           = uiState.getState(RAIL_ROTATE_90_INPUT)

        createMakerRailSketch(
            component,
            widthHp=width_hp,
            railHeightMm=height_mm,
            customLengthMm=custom_mm,
            addEndHoles=add_end_holes,
            holeDiameterMm=hole_diameter_mm,
            rotate90=rotate90,
        )
    except Exception as err:
        args.executeFailed = True
        args.executeFailedMessage = f'{err}\n{traceback.format_exc()}'
        futil.log(f'{CMD_NAME} generation error: {err}')


# ---------------------------------------------------------------------------
# Helpers
# ---------------------------------------------------------------------------

def _default_length_mm(width_hp):
    """Return the default rail length (mm) for width_hp HP."""
    return width_hp * const.HP_UNIT * 10.0


def _dims_text(width_hp: int, height_cm: float, use_custom: bool,
               custom_cm: float, add_end_holes: bool = True) -> str:
    length_mm  = custom_cm * 10.0 if use_custom else _default_length_mm(width_hp)
    height_mm  = height_cm * 10.0
    length_cm  = length_mm / 10.0
    end_margin = height_cm if add_end_holes else const.RAIL_SUPPORT_WIDTH
    available  = length_cm - 2 * end_margin
    min_pitch  = const.RAIL_SLOT_MIN_WIDTH + const.RAIL_SUPPORT_WIDTH
    n_slots    = max(1, int((available + const.RAIL_SUPPORT_WIDTH) / min_pitch))
    return (f'Length: {length_mm:.2f} mm ({width_hp} HP) | '
            f'Height: {height_mm:.2f} mm | '
            f'Slots: {n_slots}')
