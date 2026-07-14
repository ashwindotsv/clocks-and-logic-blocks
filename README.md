# clocks-and-logic-blocks

"In digital design, every bit matters!"
I am Ashwin.I create Verilog designs for FPGAs, focusing on clean RTL and thorough verification.

# Digital Design & FPGA Projects

A collection of my Digital Design, RTL Design, FPGA, and Computer Vision acceleration projects built using Verilog HDL, SystemVerilog, Xilinx Vivado, and Python.

The goal of this repository is to document my journey toward RTL Design, Design Verification, FPGA Development, and ASIC Design.

---

## Repository Structure

```
.
├── ADDERs and MULTIPLIERs
├── AV_Accelerator_Pipeline
├── CNN_inference
├── FIFO
├── FSM
├── Image_Convolution
└── Memory
```

---

## Projects

### Arithmetic Circuits

Implementation of commonly used arithmetic building blocks.

**Modules**

- Full Adder
- Ripple Carry Adder
- Binary Multiplier
- N-bit Multiplier
- Multiply-Accumulate (MAC)

Topics:
- Combinational Logic
- Arithmetic Circuits
- Parameterized Design
- Testbench Development

---

### AV Accelerator Pipeline

RTL implementation of hardware blocks required for an FPGA-based Autonomous Driving Accelerator.

Current modules include:

- Line Buffer
- Window Generator
- Processing Element
- MAC Unit
- PE FSM
- 1×3 Systolic Array
- 3×3 Systolic Array

Topics:
- Image Processing
- FPGA Acceleration
- CNN Hardware
- Systolic Arrays
- Streaming Architectures

---

### CNN Inference

Python utilities for preparing datasets and labels for CNN training.

Includes:

- Dataset preprocessing
- Label generation
- Mask verification
- Dataset validation
- Category checking

---

### FIFO

Implementation of FIFO memories.

Projects:

- Synchronous FIFO
- Asynchronous FIFO (Work in Progress)

Topics:

- Clock Domain Crossing
- Gray Code
- FIFO Control Logic

---

### Finite State Machines (FSM)

RTL implementations of classic FSM designs.

Projects:

- Traffic Light Controller
- Vending Machine Controller

Topics:

- Moore FSM
- Mealy FSM
- Sequential Logic

---

### Image Convolution

RTL implementations of image-processing hardware.

Includes:

- 3×3 Image Convolution
- Signed Convolution
- Parallel Systolic Array
- Pipelined Systolic Array
- Python verification scripts

Topics:

- Digital Image Processing
- MAC Arrays
- FPGA Acceleration

---

### Memory

Memory-related digital designs.

Projects:

- Dual Port RAM
- Round Robin Arbiter

Topics:

- Arbitration
- Memory Architecture
- Shared Resources

---

## Folder Organization

Each project follows a common directory structure.

```
Project/
│
├── docs/
├── images/
├── rtl/
├── tb/
├── waveform/
├── xdc/
└── README.md
```

| Folder | Description |
|---------|-------------|
| rtl | Verilog/SystemVerilog source files |
| tb | Testbenches |
| waveform | Simulation waveforms |
| images | Diagrams and screenshots |
| docs | Notes and documentation |
| xdc | FPGA constraint files |

---

## Tools Used

- Verilog HDL
- SystemVerilog
- Xilinx Vivado
- AMD Vivado Simulator
- Python
- OpenCV
- Git
- GitHub

---

## Hardware Platforms

Development and testing are performed on multiple FPGA platforms:

- **Boolean FPGA Board**
  - AMD/Xilinx Spartan-7 FPGA
  - Used for RTL design, digital logic, arithmetic circuits, FSMs, memories, FIFOs, and FPGA fundamentals. :contentReference[oaicite:0]{index=0}

- **PYNQ-Z2**
  - AMD/Xilinx Zynq-7000 XC7Z020 SoC
  - Used for FPGA acceleration, embedded systems, hardware/software co-design, and computer vision applications.

---

## Tools & Technologies

### Hardware Description Languages
- Verilog HDL
- SystemVerilog

### FPGA Tools
- AMD Vivado
- Vivado Simulator
- Vitis (Learning)

### Programming
- Python
- OpenCV
-Tensforflow (CNN)

### Version Control
- Git
- GitHub
---

## Current Focus

- RTL Design
- FPGA Design
- Design Verification
- Computer Architecture
- Memory Subsystems
- Computer Vision Acceleration
- CNN Hardware Acceleration
- Systolic Arrays
- Embedded FPGA Systems (Zynq)

---

## Future Additions

- UART
- SPI
- I²C
- AXI Lite
- AXI Stream
- DMA
- VGA Controller
- HDMI Pipeline
- DDR Interface
- RISC-V Processor
- Cache Memory
- Branch Predictor
- CNN Accelerator
- UVM Verification Environment

---

## 📫 Connect
- 📧 Email: nayakashwin2006@gmail.com
- 💼 LinkedIn: www.linkedin.com/in/ashwin-nayak-917947367

---

## License

This repository is intended for educational and learning purposes.

Feel free to explore the projects and suggest improvements.

---

**Author**

Ashwin Nayak

Electronics and Communication Engineering

Interested in RTL Design • FPGA • ASIC Design • Design Verification • Computer Vision Hardware