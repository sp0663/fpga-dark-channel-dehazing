`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 01/17/2026 01:00:09 PM
// Design Name: 
// Module Name: pixelLineBuffer
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


module pixelLineBuffer(
    input i_clk,
    input i_rst,
    input [23:0] i_data,        // 24-bit RGB
    input i_data_valid,
    output [23:0] o_data,       // 24-bit RGB
    input i_rd_data
);

reg [23:0] line [511:0];        // 24-bit wide memory
reg [8:0] wrPntr;
reg [8:0] rdPntr;

always @(posedge i_clk) begin
    if(i_data_valid)
        line[wrPntr] <= i_data;
end

always @(posedge i_clk) begin
    if(i_rst)
        wrPntr <= 'd0;
    else if(i_data_valid)
        wrPntr <= wrPntr + 'd1;
end

assign o_data = line[rdPntr];

always @(posedge i_clk) begin
    if(i_rst)
        rdPntr <= 'd0;
    else if(i_rd_data)
        rdPntr <= rdPntr + 'd1;
end

endmodule
