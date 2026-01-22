`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 01/16/2026 09:19:47 PM
// Design Name: 
// Module Name: transmission_estimator
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


module transmission_estimator(
    input i_clk,
    input i_rst,
    input [7:0] i_data,     //dark channel value J(x)
    input i_data_valid,
    input [7:0] A_min,
    output [7:0] o_data,    //transmission map value t(x)
    output o_data_valid
 );
    
wire [15:0] temp;
wire [7:0] t0 = 8'd153;

assign temp = (i_data * 243) / A_min;
assign o_data = (temp < t0) ? t0 : (256 - temp[7:0]);
assign o_data_valid = i_data_valid;
    
endmodule
