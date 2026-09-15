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
    assert.deepEqual(channels, [0, 1, 2, 3]);
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

    // Analog hysteresis and 25ms debounce operate on fresh samples only.
    Ads1219State button = {};
    button.pending[3] = 4095;
    ads1219_commit(&button, 0);
    button.pending[3] = 1024;
    ads1219_commit(&button, 1000);
    assert(!button.joystick.button.pressed);
    button.pending[3] = 2000; // hysteresis retains pressed candidate
    ads1219_commit(&button, 25999);
    assert(!button.joystick.button.pressed);
    ads1219_commit(&button, 26000);
    assert(button.joystick.button.pressed);
    button.pending[3] = 3072;
    ads1219_commit(&button, 27000);
    button.pending[3] = 0; // bounce cancels release
    ads1219_commit(&button, 30000);
    button.pending[3] = 4095;
    ads1219_commit(&button, 32000);
    ads1219_commit(&button, 56999);
    assert(button.joystick.button.pressed);
    ads1219_commit(&button, 57000);
    assert(!button.joystick.button.pressed);

    ButtonState stop = {};
    clock_us = 0;
    init_estop(&stop);
#if ESTOP_ENABLED
    assert(stop.pressed); // boot stopped even with a closed contact
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
    assert(axes[0] == 11 && axes[1] == 12 && axes[3] == 13);
#if ADS1219_ENABLED
    assert(axes[2] == 23 && axes[4] == 21 && axes[5] == 22);
    assert(hid_buttons == 3);
#else
    assert(axes[2] == 0 && axes[4] == 0 && axes[5] == 0);
    assert(hid_buttons == 1);
#endif
    adc.ready = false;
    send_hid_report(&primary, &adc, &stop);
    assert(hid_buttons == (ADS1219_ENABLED ? 9u : 1u));
    assert(axes[2] == 0 && axes[4] == 0 && axes[5] == 0);
    stop.pressed = true;
    send_hid_report(&primary, &adc, &stop);
    for (int8_t value : axes) assert(value == 0);
    assert(hid_buttons == (ADS1219_ENABLED ? 12u : 4u));
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