#include <stdio.h>
#include "pico/stdlib.h"
#include "hardware/i2c.h"
#include "hardware/adc.h"
#include "tusb.h"

// I2C defines
// This example uses I2C0 on GPIO8 (SDA) and GPIO9 (SCL) for Qwiic expansion.
#define I2C_PORT i2c0
#define I2C_SDA 8
#define I2C_SCL 9

// ADC constants
#define ADC_MAX_READING 4095u

// Sample/report timing
#define BUTTON_DEBOUNCE_MS 25
#define JOYSTICK_REPORT_MS 10

// Axis processing tuning
// Smoothing factor N: output = ((N-1) * previous + current) / N
// 1 = no smoothing, larger values = more smoothing.
#define AXIS_SMOOTHING_FACTOR 4

// Top button configuration
// Default wiring: button between BUTTON_PIN and GND using internal pull-up.
#define BUTTON_PIN 2
#define BUTTON_ACTIVE_LOW 1

// Axis configuration for three 10k potentiometers:
// X axis -> A0 (GPIO26 / ADC0)
// Y axis -> A1 (GPIO27 / ADC1)
// Yaw   -> A2 (GPIO28 / ADC2)
#define AXIS_X_ADC_GPIO 26
#define AXIS_X_ADC_INPUT 0
#define AXIS_Y_ADC_GPIO 27
#define AXIS_Y_ADC_INPUT 1
#define AXIS_YAW_ADC_GPIO 28
#define AXIS_YAW_ADC_INPUT 2

// Axis inversion flags (set to 1 to invert that axis)
#define AXIS_X_INVERT 0
#define AXIS_Y_INVERT 1
#define AXIS_YAW_INVERT 0

// Axis deadzone in HID units (0..127)
#define AXIS_X_DEADZONE 6
#define AXIS_Y_DEADZONE 6
#define AXIS_YAW_DEADZONE 6

// Per-axis calibration defaults. Adjust after observing raw values.
#define AXIS_X_MIN_RAW 0
#define AXIS_X_CENTER_RAW 2048
#define AXIS_X_MAX_RAW 4095

#define AXIS_Y_MIN_RAW 0
#define AXIS_Y_CENTER_RAW 2048
#define AXIS_Y_MAX_RAW 4095

#define AXIS_YAW_MIN_RAW 0
#define AXIS_YAW_CENTER_RAW 2048
#define AXIS_YAW_MAX_RAW 4095

struct AxisConfig {
    uint gpio;
    uint input;
};

struct AxisState {
    uint16_t raw;
    int16_t calibrated;
    int16_t filtered;
};

struct AxisCalibration {
    uint16_t min_raw;
    uint16_t center_raw;
    uint16_t max_raw;
    bool invert;
    uint8_t deadzone;
};

struct ButtonState {
    bool raw_pressed;
    bool pressed;
    uint64_t last_change_time_us;
};

struct JoystickState {
    AxisState x;
    AxisState y;
    AxisState yaw;
    ButtonState button;
};

static const AxisConfig AXIS_X = {AXIS_X_ADC_GPIO, AXIS_X_ADC_INPUT};
static const AxisConfig AXIS_Y = {AXIS_Y_ADC_GPIO, AXIS_Y_ADC_INPUT};
static const AxisConfig AXIS_YAW = {AXIS_YAW_ADC_GPIO, AXIS_YAW_ADC_INPUT};

static const AxisCalibration AXIS_X_CAL = {
    AXIS_X_MIN_RAW,
    AXIS_X_CENTER_RAW,
    AXIS_X_MAX_RAW,
    AXIS_X_INVERT != 0,
    AXIS_X_DEADZONE
};

static const AxisCalibration AXIS_Y_CAL = {
    AXIS_Y_MIN_RAW,
    AXIS_Y_CENTER_RAW,
    AXIS_Y_MAX_RAW,
    AXIS_Y_INVERT != 0,
    AXIS_Y_DEADZONE
};

static const AxisCalibration AXIS_YAW_CAL = {
    AXIS_YAW_MIN_RAW,
    AXIS_YAW_CENTER_RAW,
    AXIS_YAW_MAX_RAW,
    AXIS_YAW_INVERT != 0,
    AXIS_YAW_DEADZONE
};

static void init_i2c_qwiic_pins() {
    i2c_init(I2C_PORT, 400 * 1000);
    gpio_set_function(I2C_SDA, GPIO_FUNC_I2C);
    gpio_set_function(I2C_SCL, GPIO_FUNC_I2C);
    gpio_pull_up(I2C_SDA);
    gpio_pull_up(I2C_SCL);
}

static void init_button(ButtonState *button) {
    gpio_init(BUTTON_PIN);
    gpio_set_dir(BUTTON_PIN, GPIO_IN);
#if BUTTON_ACTIVE_LOW
    gpio_pull_up(BUTTON_PIN);
#else
    gpio_pull_down(BUTTON_PIN);
#endif

    button->raw_pressed = false;
    button->pressed = false;
    button->last_change_time_us = time_us_64();
}

static void init_axis(const AxisConfig *cfg) {
    adc_gpio_init(cfg->gpio);
}

static void init_axes() {
    adc_init();
    init_axis(&AXIS_X);
    init_axis(&AXIS_Y);
    init_axis(&AXIS_YAW);
}

