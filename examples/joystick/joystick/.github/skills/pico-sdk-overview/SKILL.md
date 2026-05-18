---
name: pico-sdk-overview
description: 'Provide a practical overview of the Raspberry Pi Pico SDK and where to find implementation details, API docs, examples, and board-specific configuration. Use for onboarding, architecture orientation, and quickly locating SDK symbols.'
argument-hint: 'What part of the Pico SDK do you want to understand?'
user-invocable: true
disable-model-invocation: false
---

# Pico SDK Overview

Provide a concise, practical map of the Pico SDK and point to the best source for details.

## When to Use
- You need an orientation to Pico SDK layers and modules.
- You need to find where an API is declared or implemented.
- You need quick pointers to examples, board config, or CMake integration.
- You want "where to look next" for a specific peripheral (GPIO, ADC, PWM, UART, PIO, DMA, etc.).

## Inputs
- User question or area of interest (for example: `ADC`, `PIO`, `pico_time`, `build system`).
- Optional target family or board context (`rp2040`, `rp2350`, specific board macro).

## Procedure
1. Identify the local SDK path in this workspace:
   - Primary: `build/pico-sdk/`
   - Also consider project-level files: `pico_sdk_import.cmake`, `CMakeLists.txt`
2. Give a 6-part SDK map:
   - Build integration (CMake + import)
   - Core runtime (`pico_stdlib`, time/sync/utility)
   - Hardware abstraction (`hardware_*` modules)
   - Architecture/family areas (`rp2_common`, `rp2040`, `rp2350`)
   - Boot/flash/reset support
   - Examples and docs
3. For each requested area, provide:
   - Header location(s)
   - Likely implementation/source location(s)
   - One "best next file" to open first
   - Any gotchas (clocking, IRQ, DMA channel usage, pin muxing, etc.)
4. Point to local and upstream details using [Pico SDK detail map](./references/pico-sdk-detail-map.md).
5. End with a short action list tailored to the request (for example, 2-4 files to open next).

## Output Format
- **Overview (short):** 4-8 bullets of architecture-level context.
- **Where details live:** concrete paths and doc links.
- **Next files to open:** prioritized mini list.
- **Optional follow-up:** suggest deeper drill-down (call graph, symbol trace, example comparison).

## Quality Checks
- Paths and module names are specific (not generic hand-waving).
- Distinguish declaration vs implementation location when possible.
- Include both local-workspace and official documentation pointers.
- Keep explanations concise unless user asks for deep dive.

## References
- [Pico SDK detail map](./references/pico-sdk-detail-map.md)
