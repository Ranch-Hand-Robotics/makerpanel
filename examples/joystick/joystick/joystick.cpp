#include <stdio.h>
#include "pico/stdlib.h"
#include "hardware/i2c.h"
#include "hardware/adc.h"
#include "tusb.h"

// I2C defines
// SparkFun Pro Micro RP2350 onboard Qwiic: SDA=16, SCL=17 (I2C0).
// For an externally wired connector, change these to match its wiring.
#define I2C_PORT i2c0
#define I2C_SDA 16
#define I2C_SCL 17

// ADS1219: three pots plus a button, all single-ended against AGND.
// Requires REFP=pot supply=3V3 and REFN=AGND. See ../README.md.
#ifndef ADS1219_ENABLED
#define ADS1219_ENABLED 1
#endif
#define ADS1219_ADDRESS 0x40
#define ADS1219_X_CHANNEL 0
#define ADS1219_Y_CHANNEL 1
#define ADS1219_YAW_CHANNEL 2
#define ADS1219_BUTTON_CHANNEL 3
#define ADS1219_I2C_TIMEOUT_US 2000
#define ADS1219_CONVERSION_TIMEOUT_US 20000
#define ADS1219_RETRY_US 1000000

// Normalized 12-bit button levels: <=25% pressed, >=75% released.
// AIN3 needs an EXTERNAL 4.7k pull-up to 3V3; switch shorts it to GND.
#define ADS1219_BUTTON_PRESS_RAW 1024
#define ADS1219_BUTTON_RELEASE_RAW 3072

// Dedicated NC stop contact: GPIO3 -> NC contact -> GND; 4.7k to 3V3.
// High/open means stopped (including a broken wire). USB indication only!
#ifndef ESTOP_ENABLED
#define ESTOP_ENABLED 1
#endif
#define ESTOP_PIN 3

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

// Independent calibration for joystick 2, after scaling ADS1219 to 0..4095.
#define ADS1219_X_MIN_RAW 0
#define ADS1219_X_CENTER_RAW 2048
#define ADS1219_X_MAX_RAW 4095
#define ADS1219_X_INVERT 0
#define ADS1219_X_DEADZONE 6
#define ADS1219_Y_MIN_RAW 0
#define ADS1219_Y_CENTER_RAW 2048
#define ADS1219_Y_MAX_RAW 4095
#define ADS1219_Y_INVERT 1
#define ADS1219_Y_DEADZONE 6
#define ADS1219_YAW_MIN_RAW 0
#define ADS1219_YAW_CENTER_RAW 2048
#define ADS1219_YAW_MAX_RAW 4095
#define ADS1219_YAW_INVERT 0
#define ADS1219_YAW_DEADZONE 6

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

enum class AdsPhase { Reset, Start, Wait };

struct Ads1219State {
    JoystickState joystick;
    uint16_t pending[4];
    uint8_t channel;
    AdsPhase phase;
    uint64_t next_action_us;
    uint64_t conversion_started_us;
    bool ready;
};

