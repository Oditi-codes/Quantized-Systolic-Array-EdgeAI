module relu_2x2 (
    // Inputs coming straight from our 4 matrix accumulator outputs
    input signed [15:0] in_c00, in_c01,
    input signed [15:0] in_c10, in_c11,
    // Activated outputs passing out to memory
    output signed [15:0] out_r00, out_r01,
    output signed [15:0] out_r10, out_r11
);

    // Combinational Ternary Operators acting as hardware multiplexers
    // If the input is less than 0, output 16'd0; otherwise, pass the input.
    assign out_r00 = (in_c00 < 16'sd0) ? 16'sd0 : in_c00;
    assign out_r01 = (in_c01 < 16'sd0) ? 16'sd0 : in_c01;
    assign out_r10 = (in_c10 < 16'sd0) ? 16'sd0 : in_c10;
    assign out_r11 = (in_c11 < 16'sd0) ? 16'sd0 : in_c11;

endmodule
