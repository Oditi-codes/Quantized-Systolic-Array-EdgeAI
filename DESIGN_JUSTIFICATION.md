# Architectural Design Choices & Technical Defense Document

When interviewing with the **STMicroelectronics Edge AI team**, you must be able to justify *why* every line of hardware was constructed this way. This document details the specific architectural decisions made in this project.

---

## 1. Why Did We Use a Systolic Array Instead of a Standard MAC Unit?
* **The Problem:** In a traditional Von Neumann processor architecture, the CPU must fetch an input from memory, fetch a weight from memory, send them to a multiplier, and write the result back to a register. This creates a severe **Memory Bottleneck** that slows down neural network processing.
* **Our Solution:** The Systolic Array architecture features **high data reuse**. Once an input integer enters `PE00`, it is used for a calculation and then passed *directly* to its right-hand neighbor (`PE01`) through local copper wires without ever going back to primary memory. This massively scales up throughput while lowering memory power draw.

---

## 2. Why Did We Choose INT8 Uniform Quantization?
* **The Multiplier Area Cost:** In hardware design, physical space equals cost and thermal dissipation. A `Float32` multiplier requires complex scientific notation tracking logic, consuming a large number of silicon gates. An `INT8` signed multiplier operates on simple two's complement integers, which takes up a fraction of the physical area on a silicon die.
* **Power Savings:** Processing integers requires significantly less power than floating-point math, which is critical for battery-powered Edge AI devices like the STM32 microcontrollers.

---

## 3. How Does the Wavefront Pipeline Scheduling Prevent Structural Hazards?
* If Matrix Inputs A and B were pumped into all cells at the exact same clock tick, the data streams would collide out of order because it takes exactly 1 clock edge for data to hop between neighboring Processing Elements.
* By introducing a **1-cycle delay** to Row 1 (`a10`) and Column 1 (`b01`), we match the physical travel time of data hopping across the chip. The data wavefront ripples diagonally from the top-left corner down to the bottom-right corner, ensuring calculations remain perfectly synchronized.

---

## 4. Why Use Combinational Multiplexers for the ReLU Layer?
* We designed the ReLU module using pure **Combinational Logic** (ternary operators): `assign out_r00 = (in_c00 < 16'sd0) ? 16'sd0 : in_c00;`
* **Justification:** Adding registers to the ReLU block would introduce an extra clock cycle of latency to the output path. Since checking the sign bit of a number happens almost instantaneously at the wire level, keeping it combinational ensures zero-latency truncation, saving physical flip-flop registers.

---

## 5. Why Declare Variables as `signed` Across Every Single Layer?
* By default, Verilog interprets numbers as unsigned binary magnitudes. If a number like `-69` is sent over an unsigned bus, the hardware reads it as `256 - 69 = 187`. 
* By explicitly declaring `input signed [7:0]`, we instruct the compiler to build **Two's Complement Arithmetic Logic Units (ALUs)**. This ensures that the sign bit (the highest bit) is correctly preserved during multiplications and additions, maintaining mathematical parity with PyTorch.
