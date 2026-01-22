`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 01/16/2026 08:42:39 PM
// Design Name: 
// Module Name: minFilter
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


module minFilter(
    input i_clk,
    input i_rst,
    input [1799:0] i_window,     //15x15 patch
    input window_valid,
    output [7:0] o_data,        //min of 15x15 pixels J(x) 
    output o_data_valid
);

reg [7:0] row_min [14:0];
reg [7:0] win_min;
integer i, j;

always @(*) begin
    for(i=0;i<15;i=i+1) begin
        row_min[i] = 8'hff;
        for(j=0;j<15;j=j+1)
            row_min[i] = (row_min[i]>i_window[((i*15+j)*8)+:8]) ? i_window[((i*15+j)*8)+:8]:row_min[i];    
    end
end

always @(*) begin
    win_min = 8'hff;
    for(i=0;i<15;i=i+1) begin
        if(win_min > row_min[i])
            win_min = row_min[i];        
    end
end

assign o_data = win_min;
assign o_data_valid = window_valid;

endmodule