static uint16_t read_axis_raw(uint input) {
    adc_select_input(input);
    return adc_read();
}

static int16_t clamp_axis_value(int32_t v) {
    if (v < -127) return -127;
    if (v > 127) return 127;
    return (int16_t)v;
}

static int16_t apply_deadzone(int16_t value, uint8_t deadzone) {
    if (deadzone == 0) {
        return value;
    }
    if (deadzone >= 127) {
        return 0;
    }

    if (value > 0) {
        if (value <= deadzone) return 0;
        return (int16_t)(((int32_t)(value - deadzone) * 127) / (127 - deadzone));
    }

    if (value < 0) {
        if (value >= -(int16_t)deadzone) return 0;
        return (int16_t)(((int32_t)(value + deadzone) * 127) / (127 - deadzone));
    }

    return 0;
}

static int16_t calibrate_raw_to_axis(uint16_t raw, const AxisCalibration *cal) {
    int32_t value = 0;

    if (raw >= cal->center_raw) {
        uint16_t span = (cal->max_raw > cal->center_raw) ? (cal->max_raw - cal->center_raw) : 1;
        value = ((int32_t)(raw - cal->center_raw) * 127) / span;
    } else {
        uint16_t span = (cal->center_raw > cal->min_raw) ? (cal->center_raw - cal->min_raw) : 1;
        value = -((int32_t)(cal->center_raw - raw) * 127) / span;
    }

    value = clamp_axis_value(value);
    if (cal->invert) {
        value = -value;
    }

    value = apply_deadzone((int16_t)value, cal->deadzone);
    return clamp_axis_value(value);
}

static int16_t smooth_axis(int16_t previous, int16_t current) {
#if AXIS_SMOOTHING_FACTOR <= 1
    return current;
#else
    return (int16_t)(((int32_t)previous * (AXIS_SMOOTHING_FACTOR - 1) + current) / AXIS_SMOOTHING_FACTOR);
#endif
}

static void update_axis_state(AxisState *state, const AxisConfig *cfg, const AxisCalibration *cal) {
    state->raw = read_axis_raw(cfg->input);
    state->calibrated = calibrate_raw_to_axis(state->raw, cal);
    state->filtered = smooth_axis(state->filtered, state->calibrated);
}

static bool read_raw_button_pressed() {
#if BUTTON_ACTIVE_LOW
    return gpio_get(BUTTON_PIN) == 0;
#else
    return gpio_get(BUTTON_PIN) != 0;
#endif
}

static bool update_button(ButtonState *button, uint64_t now_us) {
    // Returns true when the debounced state changed.
    bool raw_pressed = read_raw_button_pressed();
    if (raw_pressed != button->raw_pressed) {
        button->raw_pressed = raw_pressed;
        button->last_change_time_us = now_us;
    }

    if ((now_us - button->last_change_time_us) >= (BUTTON_DEBOUNCE_MS * 1000ull) &&
        button->raw_pressed != button->pressed) {
        button->pressed = button->raw_pressed;
        return true;
    }

    return false;
}

static void sample_joystick(JoystickState *js) {
    update_axis_state(&js->x, &AXIS_X, &AXIS_X_CAL);
    update_axis_state(&js->y, &AXIS_Y, &AXIS_Y_CAL);
    update_axis_state(&js->yaw, &AXIS_YAW, &AXIS_YAW_CAL);
}

static void send_hid_report(const JoystickState *js) {
    int8_t x = (int8_t)clamp_axis_value(js->x.filtered);
    int8_t y = (int8_t)clamp_axis_value(js->y.filtered);
    int8_t rz = (int8_t)clamp_axis_value(js->yaw.filtered);
    uint32_t buttons = js->button.pressed ? 0x01u : 0u;

    tud_hid_gamepad_report(0, x, y, 0, rz, 0, 0, GAMEPAD_HAT_CENTERED, buttons);
}

extern "C" uint16_t tud_hid_get_report_cb(uint8_t instance,
                                           uint8_t report_id,
                                           hid_report_type_t report_type,
                                           uint8_t *buffer,
                                           uint16_t reqlen) {
    (void)instance;
    (void)report_id;
    (void)report_type;
    (void)buffer;
    (void)reqlen;
    return 0;
}

extern "C" void tud_hid_set_report_cb(uint8_t instance,
                                        uint8_t report_id,
                                        hid_report_type_t report_type,
                                        uint8_t const *buffer,
                                        uint16_t bufsize) {
    (void)instance;
    (void)report_id;
    (void)report_type;
    (void)buffer;
    (void)bufsize;
}

int main() {
    stdio_init_all();

    init_i2c_qwiic_pins();

    JoystickState joystick = {};
    init_button(&joystick.button);
    init_axes();

    tusb_init();

    uint64_t last_report_us = 0;

    while (true) {
        tud_task();

        uint64_t now_us = time_us_64();
        update_button(&joystick.button, now_us);

        if ((now_us - last_report_us) >= (JOYSTICK_REPORT_MS * 1000ull)) {
            last_report_us = now_us;
            sample_joystick(&joystick);

            if (tud_mounted() && tud_hid_ready()) {
                send_hid_report(&joystick);
            }
        }

        sleep_ms(1);
    }
}
