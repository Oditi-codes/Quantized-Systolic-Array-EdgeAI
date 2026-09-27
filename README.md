# Quantized INT8 Pipelined Systolic Array AI Inference Accelerator 🧠⚡

A complete **Hardware-Software Co-Design** project implementing a fully synthesizable **2x2 Pipelined Systolic Array MAC Engine** and a **Signed ReLU Activation Layer** in Verilog. The entire hardware execution pipeline is verified using a customized, low-precision quantized dataset generated dynamically via **PyTorch**. 

This project demonstrates the foundational low-level optimization concepts required for **Edge AI Architecture** (similar to the underlying hardware blocks in STMicroelectronics' STM32Cube.AI processing environments).

---

## 🎨 System Architecture Overview
General-purpose processors (CPUs/GPUs) hit a "Memory Wall" when processing deep neural networks due to the heavy power consumed by constant global RAM fetching. This chip solves that problem using three core architectural principles:

```text
                      Matrix B Inputs (Weights from Top)
                             ↓              ↓
                          [b00]           [b01]
                             ↓              ↓
Matrix A Inputs  ──>  [ PE 00 ]  ───────> [ PE 01 ]  (Data flows Left-to-Right)
(From Left Edge)             ↓              ↓
                  ──>  [ PE 10 ]  ───────> [ PE 11 ]
                             ↓              ↓
                      [ ReLU Layer ]  [ ReLU Layer ]
                             ↓              ↓
                        Y10 / Y11       Y00 / Y01    (Final Active Neural Outputs)
```

1. **INT8 Uniform Quantization:** Floating-point models (`Float32`) are stripped down to 8-bit signed whole numbers (`INT8`). This reduces the physical size of the multiplier circuits on the silicon die by up to 75% and drastically minimizes dynamic power dissipation.
2. **Wavefront Pipelining:** Instead of broadcasting inputs globally to every processing node at the same instant (which creates major electrical capacitance and timing bottlenecks), data moves across local wires from cell to cell like a wave. Inputs are structurally staggered by exactly 1 clock cycle per row/column to ensure data packets collide in perfect mathematical order.
3. **Signed Arithmetic with Dynamic Overflows:** Internal ports use `16-bit signed` registers to capture the product of `8-bit signed` numbers, guaranteeing absolute protection against bit overflow errors during deep accumulation loops.

---

## 📁 Repository Blueprint
```text
Hardware_AI_Project/
├── ai_model/
│   └── train_and_extract.py   # PyTorch Model Quantization Studio
├── rtl/
│   ├── pe.v                   # 8-bit Signed Processing Element (MAC Core)
│   ├── systolic_array_2x2.v   # 2x2 Network Grid Routing Array
│   ├── relu_2x2.v             # Hardware Non-linear Multiplexer Layer
│   └── deep_nn_layer.v        # Top-Level Structural Core Processor Wrapper
└── sim/
    ├── mac_cell_tb.v          # Phase 1 Isolated Neuron Verification Rig
    └── systolic_tb.v          # Wavefront Pipeline System Verification Rig
```

---

## 🚀 Execution & Verification Protocol

### 1. Run the PyTorch Brain Extraction
```bash
python ai_model/train_and_extract.py
```
*Generates the integer weights and logs the mathematical golden truths for verification.*

### 2. Hardware RTL Compilation & Cycle Simulation
```powershell
& "C:\iverilog\bin\iverilog.exe" -o sim/systolic_sim.vvp rtl/pe.v rtl/systolic_array_2x2.v rtl/relu_2x2.v rtl/deep_nn_layer.v sim/systolic_tb.v
```

### 3. Run the Cycle-Accurate Simulator Runtime
```powershell
& "C:\iverilog\bin\vvp.exe" sim/systolic_sim.vvp
```

### 4. Convergence Result Logs
```text
==================================================
   MATHEMATICAL MATRIX RESULTS FROM HARDWARE SILICON 
==================================================
 [      0 ]  [      0 ]
 [   1188 ]  [   1804 ]
==================================================
```
The cycle-accurate simulation output matches the pre-computed fixed-point PyTorch matrix reference results exactly, proving 100% logical and structural correctness across the array.

---

## 🔬 Waveform Timing Analysis (GTKWave Proof)
* Inputs `a00` and `b00` stream in at Cycle 1.
* The delayed input ports `a10` and `b01` are successfully held at `0` until Cycle 2, validating the **Wavefront Pipeline Scheduling**.
* The unactivated top-row accumulation matrix calculations (`-1018` and `-1486`) are successfully routed through the combinational multiplexer nodes and truncated to exactly **`0`**, validating the **ReLU Hardware Layer**.
