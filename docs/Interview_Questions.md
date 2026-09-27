### STMicroelectronics Hardware AI Team Interview Defense Playbook 🎯

This document compiles highly technical, detailed interview questions and deep-dive answers based on your custom Quantized Pipelined Systolic Neural Network Accelerator layer. 

### 🔬 Category 1: Hardware-Software Co-Design & Quantization Math

### Q1: You chose INT8 Uniform Quantization for your weights and activations. Walk me through the exact mathematical mapping from a PyTorch Float32 tensor to your Verilog inputs. How do you handle zero-point shifts?

**Answer:**
"In this architecture, I implemented a symmetric uniform scalar quantization scheme. The transformation follows the equation:

Integer Value=clip(round(Float Value×Scale),-128,127)Integer Value equals clip open paren round open paren Float Value cross Scale close paren comma negative 128 comma 127 close paren
Integer Value=clip(round(Float Value×Scale),−128,127)
 

In my specific script, I utilized a static scaling factor (
𝑆

=50
). Because the data distributions of both my intermediate layer inputs (Matrix A) and my trained network weights (Matrix B) were centered closely around zero, I opted for **Symmetric Quantization**. This forces the quantization zero-point to map exactly to the hardware value 0, which provides a massive optimization benefit: it completely eliminates the need for extra hardware overhead blocks to compute zero-point bias subtraction logic inside our arithmetic pipeline circuits, saving significant silicon area." 

### Q2: During your PyTorch verification, why did you explicitly scale up the variables using .to(torch.int32) right before running the torch.matmul function? What would happen if you kept them as int8?

**Answer:**
"This is a critical boundary constraint handling step. An 8-bit signed integer (INT8) has a hard physical ceiling limit of 

+127positive 127
+127
 and a floor limit of 

-128negative 128
−128
. When you multiply two INT8 elements together (for instance, 
18

×

−69

=

−1242
), the intermediate product already demands more than 8 bits to resolve. If you force PyTorch to accumulate these values inside an 8-bit container, the tensor will suffer from catastrophic **integer wrap-around overflow** (similar to when my early script model wrapped a value of 344 down into an incorrect 88). 

By scaling the variables to int32 before the multiplication pass, I mirrored exactly what my hardware does: providing a larger arithmetic bit-width container to store accumulation passes safely, ensuring absolute parity between software math projections and physical hardware evaluations." 

### 🎛️ Category 2: Verilog RTL Architecture & Signed Bit Mechanics

### Q3: Why is the signed keyword mandatory across every internal wire, port, and register in this design? What happens at the gate level if you mix a signed variable with an unsigned variable?

**Answer:**
"By default, Verilog interprets binary bit vectors as unsigned magnitudes. For example, if I stream the negative integer weight 

-69negative 69
−69
 into an unsigned 8-bit bus, the hardware interprets the bit pattern 8'b10111011 as the unsigned decimal integer 

+187positive 187
+187
 (
256

−69
). 

By explicitly adding the **signed** keyword, I instruct the RTL synthesis compiler to implement **Two's Complement Arithmetic Logic Units (ALUs)**. When a multiplication occurs, the compiler generates sign-extension circuitry to preserve the most significant bit (MSB). If you accidentally mix a signed port with an unsigned wire anywhere in an arithmetic expression, Verilog standard compliance rules will automatically force the *entire expression* to cast to unsigned. This strips away sign-extension logic, causes arithmetic evaluation errors, and collapses the neural output accuracy." 

### Q4: In your Processing Element (pe.v), you declared the accumulator register as a reg signed [15:0] accum. How did you calculate that exact bit-width requirement?

**Answer:**
"Bit-width growth calculation is a fundamental constraint in digital design. When you multiply a signed 

Ncap N
𝑁
-bit number by a signed 

Mcap M
𝑀
-bit number, the maximum possible size of the resulting product requires exactly 
(

𝑁

+𝑀

)
 bits. Since both my inputs (
𝑖𝑛

_𝑎
 and 
𝑖𝑛

_𝑏
) are 8-bit signed vectors, the intermediate product wire (multiplication_result) must be exactly:

