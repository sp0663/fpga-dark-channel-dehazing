`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 01/15/2026 07:08:29 PM
// Design Name: 
// Module Name: lineBuffer
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


module lineBuffer(
    input   i_clk,
    input   i_rst,
    input [7:0] i_data,
    input   i_data_valid,
    output [119:0] o_data,
    input i_rd_data
);

reg [7:0] line [511:0]; 
reg [8:0] wrPntr;
reg [8:0] rdPntr;

always @(posedge i_clk)
begin
    if(i_data_valid)
        line[wrPntr] <= i_data;
end

always @(posedge i_clk)
begin
    if(i_rst)
        wrPntr <= 'd0;
    else if(i_data_valid)
        wrPntr <= wrPntr + 'd1;
end

assign o_data = {
    line[(rdPntr+0) & 9'h1ff],
    line[(rdPntr+1) & 9'h1ff],
    line[(rdPntr+2) & 9'h1ff],
    line[(rdPntr+3) & 9'h1ff],
    line[(rdPntr+4) & 9'h1ff],
    line[(rdPntr+5) & 9'h1ff],
    line[(rdPntr+6) & 9'h1ff],
    line[(rdPntr+7) & 9'h1ff],
    line[(rdPntr+8) & 9'h1ff],
    line[(rdPntr+9) & 9'h1ff],
    line[(rdPntr+10) & 9'h1ff],
    line[(rdPntr+11) & 9'h1ff],
    line[(rdPntr+12) & 9'h1ff],
    line[(rdPntr+13) & 9'h1ff],
    line[(rdPntr+14) & 9'h1ff]
};

always @(posedge i_clk)
begin
    if(i_rst)
        rdPntr <= 'd0;
    else if(i_rd_data)
        rdPntr <= rdPntr + 'd1;
end

endmodule
