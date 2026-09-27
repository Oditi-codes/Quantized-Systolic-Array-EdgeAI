### Master Terminal Command Dictionary & Reference Manual 💻

This document acts as a complete guide to every command executed in the terminal during the design, compilation, and verification of the Hardware AI accelerator. 

### 🐍 1. Python & Environment Isolation Commands

### Command: python -m venv ai_env

* **What it means:** Calls the Python executable (python) and executes its built-in virtual environment module (-m venv), creating a new localized container directory named ai_env.
* **Why we ran it:** To prevent software version conflicts. This creates an isolated "bubble" containing its own Python interpreter and copy of pip, ensuring changes do not mess with your computer's global Python settings.

### Command: Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope Process

* **What it means:** A Windows PowerShell security override command. It sets the permission level to RemoteSigned (allowing local scripts to run) but restricts that rule to a Scope of Process.
* **Why we ran it:** Windows blocks local script execution by default. The -Scope Process tag ensures this permission lift is **strictly temporary**—the moment you close that specific VS Code terminal window, your Windows security defaults are completely restored.

### Command: .\ai_env\Scripts\Activate.ps1

* **What it means:** Executes the activation script inside your local environment's folder tree.
* **Why we ran it:** To step inside your isolated Python container. You know it works when (ai_env) appears in parentheses at the very front of your terminal command prompt path line.

### Command: pip install torch

* **What it means:** Invokes the Python Package Index manager (pip) to download and install the core **PyTorch** package into your active virtual environment.
* **Why we ran it:** To give our project workspace access to tensor matrix math operations, neural network layer templates (nn.Module), and quantization logic functions.

### Command: python ai_model/train_and_extract.py

* **What it means:** Instructs the active virtual Python interpreter to execute your custom script file located inside the ai_model/ subfolder.
* **Why we ran it:** To generate the random matrix configurations, uniformly scale them to 8-bit whole integers, and print out the **Golden Matrix Reference Output** ([-1018, -1486, 1188, 1804]).

### 🎛️ 2. Windows System & Toolchain Setup Commands

### Command: winget install -e --id IcarusVerilog.IcarusVerilog

* **What it means:** Calls the Windows Package Manager (winget) to search the cloud app repository for the exact ID code (IcarusVerilog.IcarusVerilog) and execute (-e) its silent installer package tool.
* **Why we ran it:** To download and set up **Icarus Verilog (iverilog)**—our hardware compiler tool—along with **GTKWave**, our electrical wave graph visualizer window app. It handles updating your laptop's underlying system path variables automatically.

### 🚀 3. Verilog Compilation & Simulation Commands

### Command: & "C:\iverilog\bin\iverilog.exe" -o sim/systolic_sim.vvp rtl/pe.v rtl/systolic_array_2x2.v rtl/relu_2x2.v rtl/deep_nn_layer.v sim/systolic_tb.v

* **What it means:** 

  * &: The PowerShell *Call Operator*, telling it to execute the path string that follows.
  * C:\iverilog\bin\iverilog.exe: The absolute path to the Icarus Verilog hardware compiler.
  * -o sim/systolic_sim.vvp: Output flag. Tells the compiler to bundle everything into a simulation executable file named systolic_sim.vvp inside your sim/ folder.
  * List of .v files: Links all your physical circuit designs (pe, array, relu, wrapper) and your test rig file (systolic_tb) together.
* **Why we ran it:** To check your hardware code for typos, syntax bugs, or broken wire ports. If the code is clean, it creates your compiled simulation blueprint file and returns a silent, blank line prompt.

### Command: & "C:\iverilog\bin\vvp.exe" sim/systolic_sim.vvp

* **What it means:** Calls the **Verilog Virtual Simulator Engine (vvp)** runtime runner to execute the compiled systolic_sim.vvp project file.
* **Why we ran it:** To run the simulation. This executes your testbench, toggles the virtual clock pulse, streams your custom PyTorch dataset into the grid using wavefront timing delays, prints the final values to the terminal panel, and saves the wave log database file (systolic_sim.vcd).

### Command: & "C:\iverilog\bin\gtkwave.exe" sim/systolic_sim.vcd

* **What it means:** Launches the external graph desktop engine **GTKWave** and automatically feeds it your simulation's Value Change Dump data file (systolic_sim.vcd).
* **Why we ran it:** To open the visual wave interface, allowing you to watch the digital inputs ripple diagonally across your processing elements and confirm that negative numbers are zeroed out by the ReLU block.

### 🌐 4. Cloud Repository Git Management Commands

### Command: git init

* **What it means:** Initializes a hidden, fresh version-control storage tracking ledger metadata folder (.git) right inside your local directory.
* **Why we ran it:** To transform a generic Windows folder structure into an official, locally tracked Git source code repository.

### Command: git add .

* **What it means:** Tells Git to look at the entire current directory (.) and stage every single untracked code asset, python module script, and markdown portfolio document.
* **Why we ran it:** To snap a preliminary boundary lasso around all your local progress files, getting them ready to lock into your next official project baseline save state.

### Command: git commit -m "Your Message Here"

* **What it means:** Saves your staged local file modifications into a permanent history log, attaching a message (-m) describing what you accomplished.
* **Why we ran it:** To create an engineering milestone checkpoint, serving as a clean rollback base state in case you introduce critical structural logic errors to your layout files later.

### Command: git branch -M main

* **What it means:** Re-allocates and renames the current baseline active git thread track to have the official primary ID name **main**.
* **Why we ran it:** To guarantee that your branch directory structural paths sync perfectly with the default branch routing structures used by modern online Git servers like GitHub.

### Command: git remote add origin https://github.com/...

* **What it means:** Creates a logical cloud connection bridge mapping your local computer repository to an empty storage shell hosted remotely on GitHub's cloud platform.
* **Why we ran it:** To tell Git exactly which address on the web to target when you are ready to upload your folder contents.

### Command: git push -u origin main

* **What it means:** Uploads (push) your tracked timeline code checkpoints from your local machine up to the cloud host's main branch path (-u origin main).
* **Why we ran it:** To move your code to the cloud, rendering your fully formatted README.md file and project layout completely live for review by external engineering recruiters.