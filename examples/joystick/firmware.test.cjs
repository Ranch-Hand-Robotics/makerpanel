// Run with node --test. Set CXX to an absolute native clang++/g++ executable
// to also compile and execute the actual firmware with mocked Pico/TinyUSB IO.
const test = require('node:test');
const assert = require('node:assert/strict');
const fs = require('node:fs');
const os = require('node:os');
const path = require('node:path');
const { spawnSync } = require('node:child_process');

const firmwareDir = path.join(__dirname, 'joystick');
const source = fs.readFileSync(path.join(firmwareDir, 'joystick.cpp'), 'utf8');
const readme = fs.readFileSync(path.join(__dirname, 'README.md'), 'utf8');

function define(name) {
    const match = source.match(new RegExp(`^#define ${name} (\\w+)$`, 'm'));
    assert.ok(match, `Missing literal definition: ${name}`);
    return Number(match[1]);
}

test('source contract: schematic pins and address do not collide', () => {
    assert.equal(define('ADS1219_ADDRESS'), 0x40);
    assert.equal(define('I2C_SDA'), 16);
    assert.equal(define('I2C_SCL'), 17);
    assert.equal(define('ESTOP_PIN'), 3);
    const pins = ['I2C_SDA', 'I2C_SCL', 'BUTTON_PIN', 'ESTOP_PIN',
        'AXIS_X_ADC_GPIO', 'AXIS_Y_ADC_GPIO', 'AXIS_YAW_ADC_GPIO'].map(define);
    assert.equal(new Set(pins).size, pins.length);
    const channels = ['X', 'Y', 'YAW', 'BUTTON'].map(
        axis => define(`ADS1219_${axis}_CHANNEL`));
    assert.deepEqual(channels, [0, 3, 2, 1]);
});

test('source contract: wiring guide matches button and stop defaults', () => {
    assert.equal(define('ADS1219_BUTTON_PRESS_RAW'), 1024);
    assert.equal(define('ADS1219_BUTTON_RELEASE_RAW'), 3072);
    assert.ok(define('ADS1219_BUTTON_PRESS_RAW') <
        define('ADS1219_BUTTON_RELEASE_RAW'));
    assert.equal(define('BUTTON_DEBOUNCE_MS'), 25);
    assert.equal(define('ADS1219_ENABLED'), 1);
    assert.equal(define('ESTOP_ENABLED'), 1);
    for (const term of ['REFP', 'REFN', '4.7 kohm', 'AIN3', 'GPIO3',
        'normally closed', 'not a safety-rated', 'manual-reset/rearm']) {
        assert.ok(readme.includes(term), `Missing wiring guidance: ${term}`);
    }
    assert.match(readme, /Joystick 2 Y wiper \| ADS1219 AIN3 \| Rx/);
    assert.match(readme, /Joystick 2 top button \| ADS1219 AIN1/);
    assert.ok(readme.includes('REFP (tied to 3V3) to AIN1'));
    assert.ok(readme.includes('Do not directly bridge AIN1 to REFP'));
    const diagram = fs.readFileSync(
        path.join(__dirname, 'images', 'ads1219-wiring.svg'), 'utf8');
    assert.match(diagram, /AIN3 Y,.*AIN1 button, AIN0 X/);
    assert.ok(diagram.includes('wiper → AIN3'));
    assert.ok(diagram.includes('Do not bridge AIN1 directly to REFP'));
});

test('source contract: composite diagram matches firmware inputs', () => {
    const diagram = fs.readFileSync(
        path.join(__dirname, 'images', 'controller-wiring.svg'), 'utf8');
    const gpioSignals = {
        J1_X: 'AXIS_X_ADC_GPIO', J1_Y: 'AXIS_Y_ADC_GPIO',
        J1_TWIST: 'AXIS_YAW_ADC_GPIO', J1_BTN: 'BUTTON_PIN',
        STOP: 'ESTOP_PIN', SDA: 'I2C_SDA', SCL: 'I2C_SCL'
    };
    for (const [signal, name] of Object.entries(gpioSignals)) {
        assert.ok(diagram.includes(
            `data-signal="${signal}" data-gpio="${define(name)}"`), name);
    }
    for (const [signal, axis] of Object.entries({
        J2_X: 'X', J2_Y: 'Y', J2_TWIST: 'YAW', J2_BTN: 'BUTTON'
    })) {
        const channel = define(`ADS1219_${axis}_CHANNEL`);
        assert.ok(diagram.includes(
            `data-signal="${signal}" data-ain="${channel}"`), signal);
    }
    for (const term of ['SparkFun Pro Micro RP2350', 'REFP → 3V3',
        'REFN → GND', 'R1 · 4.7 kΩ', 'R2 · 4.7 kΩ', 'C1 · 100 nF',
        'Do not bridge AIN1 directly to REFP',
        'Not a safety-rated emergency stop']) {
        assert.ok(diagram.includes(term), `Missing diagram guidance: ${term}`);
    }
    assert.ok(readme.includes('images/controller-wiring.png'));
    assert.ok(readme.includes('images/controller-wiring.svg'));
});

