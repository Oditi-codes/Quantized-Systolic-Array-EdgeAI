module deep_nn_layer (
    input clk,
    input rst_n,
    // Boundaries matrix inputs
    input signed [7:0] a00, a10,
    input signed [7:0] b00, b01,
    // Fully Accelerated and Activated Outputs!
    output signed [15:0] y00, y01,
    output signed [15:0] y10, y11
);

    // Internal copper bus lines to channel the matrix results into the ReLU module
    wire signed [15:0] c00, c01, c10, c11;

    // 1. Instantiate our Matrix Accelerator Engine
    systolic_array_2x2 matrix_engine (
        .clk(clk), .rst_n(rst_n),
        .a00(a00), .a10(a10),
        .b00(b00), .b01(b01),
        .c00(c00), .c01(c01),
        .c10(c10), .c11(c11)
    );

    // 2. Solder the Matrix Engine wires directly into the ReLU Activation Cell
    relu_2x2 activation_layer (
        .in_c00(c00), .in_c01(c01), .in_c10(c10), .in_c11(c11),
        .out_r00(y00), .out_r01(y01), .out_r10(y10), .out_r11(y11)
    );

endmodule
