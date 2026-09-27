`timescale 1ns / 1ps

module mac_cell_tb;

    reg clk;
    reg rst_n;
    reg [7:0] in_x;
    reg [7:0] in_w;

    wire [15:0] out_y;

    mac_cell UUT (
        .clk(clk),
        .rst_n(rst_n),
        .in_x(in_x),
        .in_w(in_w),
        .out_y(out_y)
    );

    always #5 clk = ~clk;

    initial begin
        // --- ADD THESE 4 LINES TO GENERATE WAVEFORMS ---
        $dumpfile("sim/mac_sim.vcd"); // Creates a value change dump file
        $dumpvars(0, mac_cell_tb);    // Tells it to record EVERY single wire inside this testbench
        // -----------------------------------------------

        clk = 0;
        rst_n = 0;
        in_x = 0;
        in_w = 0;

        #15;
        rst_n = 1;

        // Cycle 1 data (X=2, W=54)
        in_x = 8'd2;
        in_w = 8'd54;
        #10;

        // Cycle 2 data (X=4, W=59)
        in_x = 8'd4;
        in_w = 8'd59;
        #10;

        // Clear inputs to observe final output
        in_x = 8'd0;
        in_w = 8'd0;
        #10;

        $display("==================================================");
        $display("Hardware Output out_y (Decimal): %d", out_y);
        $display("==================================================");
        
        $finish;
    end

endmodule