8 bits+8 bits=16 bits8  bits plus 8  bits equals 16  bits
8 bits+8 bits=16 bits
 

To prevent overflow errors across multiple accumulation cycles in deeper matrix sizes, you generally add 
log2

(

𝐾

)
 guard bits, where 

Kcap K
𝐾
 is the length of the dot product vector. For a compact 2x2 grid, a 16-bit wide container provided a safe, optimized balance that completely eliminated quantization clipping without wasting unnecessary flip-flop register gates." 

### 🌊 Category 3: Pipelining, Control Schedules & Wavefront Strategy

### Q5: Explain the structural configuration of your Systolic Array. Why did you stagger inputs by 1 clock cycle using Wavefront Pipelining instead of broadcasting data to all cells simultaneously?

**Answer:**
"If you broadcast inputs globally to every processing cell in a large matrix layout simultaneously, you create a massive **Fan-out/Capacitance Bottleneck** on the clock and data routing buses. The copper wires become electrically overloaded, requiring massive driver buffers, which slows down maximum operating frequency (

Fmaxcap F sub m a x end-sub
𝐹𝑚𝑎𝑥
) and increases dynamic power consumption. 

My architecture relies on **Localized Interconnect Networks**. Data moves only between immediate physical neighbors. PE00 processes its input and passes it rightward to PE01 on the next clock tick. Because of this 1-cycle physical propagation delay, I implemented **Wavefront Scheduling** inside my testbench: Row 1 (a10) and Column 1 (b01) are held at zero and delayed by exactly 1 clock period relative to Row 0 and Column 0. This guarantees that data packets moving vertically and horizontally collide in perfect synchronization at the multiplier registers, achieving massive data reuse with minimal wire paths." 

### Q6: Your ReLU module (relu_2x2.v) is designed using pure Combinational Logic via ternary operators, rather than Sequential Logic registers. Justify this choice. What are the engineering trade-offs?

**Answer:**
"Designing the ReLU activation layer as pure combinational logic introduces a major advantage: **Zero-latency execution**. The circuit simply evaluates the sign bit (MSB) of the incoming 16-bit bus using multiplexer gates. If the bit is 1 (negative), it routes a signed zero (16'sd0) to the output pin instantly; otherwise, it passes the data untouched. This saves hundreds of physical flip-flop register slots on chip. 

The trade-off consideration is **Propagation Delay (

Tpdcap T sub p d end-sub
𝑇𝑝𝑑
)**. Because there are no registers to break up the path, the combinational gate delay of the ReLU module appends directly onto the calculation paths of the systolic array cells. For our 2x2 design, this combinational logic overhead is negligible. However, if this were a large, deep array configuration, I would insert a pipeline stage register at the ReLU boundary to break up the long critical path, preserving high 

Fmaxcap F sub m a x end-sub
𝐹𝑚𝑎𝑥
 at the expense of exactly 1 extra clock cycle of throughput latency." 

### 🔬 Category 4: Verification, Waveforms & Debugging Protocols

### Q7: When you first compiled your custom signed matrix data array, your outputs read massive incorrect values like [-5727, -5940]. Explain the root cause of this simulation behavior and your systematic approach to identifying and debugging it.

**Answer:**
"The root cause was an asymmetric unsigned data format assignment bug inside my simulation script module. While my internal Processing Elements (pe.v) were configured with signed ports, my testbench stimulus generators (reg [7:0] a00) and output capture wires (wire [15:0] c00) were originally declared as standard unsigned vectors. 

When I injected negative variables like -8'd69, the compiler evaluated the literal bit vector as an unsigned positive value (

187187
187
), feeding corrupted data magnitudes into my multipliers. To debug this systematically, I generated a visual Value Change Dump database (.vcd) and loaded the internal nodes into **GTKWave**. By expanding the UUT.matrix_engine hierarchy block and changing the data render format to **Signed Decimal**, I immediately observed the boundary numbers ballooning improperly on the first clock edge. Resolving this required enforcing the signed keyword across all testbench stimulus registers and output monitor wires, which immediately aligned my cycle-accurate simulations with my PyTorch targets."