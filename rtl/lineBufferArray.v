`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/08/2026 11:40:52 AM
// Design Name: 
// Module Name: lineBufferArray
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module lineBufferArray(
    input i_clk,
    input i_rst,
    input [7:0] i_data,     //pixel min of rgb
    input i_data_valid,
    input i_rd_data,
    output [391:0] o_data,   //15x15 patch
    output reg o_data_valid
);

reg [14:0] fill_counter;
wire [55:0] lb_chain [0:6];  // 15 intermediate connections

// Generate 15 line buffers in series
genvar i;
generate
    for(i = 0; i < 7; i = i + 1) begin
        lineBuffer lb_inst (
            .i_clk(i_clk),
            .i_rst(i_rst),
            .i_data(i == 0 ? i_data : lb_chain[i-1]),  // Chain input
            .i_data_valid(i_data_valid),                // Same valid for all
            .o_data(lb_chain[i]),                       // Chain output
            .i_rd_data(i_rd_data)                            // Always reading
        );
        
    end
endgenerate
assign o_data = {lb_chain[0], lb_chain[1], lb_chain[2], lb_chain[3], lb_chain[4], lb_chain[5], 
                 lb_chain[6]};
                         
always @(posedge i_clk) begin
    if (i_rst)
        fill_counter <= 0;
    else if (i_data_valid && fill_counter < ((512*7)-1))
        fill_counter <= fill_counter + 1;
end

always @(posedge i_clk) begin
    if (i_rst)
        o_data_valid <= 1'b0;
    else if (fill_counter >= ((512*7)-1))
        o_data_valid <= i_data_valid;
    else
        o_data_valid <= 1'b0;
end

endmodule