test('source contract: rotate both USB stick pairs, not their wiring', () => {
    for (const [output, input] of [
        ['x', 'js->y.filtered'], ['y', '-js->x.filtered'],
        ['rx', '-adc->joystick.y.filtered'],
        ['ry', '-adc->joystick.x.filtered'],
        ['z', 'js->yaw.filtered'], ['rz', 'adc->joystick.yaw.filtered']
    ]) {
        assert.ok(source.includes(
            `${output} = (int8_t)clamp_axis_value(${input});`), output);
    }
    assert.ok(readme.includes('new X = old Y, new Y = -old X'));
    assert.ok(readme.includes('Rx = -old Y, Ry = -old X'));
    assert.match(readme, /Joystick 1 twist wiper \| A2 \/ GPIO28 \/ ADC2 \| Z \|/);
    assert.match(readme, /Joystick 2 twist wiper \| ADS1219 AIN2 \| Rz/);
});

test('source contract: stop only adds Button 3 without masking inputs', () => {
    const stopBranch = source.match(/if \(stop->pressed\) \{([^}]+)\}/);
    assert.ok(stopBranch, 'Missing stop status reporting');
    assert.equal(stopBranch[1].replace(/\/\/[^\n]*/g, '').trim(),
        'buttons |= 0x04u;');
    assert.ok(readme.includes('**status-only**'));
    const diagram = fs.readFileSync(
        path.join(__dirname, 'images', 'controller-wiring.svg'), 'utf8');
    assert.ok(diagram.includes('Axes and top buttons keep reporting'));
});

test('source contract: retain HID descriptor and disable USB stdio', () => {
    const descriptor = fs.readFileSync(
        path.join(firmwareDir, 'usb_hid_descriptors.c'), 'utf8');
    const cmake = fs.readFileSync(
        path.join(firmwareDir, 'CMakeLists.txt'), 'utf8');
    assert.match(descriptor, /TUD_HID_REPORT_DESC_GAMEPAD\(\)/);
    assert.match(cmake, /pico_enable_stdio_usb\(joystick 0\)/);
    assert.match(source, /i2c_write_timeout_us/);
    assert.match(source, /i2c_read_timeout_us/);
    assert.doesNotMatch(source, /i2c_(read|write)_blocking/);
});

const mocks = String.raw`
#pragma once
#include <cassert>
#include <cstddef>
#include <cstdint>
#include <deque>
#include <vector>
using uint = unsigned int;
using hid_report_type_t = int;
constexpr int GPIO_FUNC_I2C = 3, GPIO_IN = 0, GAMEPAD_HAT_CENTERED = 0;
inline int *i2c0 = nullptr;
inline uint64_t clock_us = 0;
inline bool levels[32] = {};
inline std::vector<std::vector<uint8_t>> writes;
inline std::deque<std::vector<uint8_t>> reads;
inline bool fail_write = false;
inline int8_t axes[6] = {};
inline uint32_t hid_buttons = 0;
inline uint64_t time_us_64() { return clock_us; }
inline void stdio_init_all() {}
inline void i2c_init(int *, int) {}
inline void gpio_set_function(uint, int) {}
inline void gpio_init(uint) {}
inline void gpio_set_dir(uint, int) {}
inline void gpio_pull_up(uint) {}
inline void gpio_pull_down(uint) {}
inline bool gpio_get(uint pin) { return levels[pin]; }
inline void adc_gpio_init(uint) {}
inline void adc_init() {}
inline void adc_select_input(uint) {}
inline uint16_t adc_read() { return 2048; }
inline void tusb_init() {}
inline void tud_task() {}
inline bool tud_mounted() { return true; }
inline bool tud_hid_ready() { return true; }
inline void sleep_ms(int) {}
inline int i2c_write_timeout_us(int *, uint8_t address,
    const uint8_t *data, size_t count, bool nostop, uint timeout) {
    assert(address == 0x40 && !nostop && timeout == 2000);
    writes.emplace_back(data, data + count);
    return fail_write ? -1 : static_cast<int>(count);
}
inline int i2c_read_timeout_us(int *, uint8_t address, uint8_t *data,
    size_t count, bool nostop, uint timeout) {
    assert(address == 0x40 && !nostop && timeout == 2000);
    assert(!reads.empty());
    auto next = reads.front();
    reads.pop_front();
    for (size_t i = 0; i < count && i < next.size(); ++i) data[i] = next[i];
    return static_cast<int>(next.size());
}
inline bool tud_hid_gamepad_report(uint8_t, int8_t x, int8_t y, int8_t z,
    int8_t rz, int8_t rx, int8_t ry, uint8_t, uint32_t buttons) {
    axes[0] = x; axes[1] = y; axes[2] = z;
    axes[3] = rz; axes[4] = rx; axes[5] = ry;
    hid_buttons = buttons;
    return true;
}
`;