static const AxisCalibration ADS1219_X_CAL = {
    ADS1219_X_MIN_RAW, ADS1219_X_CENTER_RAW, ADS1219_X_MAX_RAW,
    ADS1219_X_INVERT != 0, ADS1219_X_DEADZONE
};
static const AxisCalibration ADS1219_Y_CAL = {
    ADS1219_Y_MIN_RAW, ADS1219_Y_CENTER_RAW, ADS1219_Y_MAX_RAW,
    ADS1219_Y_INVERT != 0, ADS1219_Y_DEADZONE
};
static const AxisCalibration ADS1219_YAW_CAL = {
    ADS1219_YAW_MIN_RAW, ADS1219_YAW_CENTER_RAW, ADS1219_YAW_MAX_RAW,
    ADS1219_YAW_INVERT != 0, ADS1219_YAW_DEADZONE
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

static bool update_button(ButtonState *button, bool raw_pressed,
                          uint64_t now_us) {
    // Returns true when the debounced state changed.
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

static void init_estop(ButtonState *stop) {
#if ESTOP_ENABLED
    gpio_init(ESTOP_PIN);
    gpio_set_dir(ESTOP_PIN, GPIO_IN);
    gpio_pull_up(ESTOP_PIN);
    // Start stopped; require a stable closed contact before clearing.
    *stop = {true, true, time_us_64()};
#else
    *stop = {};
#endif
}

static void update_estop(ButtonState *stop, uint64_t now_us) {
#if ESTOP_ENABLED
    bool open = gpio_get(ESTOP_PIN) != 0;
    update_button(stop, open, now_us);
    // Assert immediately; debounce only the return to a closed contact.
    if (open) stop->pressed = true;
#endif
}

static bool ads1219_write(const uint8_t *data, size_t size) {
    return i2c_write_timeout_us(I2C_PORT, ADS1219_ADDRESS, data, size,
                               false, ADS1219_I2C_TIMEOUT_US) == (int)size;
}

static bool ads1219_read(uint8_t command, uint8_t *data, size_t size) {
    // Commands are latched on the final ACK; STOP then read is supported.
    return ads1219_write(&command, 1) &&
        i2c_read_timeout_us(I2C_PORT, ADS1219_ADDRESS, data, size,
                           false, ADS1219_I2C_TIMEOUT_US) == (int)size;
}

static uint16_t ads1219_normalize(const uint8_t *data) {
    uint32_t code = ((uint32_t)data[0] << 16) |
                    ((uint32_t)data[1] << 8) | data[2];
    // Signed 24-bit result: negative noise near ground must not wrap high.
    if (code & 0x800000u) return 0;
    return (uint16_t)(code >> 11); // 0..0x7fffff -> 0..4095
}

static void update_external_axis(AxisState *axis, uint16_t raw,
                                 const AxisCalibration *cal) {
    axis->raw = raw;
    axis->calibrated = calibrate_raw_to_axis(raw, cal);
    axis->filtered = smooth_axis(axis->filtered, axis->calibrated);
}

static void ads1219_commit(Ads1219State *adc, uint64_t now_us) {
    JoystickState *js = &adc->joystick;
    update_external_axis(&js->x, adc->pending[ADS1219_X_CHANNEL],
                         &ADS1219_X_CAL);
    update_external_axis(&js->y, adc->pending[ADS1219_Y_CHANNEL],
                         &ADS1219_Y_CAL);
    update_external_axis(&js->yaw, adc->pending[ADS1219_YAW_CHANNEL],
                         &ADS1219_YAW_CAL);
    uint16_t raw = adc->pending[ADS1219_BUTTON_CHANNEL];
    bool pressed = js->button.raw_pressed;
    if (raw <= ADS1219_BUTTON_PRESS_RAW) pressed = true;
    if (raw >= ADS1219_BUTTON_RELEASE_RAW) pressed = false;
    update_button(&js->button, pressed, now_us);
    adc->ready = true;
}

static void ads1219_failed(Ads1219State *adc, uint64_t now_us) {
    // Never leave the host driving on stale axes or a stuck button.
    adc->joystick = {};
    adc->ready = false;
    adc->channel = 0;
    adc->phase = AdsPhase::Reset;
    adc->next_action_us = now_us + ADS1219_RETRY_US;
}

static void poll_ads1219(Ads1219State *adc, uint64_t now_us) {
#if ADS1219_ENABLED
    if (now_us < adc->next_action_us) return;

    if (adc->phase == AdsPhase::Reset) {
        const uint8_t reset = 0x06;
        if (!ads1219_write(&reset, 1)) {
            ads1219_failed(adc, now_us);
            return;
        }
        adc->channel = 0;
        adc->phase = AdsPhase::Start;
        adc->next_action_us = time_us_64() + 1000; // RESET recovery
        return;
    }

    if (adc->phase == AdsPhase::Start) {
        // MUX=011..110: AIN0..3 vs AGND; gain=1; DR=1000 SPS;
        // CM=single-shot; VREF=external. Configs: 6D,8D,AD,CD.
        const uint8_t config[] = {
            0x40, (uint8_t)(((adc->channel + 3u) << 5) | 0x0du)
        };
        const uint8_t start = 0x08;
        if (!ads1219_write(config, sizeof(config)) ||
            !ads1219_write(&start, 1)) {
            ads1219_failed(adc, now_us);
            return;
        }
        adc->conversion_started_us = time_us_64();
        adc->next_action_us = adc->conversion_started_us + 1000;
        adc->phase = AdsPhase::Wait;
        return;
    }

    if (now_us - adc->conversion_started_us >=
        ADS1219_CONVERSION_TIMEOUT_US) {
        ads1219_failed(adc, now_us);
        return;
    }
    uint8_t status;
    if (!ads1219_read(0x24, &status, 1)) {
        ads1219_failed(adc, now_us);
        return;
    }
    if (!(status & 0x80u)) return; // DRDY register bit: 1 = new data

    uint8_t data[3];
    if (!ads1219_read(0x10, data, sizeof(data))) {
        ads1219_failed(adc, now_us);
        return;
    }
    adc->pending[adc->channel] = ads1219_normalize(data);
    if (++adc->channel == 4) {
        // Publish only a complete scan; debounce only on fresh samples.
        ads1219_commit(adc, time_us_64());
        adc->channel = 0;
    }
    adc->phase = AdsPhase::Start;
#endif
}

static void send_hid_report(const JoystickState *js,
                            const Ads1219State *adc,
                            const ButtonState *stop) {
    int8_t x = (int8_t)clamp_axis_value(js->x.filtered);
    int8_t y = (int8_t)clamp_axis_value(js->y.filtered);
    int8_t rz = (int8_t)clamp_axis_value(js->yaw.filtered);
    uint32_t buttons = js->button.pressed ? 0x01u : 0u;
    int8_t rx = 0, ry = 0, z = 0;
    if (ADS1219_ENABLED && adc->ready) {
        rx = (int8_t)clamp_axis_value(adc->joystick.x.filtered);
        ry = (int8_t)clamp_axis_value(adc->joystick.y.filtered);
        z = (int8_t)clamp_axis_value(adc->joystick.yaw.filtered);
        if (adc->joystick.button.pressed) buttons |= 0x02u;
    } else if (ADS1219_ENABLED) {
        buttons |= 0x08u; // Button 4: expansion unavailable
    }
    if (stop->pressed) {
        x = y = z = rz = rx = ry = 0;
        buttons = (buttons & ~0x03u) | 0x04u; // Button 3: stop
    }

    tud_hid_gamepad_report(0, x, y, z, rz, rx, ry,
                           GAMEPAD_HAT_CENTERED, buttons);
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
    Ads1219State expansion = {};
    ButtonState estop = {};
    init_button(&joystick.button);
    init_estop(&estop);
    init_axes();

    tusb_init();

    uint64_t last_report_us = 0;

    while (true) {
        tud_task();

        uint64_t now_us = time_us_64();
        update_button(&joystick.button, read_raw_button_pressed(), now_us);
        update_estop(&estop, now_us);
        poll_ads1219(&expansion, now_us);
        // Recheck after bounded I2C operations, before sending a report.
        now_us = time_us_64();
        update_estop(&estop, now_us);

        if ((now_us - last_report_us) >= (JOYSTICK_REPORT_MS * 1000ull)) {
            last_report_us = now_us;
            sample_joystick(&joystick);

            if (tud_mounted() && tud_hid_ready()) {
                send_hid_report(&joystick, &expansion, &estop);
            }
        }

        sleep_ms(1);
    }
}
