module mac_cell (
    input clk,               // The heartbeat clock wire of the chip
    input rst_n,             // Reset pin (Active Low: 0 means clear everything, 1 means run)
    input [7:0] in_x,        // 8-bit wire for Input Data (X)
    input [7:0] in_w,        // 8-bit wire for Weight Data (W)
    output reg [15:0] out_y  // 16-bit register to store the accumulated calculation
);

    // Internal wire to hold the immediate result of the multiplication
    // 8-bit * 8-bit multiplication can result in up to a 16-bit number!
    wire [15:0] multiplication_result;

    // Continually multiply X and W as soon as they show up on the wires
    assign multiplication_result = in_x * in_w;

    // Synchronous Logic: Updates only on the rising edge of the clock signal
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            // If reset is pressed, wipe the memory clean back to zero
            out_y <= 16'b0;
        end
        else begin
            // Accumulate: Take the existing value and add the new multiplication result
            out_y <= out_y + multiplication_result;
        end
    end

endmodule