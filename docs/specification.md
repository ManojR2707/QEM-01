# QEM-01: Quadrature Encoder Position and Speed Monitor

## Application
Digital position and speed monitoring for incremental rotary encoders.

## System specifications
- System clock: 50 MHz
- Reset: Active-low asynchronous
- Encoder inputs: A and B
- Encoder type: Incremental quadrature
- Decoding: 4x
- Target maximum input frequency: 1 MHz per channel

## Position measurement
- 32-bit signed position counter
- Increment for forward rotation
- Decrement for reverse rotation
- Position clear functionality
- Snapshot mechanism for consistent readback

## Speed measurement
- Measurement window: 10 ms
- 16-bit count per measurement window
- Capture and hold the latest measurement

## Error detection
- Detect illegal quadrature transitions
- Sticky error flag
- Error clear functionality

## External interface
- 8-bit readback data bus
- 3-bit register selection
- Read enable
- Control inputs

## Implementation tools
- Verilog
- Icarus Verilog
- GTKWave
- Yosys
- SKY130HD
- OpenROAD
- OpenSTA
- KLayout