const harness = String.raw`
#define main joystick_firmware_main
#include "joystick.cpp"
#undef main

static void poll_at(Ads1219State *adc, uint64_t time) {
    clock_us = time;
    poll_ads1219(adc, time);
}

int main() {
    // Signed 24-bit decoding must saturate negatives, never wrap high.
    const uint8_t zero[] = {0, 0, 0}, middle[] = {0x40, 0, 0};
    const uint8_t full[] = {0x7f, 0xff, 0xff};
    const uint8_t negative[] = {0xff, 0xff, 0xff};
    const uint8_t minimum[] = {0x80, 0, 0};
    assert(ads1219_normalize(zero) == 0);
    assert(ads1219_normalize(middle) == 2048);
    assert(ads1219_normalize(full) == 4095);
    assert(ads1219_normalize(negative) == 0);
    assert(ads1219_normalize(minimum) == 0);
    assert(calibrate_raw_to_axis(0, &ADS1219_X_CAL) == -127);
    assert(calibrate_raw_to_axis(2048, &ADS1219_X_CAL) == 0);
    assert(calibrate_raw_to_axis(4095, &ADS1219_X_CAL) == 127);
    assert(calibrate_raw_to_axis(4095, &ADS1219_Y_CAL) == -127);

    // Physical AIN1 is the button; AIN3 now independently supplies Y.
    Ads1219State mapping = {};
    mapping.pending[0] = 1024;
    mapping.pending[1] = 4095;
    mapping.pending[2] = 2048;
    mapping.pending[3] = 0;
    ads1219_commit(&mapping, 0);
    ads1219_commit(&mapping, 25000);
    assert(mapping.joystick.x.raw == 1024);
    assert(mapping.joystick.y.raw == 0);
    assert(mapping.joystick.yaw.raw == 2048);
    assert(!mapping.joystick.button.pressed);
    mapping.pending[1] = 0;
    mapping.pending[3] = 4095;
    ads1219_commit(&mapping, 30000);
    ads1219_commit(&mapping, 55000);
    assert(mapping.joystick.y.raw == 4095);
    assert(mapping.joystick.y.calibrated == -127);
    assert(mapping.joystick.button.pressed);

    // Analog hysteresis and 25ms debounce operate on fresh samples only.
    Ads1219State button = {};
    button.pending[ADS1219_BUTTON_CHANNEL] = 4095;
    ads1219_commit(&button, 0);
    button.pending[ADS1219_BUTTON_CHANNEL] = 1024;
    ads1219_commit(&button, 1000);
    assert(!button.joystick.button.pressed);
    button.pending[ADS1219_BUTTON_CHANNEL] = 2000; // retain candidate
    ads1219_commit(&button, 25999);
    assert(!button.joystick.button.pressed);
    ads1219_commit(&button, 26000);
    assert(button.joystick.button.pressed);
    button.pending[ADS1219_BUTTON_CHANNEL] = 3072;
    ads1219_commit(&button, 27000);
    button.pending[ADS1219_BUTTON_CHANNEL] = 0; // bounce cancels release
    ads1219_commit(&button, 30000);
    button.pending[ADS1219_BUTTON_CHANNEL] = 4095;
    ads1219_commit(&button, 32000);
    ads1219_commit(&button, 56999);
    assert(button.joystick.button.pressed);
    ads1219_commit(&button, 57000);
    assert(!button.joystick.button.pressed);

    ButtonState stop = {};
    clock_us = 0;
    init_estop(&stop);
#if ESTOP_ENABLED
    assert(stop.pressed); // boot status asserted even with a closed contact
    levels[ESTOP_PIN] = false;
    update_estop(&stop, 1000);
    update_estop(&stop, 25999);
    assert(stop.pressed);
    update_estop(&stop, 26000);
    assert(!stop.pressed);
    levels[ESTOP_PIN] = true;
    update_estop(&stop, 27000);
    assert(stop.pressed); // immediate on open wire/contact
    levels[ESTOP_PIN] = false;
    update_estop(&stop, 28000);
    levels[ESTOP_PIN] = true;
    update_estop(&stop, 29000);
    levels[ESTOP_PIN] = false;
    update_estop(&stop, 30000);
    update_estop(&stop, 54999);
    assert(stop.pressed);
    update_estop(&stop, 55000);
    assert(!stop.pressed);
#else
    assert(!stop.pressed);
    update_estop(&stop, 100000);
    assert(!stop.pressed);
#endif

    Ads1219State adc = {};
#if ADS1219_ENABLED
    poll_at(&adc, 0);
    assert(writes.back() == std::vector<uint8_t>({0x06}));
    assert(adc.phase == AdsPhase::Start);
    poll_at(&adc, 999);
    assert(writes.size() == 1); // reset recovery, no early WREG
    for (unsigned channel = 0; channel < 4; ++channel) {
        uint64_t start = 1000 + channel * 3000;
        poll_at(&adc, start);
        assert(writes[writes.size() - 2] == std::vector<uint8_t>(
            {0x40, static_cast<uint8_t>(0x6d + channel * 0x20)}));
        assert(writes.back() == std::vector<uint8_t>({0x08}));
        reads.push_back({0x01}); // not ready, including reserved bits
        poll_at(&adc, start + 1000);
        assert(writes.back() == std::vector<uint8_t>({0x24}));
        assert(adc.channel == channel && !adc.ready);
        reads.push_back({0x81}); // ready, reserved bits ignored
        reads.push_back({0x40, 0, 0});
        poll_at(&adc, start + 2000);
        assert(writes.back() == std::vector<uint8_t>({0x10}));
        assert(adc.ready == (channel == 3));
    }
    assert(adc.joystick.x.raw == 2048 && adc.joystick.x.filtered == 0);

    // A conversion deadline drops stale values and starts retry backoff.
    poll_at(&adc, 13000);
    adc.joystick.x.filtered = 100;
    adc.joystick.button.pressed = true;
    poll_at(&adc, 33000);
    assert(!adc.ready && adc.phase == AdsPhase::Reset);
    assert(adc.joystick.x.filtered == 0 && !adc.joystick.button.pressed);
    const size_t count = writes.size();
    poll_at(&adc, 1032999);
    assert(writes.size() == count);
    poll_at(&adc, 1033000);
    assert(writes.size() == count + 1 && writes.back()[0] == 0x06);

    // NACK at reset, short status/data reads, and failed channel start.
    Ads1219State absent = {};
    fail_write = true;
    poll_at(&absent, 0);
    assert(!absent.ready && absent.next_action_us == ADS1219_RETRY_US);
    fail_write = false;
    for (bool short_data : {false, true}) {
        Ads1219State broken = {};
        poll_at(&broken, 0);
        poll_at(&broken, 1000);
        if (short_data) { reads.push_back({0x80}); reads.push_back({0, 0}); }
        else reads.push_back({});
        poll_at(&broken, 2000);
        assert(!broken.ready && broken.phase == AdsPhase::Reset);
    }
    Ads1219State failed_start = {};
    poll_at(&failed_start, 0);
    fail_write = true;
    poll_at(&failed_start, 1000);
    assert(failed_start.phase == AdsPhase::Reset && !failed_start.ready);
    fail_write = false;
    assert(reads.empty());
#else
    poll_at(&adc, 0);
    assert(writes.empty());
#endif

    // Verify TinyUSB's unusual argument order and all four button bits.
    JoystickState primary = {};
    primary.x.filtered = 11; primary.y.filtered = 12;
    primary.yaw.filtered = 13; primary.button.pressed = true;
    adc.ready = true;
    adc.joystick.x.filtered = 21; adc.joystick.y.filtered = 22;
    adc.joystick.yaw.filtered = 23; adc.joystick.button.pressed = true;
    stop.pressed = false;
    send_hid_report(&primary, &adc, &stop);
    assert(axes[0] == 12 && axes[1] == -11 && axes[2] == 13);
#if ADS1219_ENABLED
    assert(axes[3] == 23 && axes[4] == -22 && axes[5] == -21);
    assert(hid_buttons == 3);
#else
    assert(axes[3] == 0 && axes[4] == 0 && axes[5] == 0);
    assert(hid_buttons == 1);
#endif
    adc.ready = false;
    send_hid_report(&primary, &adc, &stop);
    assert(hid_buttons == (ADS1219_ENABLED ? 9u : 1u));
    assert(axes[0] == 12 && axes[1] == -11 && axes[2] == 13);
    assert(axes[3] == 0 && axes[4] == 0 && axes[5] == 0);
    stop.pressed = true;
    send_hid_report(&primary, &adc, &stop);
    assert(axes[0] == 12 && axes[1] == -11 && axes[2] == 13);
    assert(axes[3] == 0 && axes[4] == 0 && axes[5] == 0);
    assert(hid_buttons == (ADS1219_ENABLED ? 13u : 5u));

    // Stop changes only bit 2, for every top-button combination and
    // expansion readiness state. Reports also keep updating while held.
    for (bool ready : {false, true}) {
        adc.ready = ready;
        for (unsigned pressed = 0; pressed < 4; ++pressed) {
            primary.button.pressed = (pressed & 1u) != 0;
            adc.joystick.button.pressed = (pressed & 2u) != 0;
            stop.pressed = false;
            send_hid_report(&primary, &adc, &stop);
            const std::vector<int8_t> before(axes, axes + 6);
            const uint32_t buttons_before = hid_buttons;
            stop.pressed = true;
            send_hid_report(&primary, &adc, &stop);
            assert(std::vector<int8_t>(axes, axes + 6) == before);
            assert(hid_buttons == (buttons_before | 0x04u));
            primary.y.filtered = -12;
            send_hid_report(&primary, &adc, &stop);
            assert(axes[0] == -12); // Not frozen at the pre-stop value.
            primary.y.filtered = 12;
            stop.pressed = false;
            send_hid_report(&primary, &adc, &stop);
            assert(hid_buttons == buttons_before);
            assert(std::vector<int8_t>(axes, axes + 6) == before);
        }
    }

        // Rotation plus ADS-only horizontal reversal; vertical is unchanged.
        // Include center and diagonal travel; twist and buttons stay unchanged.
        const int16_t directions[][4] = {
        {0, -127, -127, 0}, {0, 127, 127, 0},
        {127, 0, 0, -127}, {-127, 0, 0, 127},
        {0, 0, 0, 0}, {127, -127, -127, -127},
        {-127, 127, 127, 127}
        };
        stop.pressed = false;
        adc.ready = true;
        for (const auto &direction : directions) {
        primary.x.filtered = adc.joystick.x.filtered = direction[0];
        primary.y.filtered = adc.joystick.y.filtered = direction[1];
        send_hid_report(&primary, &adc, &stop);
        assert(axes[0] == direction[2] && axes[1] == direction[3]);
        assert(axes[2] == 13);
    #if ADS1219_ENABLED
        assert(axes[4] == -direction[2] && axes[5] == direction[3]);
        assert(axes[3] == 23 && hid_buttons == 3);
    #else
        assert(axes[4] == 0 && axes[5] == 0 && axes[3] == 0);
        assert(hid_buttons == 1);
    #endif
        stop.pressed = true;
        send_hid_report(&primary, &adc, &stop);
        assert(axes[0] == direction[2] && axes[1] == direction[3]);
        assert(axes[2] == 13);
    #if ADS1219_ENABLED
        assert(axes[4] == -direction[2] && axes[5] == direction[3]);
        assert(axes[3] == 23 && hid_buttons == 7);
    #else
        assert(axes[4] == 0 && axes[5] == 0 && axes[3] == 0);
        assert(hid_buttons == 5);
    #endif
        stop.pressed = false;
        }

    // AIN2 -> normalized raw -> calibration -> smoothing -> signed HID Rz.
    // Clamping negative ADC noise to raw zero must still produce negative Rz.
    const uint8_t twist_samples[][3] = {
        {0, 0, 0}, {0x40, 0, 0}, {0x7f, 0xff, 0xff}, {0xff, 0xff, 0xff}
    };
    const int16_t twist_expected[] = {-127, 0, 127, -127};
    for (unsigned i = 0; i < 4; ++i) {
        Ads1219State twist = {};
        twist.pending[ADS1219_X_CHANNEL] = 2048;
        twist.pending[ADS1219_Y_CHANNEL] = 2048;
        twist.pending[ADS1219_BUTTON_CHANNEL] = 4095;
        twist.pending[ADS1219_YAW_CHANNEL] =
            ads1219_normalize(twist_samples[i]);
        for (unsigned sample = 0; sample < 64; ++sample) {
            ads1219_commit(&twist, sample * 10000ull);
        }
        assert(twist.joystick.yaw.calibrated == twist_expected[i]);
        send_hid_report(&primary, &twist, &stop);
#if ADS1219_ENABLED
        assert(axes[3] == twist.joystick.yaw.filtered);
        if (twist_expected[i] < 0) assert(axes[3] < 0);
        else if (twist_expected[i] > 0) assert(axes[3] > 0);
        else assert(axes[3] == 0);
#else
        assert(axes[3] == 0);
#endif
        assert(axes[2] == 13); // Primary twist is independent.
        assert(axes[4] == 0 && axes[5] == 0);
    }

    // Swapping Z/Rz must not invert either twist or couple their values.
    for (int16_t rp_twist : {-127, 0, 127}) {
        for (int16_t ads_twist : {-127, 0, 127}) {
            primary.yaw.filtered = rp_twist;
            adc.joystick.yaw.filtered = ads_twist;
            for (bool ready : {false, true}) {
                adc.ready = ready;
                for (bool active : {false, true}) {
                    stop.pressed = active;
                    send_hid_report(&primary, &adc, &stop);
                    assert(axes[2] == rp_twist);
                    assert(axes[3] ==
                        (ADS1219_ENABLED && ready ? ads_twist : 0));
                }
            }
        }
    }
    return 0;
}
`;

