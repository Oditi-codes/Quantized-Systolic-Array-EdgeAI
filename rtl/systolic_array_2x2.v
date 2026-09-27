module systolic_array_2x2 (
    input clk,
    input rst_n,
    // Matrix Inputs entering the boundaries of the chip
    input signed [7:0] a00, a10, // Inputs entering from the left edge (Rows)
    input signed [7:0] b00, b01, // Inputs entering from the top edge (Columns)
    // Accumulation Outputs from each independent cell
    output signed [15:0] c00, c01,
    output signed [15:0] c10, c11
);

    // Internal copper wires to connect neighboring cells together
    wire signed [7:0] a00_to_a01, a10_to_a11;
    wire signed [7:0] b00_to_b10, b01_to_b11;
    
    // Terminating wires for data exiting the right and bottom boundaries
    wire signed [7:0] exit_a01, exit_a11;
    wire signed [7:0] exit_b10, exit_b11;

    // Top-Left Cell (Row 0, Col 0)
    pe PE00 (
        .clk(clk), .rst_n(rst_n),
        .in_a(a00), .in_b(b00),
        .out_a(a00_to_a01), .out_b(b00_to_b10), .accum(c00)
    );

    // Top-Right Cell (Row 0, Col 1) -> Receives A from PE00
    pe PE01 (
        .clk(clk), .rst_n(rst_n),
        .in_a(a00_to_a01), .in_b(b01),
        .out_a(exit_a01), .out_b(b01_to_b11), .accum(c01)
    );

    // Bottom-Left Cell (Row 1, Col 0) -> Receives B from PE00
    pe PE10 (
        .clk(clk), .rst_n(rst_n),
        .in_a(a10), .in_b(b00_to_b10),
        .out_a(a10_to_a11), .out_b(exit_b10), .accum(c10)
    );

    // Bottom-Right Cell (Row 1, Col 1) -> Receives A from PE10, B from PE01
    pe PE11 (
        .clk(clk), .rst_n(rst_n),
        .in_a(a10_to_a11), .in_b(b01_to_b11),
        .out_a(exit_a11), .out_b(exit_b11), .accum(c11)
    );

endmodule
