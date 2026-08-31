# FPGA MNIST Digit Classifier

A hardware neural network accelerator implemented in Verilog, running entirely on FPGA fabric, that classifies 28×28 handwritten digit images (MNIST-style) in real time. The design implements a small fully-connected feedforward network — two dense layers followed by an argmax classifier — with results displayed live on a 7-segment HEX display.

## Overview

This project takes a pre-trained neural network (trained offline) and implements its **inference pass** directly in digital logic, with no CPU, no soft processor, and no software runtime involved. All weights and biases are loaded into on-chip memory at configuration time via `$readmemh`, and the entire forward pass — matrix multiplication, bias addition, ReLU activation, quantization, and classification — runs as a synchronous hardware state machine clocked at 50 MHz.

**Network architecture:**

```
Input (784 px, 28×28 grayscale)
   -> Fully Connected Layer 1 (784 -> 32) + ReLU + Quantization
   -> Fully Connected Layer 2 (32 -> 10)
   -> Argmax (10 -> 1 predicted digit class)
   -> 7-segment HEX display
```

## Hardware / Toolchain

- **Target platform:** Intel/Altera DE-series FPGA board (e.g. DE10-Lite / DE2), 50 MHz onboard clock (`CLOCK_50`)
- **Toolchain:** Quartus Prime (synthesis, programming, SignalTap for hardware debug)
- **Language:** Verilog

## Modules

| Module | Description |
|---|---|
| `top` | Top-level module. Instantiates both layers and the argmax classifier, wires up switches, LEDs, and the HEX display, and tracks total clock cycles for benchmarking. |
| `firstlayer` | Computes the first fully-connected layer (784 → 32), applies ReLU, and quantizes the result down to 8-bit outputs for the next stage. |
| `secondlayer` | Computes the second fully-connected layer (32 → 10) from the first layer's output. |
| `argmax` | Selects the index of the largest of the 10 output values — the predicted digit class. |

Each layer is implemented as a synchronous finite state machine (`IDLE → ROW → COLUMN → RELU/COMPLETE → ...`) that walks through one multiply-accumulate (MAC) operation per pixel, per neuron, per clock cycle.

## I/O

- **`SW[0]`** — Start switch. Triggers the pipeline to begin inference.
- **`HEX2`** — 7-segment display showing the predicted digit (0–9).
- **`LEDR`** — Status/debug LEDs, including a live view of the internal cycle counter.

## Performance

The design includes an onboard cycle counter (`cycle_count`) that measures how many `CLOCK_50` cycles elapse between the start of inference and completion of the second layer, for benchmarking purposes.

- Clock: 50 MHz (20 ns per cycle)
- Current measured latency: **~11,949 cycles ≈ 239 µs** per full inference pass (first layer + second layer)

This reflects a fully **serial** implementation — one MAC operation per clock cycle. Because FPGAs excel at parallel execution, a natural next step is unrolling the per-neuron / per-pixel loops into multiple concurrent MAC units, which would reduce latency roughly in proportion to the degree of parallelism introduced.

## Data / Weights

Weights, biases, and test input images are preloaded into block memory from hex files at synthesis/simulation time using `$readmemh`:

- `weightsFirstLayer.hex`, `biasesFirstLayer.hex`
- `weightsSecondLayer.hex`, `biasesSecondLayer.hex`
- Test digit images (e.g. `digit_9.hex`) — 784 bytes each, one hex value per line, representing a flattened 28×28 grayscale image

## Known Limitations / Future Work

- **Fully serial MAC pipeline** — no parallelism across neurons or pixels yet; this is the main lever for reducing latency.
- **Start signal is level-triggered**, not edge-triggered — the pipeline currently begins as soon as `SW[0]` is high rather than on a clean off→on transition, which is worth revisiting for cleaner control from a physical switch.
- Potential future additions: pipelining across layers, parallel MAC arrays, support for convolutional layers, and on-device training data feedback via SignalTap capture.