test('host-mocked C++ behavior (enabled and disabled builds)', t => {
    const compiler = process.env.CXX;
    if (!compiler) {
        t.skip('No CXX configured: set an absolute native clang++/g++ path');
        return;
    }
    assert.ok(path.isAbsolute(compiler) && fs.existsSync(compiler),
        'CXX must name an existing absolute compiler path');
    if (process.platform === 'win32') {
        assert.equal(path.extname(compiler).toLowerCase(), '.exe');
    }
    const version = spawnSync(compiler, ['--version'], { encoding: 'utf8' });
    assert.equal(version.status, 0, version.error?.message || version.stderr);
    const temp = fs.mkdtempSync(path.join(os.tmpdir(), 'joystick-test-'));
    try {
        fs.writeFileSync(path.join(temp, 'mocks.h'), mocks);
        for (const name of ['pico/stdlib.h', 'hardware/i2c.h',
            'hardware/adc.h', 'tusb.h']) {
            const target = path.join(temp, name);
            fs.mkdirSync(path.dirname(target), { recursive: true });
            fs.writeFileSync(target, '#include "mocks.h"\n');
        }
        const cpp = path.join(temp, 'test.cpp');
        fs.writeFileSync(cpp, harness);
        for (const enabled of [1, 0]) {
            const exe = path.join(temp, `test-${enabled}` +
                (process.platform === 'win32' ? '.exe' : ''));
            const build = spawnSync(compiler, ['-std=c++17',
                `-DADS1219_ENABLED=${enabled}`, `-DESTOP_ENABLED=${enabled}`,
                '-I', temp, '-I', firmwareDir, cpp, '-o', exe],
            { encoding: 'utf8' });
            assert.equal(build.status, 0,
                build.error?.message || build.stdout + build.stderr);
            const run = spawnSync(exe, [], { encoding: 'utf8' });
            assert.equal(run.status, 0,
                run.error?.message || run.stdout + run.stderr);
        }
    } finally {
        fs.rmSync(temp, { recursive: true, force: true });
    }
});