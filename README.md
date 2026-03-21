# FPGA Dark Channel Dehazing

A hardware implementation of the Dark Channel Prior (DCP) image dehazing algorithm on the Zybo Zynq-7000 FPGA development board.

---

## Project Overview

This project implements a real-time image dehazing pipeline on an FPGA using the Dark Channel Prior algorithm. The design processes 512×512 RGB images streamed via AXI DMA from the ARM Cortex-A9 processor to the FPGA fabric, where the dehazing pipeline runs, and streams the dehazed output back to DDR memory.

---

## Algorithm Description

The Dark Channel Prior (DCP) algorithm, proposed by He et al., exploits the observation that most local patches in haze-free outdoor images contain pixels with very low intensity in at least one color channel. This "dark channel" is used to estimate the transmission map and atmospheric light, which are then used to recover the scene radiance.

### Standard DCP Pipeline
1. Compute the dark channel (minimum over a local patch and color channels)
2. Estimate atmospheric light from the brightest region of the dark channel
3. Estimate the transmission map
4. Recover the scene radiance using the transmission map and atmospheric light

### Deviations from Standard DCP
- **Single-pass approximation** — atmospheric light is computed incrementally as pixels stream in, rather than from the complete image
- **No guided filter refinement** — the raw transmission map is used directly without soft matting
- **Fixed 7×7 patch size** — no adaptive patch sizing
- **Fixed-point arithmetic** — integer arithmetic instead of floating point
- **Streaming architecture** — pixels processed sequentially in raster scan order

---

## Hardware Architecture

### System Overview
```
PS (ARM Cortex-A9)                    PL (FPGA Fabric)
+------------------+                +----------------------+
|                  |                |                      |
|  Input Image     |   AXI DMA      |   Width Converter    |
|  (DDR Memory)  --|-- MM2S ------->|-- (32→24 bit) -----> |
|                  |                |                      |
|                  |                |   dcp_axi_wrapper    |
|                  |                |   +----------------+ |
|                  |                |   |   dcp_top      | |
|                  |                |   |  rgb_min       | |
|                  |                |   |  lineBuffer    | |
|                  |                |   |  minFilter     | |
|                  |                |   |  ambientLight  | |
|                  |                |   |  transmission  | |
|                  |                |   |  pixelDelay    | |
|                  |                |   |  sceneRadiance | |
|                  |                |   +----------------+ |
|                  |                |                      |
|  Output Image  <-|-- S2MM <-------|-- Width Converter    |
|  (DDR Memory)    |   AXI DMA      |   (24→32 bit)        |
+------------------+                +----------------------+
```

### Module Descriptions

| Module | Description |
|--------|-------------|
| `rgb_min` | Computes minimum of R, G, B channels per pixel |
| `lineBufferArray` | Stores 7 rows of 512 pixels for 7×7 sliding window |
| `minFilter` | Computes minimum over 7×7 patch (dark channel) |
| `ambientLight` | Incrementally estimates atmospheric light A |
| `transmission_estimator` | Computes transmission map t = 1 - (dark_channel / A) |
| `pixelDelayBuffer` | Delays original pixel to align with pipeline output |
| `scene_radiance` | Recovers dehazed pixel using J = (I - A) / t + A |
| `dcp_top` | Top-level module wiring all submodules |
| `dcp_axi_wrapper` | AXI4-Stream wrapper for PS-PL communication |

---

## Hardware Specifications

**Target Board:** Digilent Zybo Zynq-7000 (XC7Z010-1CLG400C)

**Resource Utilization:**

| Resource | Used | Available | Utilization |
|----------|------|-----------|-------------|
| LUTs | ~4,000 | 17,600 | ~23% |
| Flip Flops | ~4,700 | 35,200 | ~13% |
| BRAMs | ~28.5 | 60 | ~47% |
| DSPs | 4 | 80 | 5% |

**Performance:**
- Clock frequency: 25 MHz
- Throughput: 1 pixel/cycle
- Pipeline latency: ~3,584 clock cycles
- Total processing time (512×512): ~10.5 ms

---

## System Requirements

### Tools
- Xilinx Vivado 2025.2
- Vitis Unified IDE 2025.2
- Python 3.x with Pillow and NumPy

### Hardware
- Digilent Zybo Zynq-7000 development board
- Micro USB cable (PROG/UART port)

---

## Results

Input and output images are stored as PNG files. The dehazed output shows improved visibility and contrast compared to the hazy input, with some dark patch artifacts in smooth regions due to the single-pass approximation of the atmospheric light estimation.

---

## Possible Enhancements

- Two-pass implementation for accurate atmospheric light estimation
- Guided filter refinement for transmission map
- Higher clock frequency through pipeline optimization
- Real-time HDMI video dehazing
- Variable image resolution via AXI control registers

---

## References

- He, K., Sun, J., & Tang, X. (2011). Single image haze removal using dark channel prior. IEEE Transactions on Pattern Analysis and Machine Intelligence.

---

## Collaborators

- Shresh Parti
- Akhilesh
