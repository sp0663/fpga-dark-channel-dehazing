`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 01/17/2026 01:01:43 PM
// Design Name: 
// Module Name: pixelDelayBuffer
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


module pixelDelayBuffer(
    input i_clk,
    input i_rst,
    input [23:0] i_pixel,        // RGB pixel input
    input i_pixel_valid,
    output [23:0] o_pixel,       // Delayed RGB pixel output
    output reg o_pixel_valid
);

reg [31:0] fill_counter;
wire [23:0] pixel_chain [0:14];  

// 15 line buffers (matching lineBufferArray)
genvar i;
generate
    for(i = 0; i < 15; i = i + 1) begin
        pixelLineBuffer plb_inst (
            .i_clk(i_clk),
            .i_rst(i_rst),
            .i_data(i == 0 ? i_pixel : pixel_chain[i-1]),
            .i_data_valid(i_pixel_valid),
            .o_data(pixel_chain[i]),
            .i_rd_data(1'b1)
        );
    end
endgenerate

assign o_pixel = pixel_chain[0];

always @(posedge i_clk) begin
    if (i_rst)
        fill_counter <= 0;
    else if (i_pixel_valid && fill_counter < ((512*15)-1))
        fill_counter <= fill_counter + 1;
end

always @(posedge i_clk) begin
    if (i_rst)
        o_pixel_valid <= 1'b0;
    else if (fill_counter >= ((512*15)-1))
        o_pixel_valid <= i_pixel_valid;
    else
        o_pixel_valid <= 1'b0;
end

endmodule