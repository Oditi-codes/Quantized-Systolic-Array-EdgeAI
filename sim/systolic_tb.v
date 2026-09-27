`timescale 1ns / 1ps

module systolic_tb;

    // Testbench Stimulus Wires
    reg clk;
    reg rst_n;
    reg signed [7:0] a00, a10;
    reg signed [7:0] b00, b01;

    // Output Capture Wires
    wire signed [15:0] c00, c01, c10, c11;

    // Instantiate the 2x2 Matrix Hardware Grid
    // systolic_array_2x2 UUT (
    //     .clk(clk), .rst_n(rst_n),
    //     .a00(a00), .a10(a10),
    //     .b00(b00), .b01(b01),
    //     .c00(c00), .c01(c01),
    //     .c10(c10), .c11(c11)
    // );

    deep_nn_layer UUT (
        .clk(clk), .rst_n(rst_n),
        .a00(a00), .a10(a10),
        .b00(b00), .b01(b01),
        .y00(c00), .y01(c01), // Mapped to our existing c wires for simple reuse!
        .y10(c10), .y11(c11)
    );
    
    // Generate consistent 10ns Clock Heartbeat
    always #5 clk = ~clk;

        initial begin
        $dumpfile("sim/systolic_sim.vcd");
        $dumpvars(0, systolic_tb);

        clk = 0;
        rst_n = 0;
        a00 = 0; a10 = 0;
        b00 = 0; b01 = 0;

        #15;
        rst_n = 1; // Release reset, start processing

        // --- Cycle 1 (Wavefront Step 0) ---
        a00 = 8'd18;          // Matrix A: Row 0, Element 0
        b00 = -8'd69;         // Matrix B: Col 0, Element 0
        a10 = 8'd0;           // Row 1 Delayed
        b01 = 8'd0;           // Col 1 Delayed
        #10;

        // --- Cycle 2 (Wavefront Step 1) ---
        a00 = -8'd14;         // Matrix A: Row 0, Element 1
        b00 = -8'd16;         // Matrix B: Col 0, Element 1
        a10 = -8'd20;         // Matrix A: Row 1, Element 0 (Enters now!)
        b01 = -8'd116;        // Matrix B: Col 1, Element 0 (Enters now!)
        #10;

        // --- Cycle 3 (Wavefront Step 2) ---
        a00 = 8'd0;           // Row 0 inputs completed
        b00 = 8'd0;           // Col 0 inputs completed
        a10 = 8'd12;          // Matrix A: Row 1, Element 1
        b01 = -8'd43;         // Matrix B: Col 1, Element 1
        #10;

        // Clear remaining interfaces
        a10 = 8'd0; b01 = 8'd0;
        #30; // Wait for calculations to fully propagate through the internal registers

        // Print Out the Final Computed Hardware Matrix Grid
        $display("==================================================");
        $display("   MATHEMATICAL MATRIX RESULTS FROM HARDWARE SILICON ");
        $display("==================================================");
        $display(" [ %d ]  [ %d ]", $signed(c00), $signed(c01));
        $display(" [ %d ]  [ %d ]", $signed(c10), $signed(c11));
        $display("==================================================");

        $finish;
    end

endmodule
