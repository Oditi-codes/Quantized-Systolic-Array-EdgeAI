### Edge AI Hardware Accelerator: Master Replication Blueprint 📑

This document serves as a complete future reference manual for rebuilding, scaling, or reproducing this **Hardware-Software Co-Design Inference System**. It preserves the step-by-step design framework, toolchain setup, configuration choices, and debugging patterns established during development. 

### 🏗️ 1. What We Created (The Complete System Stack)

We built a cycle-accurate, hardware-accelerated **Deep Learning Inference Layer** structured across a clean 3-layer workspace hierarchy: 

text

       [ 1. SOFTWARE BRAIN ]      ──>      [ 2. HARDWARE GRID ]      ──>      [ 3. ACTIVATION FILTER ]
    PyTorch INT8 Quantization             2x2 Systolic Array ALUs              Zero-Latency ReLU Block
  Generates Golden Target Matrix        Staggered Data Wavefront Data          Truncates Negative Values

Use code with caution.

1. **ai_model/train_and_extract.py**: A PyTorch script that takes standard neural decimal arrays (Float32), performs uniform scalar scaling, and clips them into **Signed 8-bit integers (INT8)**. It outputs the random-seeded matrix values and prints the mathematical "Golden Truth".
2. **rtl/pe.v**: The Processing Element cell. The hardware atom of the accelerator. It houses a signed 8-bit multiplier linked to a 16-bit sequential accumulator register.
3. **rtl/systolic_array_2x2.v**: A grid layout connecting four PEs together using local row and column data-routing paths.
4. **rtl/relu_2x2.v**: A combinational multiplexer circuit that checks the sign bit of incoming calculations. It sets negative numbers to 0 and passes positive numbers through unchanged.
5. **rtl/deep_nn_layer.v**: The top-level master chip block wrapper that connects the array outputs directly into the ReLU inputs.
6. **sim/systolic_tb.v**: A pinless laboratory testbench rig that drives the virtual system clock and feeds data using an offset timing schedule (**Wavefront Scheduling**).

### 🛠️ 2. The Toolchain Environment Setup Recipe

To reproduce this runtime test workbench on any fresh Windows development machine, execute this sequence: 

1. **VS Code Environment Extensions:** Install the **Verilog-HDL/SystemVerilog** extension (by *Masahiro Hiramori*) for hardware syntax highlighting.
2. **Python Environment Isolation:** Open the terminal in your project directory and configure a virtual environment bubble: 

powershell

python -m venv ai_env
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope Process
.\ai_env\Scripts\Activate.ps1
pip install torch

Use code with caution.
3. **Select the Workspace Interpreter:** Open the Command Palette (Ctrl+Shift+P), select **Python: Select Interpreter**, and choose your new local ai_env instance to clear code-checker warnings.
4. **Install the Verilog Toolchain Compiler:** Run Windows Package Manager via a separate administrative terminal to download the Icarus simulator and waveform browser: 

powershell

winget install -e --id IcarusVerilog.IcarusVerilog

Use code with caution.

*(Note: Fully restart VS Code after the installation finishes to reload system command paths).*

### 🚀 3. The Re-Compilation & Verification Routine

Whenever you update your hardware module layouts or change weights inside Python, run this terminal verification pipeline: 

powershell

# Step 1: Run the PyTorch quantization script to generate values
python ai_model/train_and_extract.py

# Step 2: Compile the structural RTL modules into a simulation model
& "C:\iverilog\bin\iverilog.exe" -o sim/systolic_sim.vvp rtl/pe.v rtl/systolic_array_2x2.v rtl/relu_2x2.v rtl/deep_nn_layer.v sim/systolic_tb.v

# Step 3: Execute the cycle-accurate runtime simulation engine
& "C:\iverilog\bin\vvp.exe" sim/systolic_sim.vvp

# Step 4: Open the waveform database inside GTKWave for visual analysis
& "C:\iverilog\bin\gtkwave.exe" sim/systolic_sim.vcd

Use code with caution.

### ⚠️ 4. Crucial Engineering Lessons Learned (The Interview Survival Kit)

When reproducing this architecture in the future, watch out for these four critical pitfalls that we debugged and resolved: 

### 1. The Variable-Type Signed Trap

* **The Error:** Verilog interprets all numbers as unsigned magnitude indices by default. Sending negative values like -8'd69 over a default wire converts it into a large positive number (187), causing math outputs to balloon out of bounds.
* **The Fix:** Every input, output, wire, register, and verification terminal wire must be explicitly marked with the **signed** keyword. In addition, conditional operators must target a signed zero constant format (16'sd0).

### 2. The Wavefront Staggering Rule

* **The Constraint:** Data elements take exactly 1 clock cycle to travel between neighboring cells in a pipelined array. Pumping all matrix elements in simultaneously causes data collisions.
* **The Fix:** Row 1 of Matrix A and Column 1 of Matrix B must be delayed by exactly **1 clock period (#10 delay intervals)** relative to Row 0 and Column 0. This ensures inputs meet in perfect mathematical alignment at the internal multipliers.

### 3. Bit-Width Growth Math

* **The Constraint:** Multiplying two 8-bit integers results in a number up to 16 bits wide.
* **The Fix:** Sizing accumulator wires to 16-bit signed prevents data clipping during multiplication and accumulation steps, avoiding the integer overflow issues common in standard software frameworks.

### 4. Invisible Characters (Clipboard NBSP Errors)

* **The Error:** Copying code from browsers or text blocks can introduce a hidden character called a **Non-Breaking Space (NBSP)** right before semicolons, causing the hardware compiler to throw a cryptic syntax error / I give up. alert.
* **The Fix:** If a line looks visually perfect but fails to compile, clear the spaces and rewrite the symbols directly inside the text editor using your keyboard.