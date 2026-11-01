# QEM-01 Architecture

## 1. System Overview

QEM-01 is a quadrature encoder monitoring design. It accepts two incremental encoder signals, synchronizes them to the system clock, decodes their state transitions, and maintains position, speed, and error information.

The RTL is organized into a reusable encoder-processing core, a register bank, a top-level integration module, and a TinyTapeout-compatible wrapper.

## 2. Signal Flow

```text
Encoder A/B
    |
    v
Input Synchronizer
    |
    v
Quadrature Decoder
    |             |
 count_up     count_down
    |             |
    +------+------+
           |
     +-----+------+
     |            |
     v            v
Position       Speed
Counter        Counter
     |            |
     +------+-----+
            |
            v
       Encoder Core
            |
            v
       Register Bank
            |
            v
          QEM Top
            |
            v
   TinyTapeout Wrapper
```

## 3. RTL Module Responsibilities

### `input_synchronizer.v`

Synchronizes the asynchronous encoder inputs to the system clock using two flip-flop stages for each input.

This reduces the risk of metastability propagating into the synchronous decoding logic. It does not implement a separate glitch filter.

### `quadrature_decoder.v`

Compares the current synchronized two-bit encoder state with the previous state.

Forward sequence:

```text
00 -> 01 -> 11 -> 10 -> 00
```

Reverse sequence:

```text
00 -> 10 -> 11 -> 01 -> 00
```

Each valid transition generates a one-cycle `count_up` or `count_down` pulse. A transition in which both encoder bits change is treated as invalid and produces an `invalid_transition` indication.

The first synchronized state after reset is captured as the initial state; it does not generate a position count.

### `encoder_frontend.v`

Connects the input synchronizer to the quadrature decoder. It provides the synchronized and decoded encoder event signals to the rest of the design.

### `position_counter.v`

Maintains a 32-bit signed position value.

- Increments on `count_up`.
- Decrements on `count_down`.
- Saturates at the maximum and minimum signed 32-bit values.
- Sets a sticky overflow indication when a limit is exceeded.
- Supports clearing the position and overflow state.

The counter can move back inward after reaching a limit; the overflow indication remains set until cleared.

### `speed_counter.v`

Counts valid encoder transitions over a fixed measurement window.

With a 50 MHz clock and a 500,000-cycle window:

- Measurement interval: 10 ms
- Window timer width: 19 bits
- Speed result width: 16 bits

The result represents the number of decoded transitions in the preceding measurement window. It is not directly an RPM value.

### `encoder_core.v`

Integrates the encoder frontend, position counter, and speed counter. It also maintains the sticky invalid-transition error status.

The error status is cleared by reset or the error-clear control. A newly detected invalid transition sets the status.

### `qem_register_bank.v`

Provides the host-visible register map, snapshot capture, and clear controls.

The position and speed values are copied into snapshot registers when the snapshot command is issued. The host can then read the bytes without the underlying live counters changing the value halfway through a multi-byte read.

### `qem_top.v`

Connects the encoder core and register bank and maps them to the top-level data, address, and control signals.

### `tt_um_qem01.v`

Provides the TinyTapeout-compatible wrapper around `qem_top`.

## 4. Register Map

The register address is three bits wide and the read data is eight bits wide.

| Address | Read data | Write function |
|---|---|---|
| `0x0` | Position snapshot [7:0] | — |
| `0x1` | Position snapshot [15:8] | — |
| `0x2` | Position snapshot [23:16] | — |
| `0x3` | Position snapshot [31:24] | — |
| `0x4` | Speed snapshot [7:0] | — |
| `0x5` | Speed snapshot [15:8] | — |
| `0x6` | Status bits | — |
| `0x7` | Constant read value | Control commands |

Status register, address `0x6`:

| Bit | Meaning |
|---|---|
| 0 | Sticky invalid-transition error status |
| 1 | Position overflow status |
| 2 | Invalid-transition indication |

Control register, address `0x7`:

| Write-data bit | Function |
|---|---|
| 0 | Capture position and speed snapshots |
| 1 | Clear position and position overflow |
| 2 | Clear sticky error status |

The control actions are decoded from a write to address `0x7`.

## 5. Top-Level Interface Mapping

| Signal | Function |
|---|---|
| `clk` | System clock |
| `rst_n` | Active-low asynchronous reset |
| `ui_in[7:0]` | Register write data |
| `uo_out[7:0]` | Register read data |
| `uio_in[0]` | Encoder A |
| `uio_in[1]` | Encoder B |
| `uio_in[4:2]` | Register address |
| `uio_in[5]` | Register write strobe |
| `uio_in[7:6]` | Reserved |
| `uio_out[7:0]` | Unused; driven low |
| `uio_oe[7:0]` | Unused; driven low |

The interface assumes that the external controller is synchronous to the 50 MHz system clock and provides a one-cycle write strobe. The write strobe is not independently synchronized or edge-detected inside the design.

## 6. Measurement Interpretation

The speed register reports decoded encoder transitions per 10 ms.

To convert this result to RPM, the encoder's pulses-per-revolution specification is required. The conversion must account for the fact that QEM-01 uses 4× quadrature decoding.

For an encoder specified in cycles per channel per revolution (PPR), and a measured count `C` over a 10 ms window:

```text
RPM = C * 6000 / (4 * PPR)
```

This formula assumes the PPR specification refers to cycles per channel per revolution and that each quadrature edge is counted.

## 7. Design Notes

- Encoder inputs are synchronized through two flip-flop stages.
- No separate digital glitch filter is implemented.
- Position is a signed, saturating 32-bit quantity.
- Overflow and invalid-transition status are sticky until cleared.
- Snapshot registers provide coherent multi-byte readback.
- Speed is reported as transitions per measurement window, not as a calibrated physical speed.
