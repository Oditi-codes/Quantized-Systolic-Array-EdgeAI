module pe (
    input clk,
    input rst_n,
    input signed [7:0] in_a,        // Matrix A input coming from the left
    input signed [7:0] in_b,        // Matrix B input coming from the top
    output reg signed [7:0] out_a,  // Register passing Matrix A to the right neighbor
    output reg signed [7:0] out_b,  // Register passing Matrix B to the bottom neighbor
    output reg signed [15:0] accum  // 16-bit register storing our MAC accumulation result
);

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            out_a <= 8'd0;
            out_b <= 8'd0;
            accum <= 16'd0;
        end else begin
            out_a <= in_a;   // Pass the left input to the right on the clock edge
            out_b <= in_b;   // Pass the top input downward on the clock edge
            accum <= accum + (in_a * in_b); // Core Matrix MAC operation
        end
    end

endmodule
