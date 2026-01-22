`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 01/16/2026 09:09:18 PM
// Design Name: 
// Module Name: ambientLight
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


module ambientLight(
    input i_clk,
    input i_rst,
    input [23:0] i_pixel_data,
    input [7:0] i_dark_channel_val,
    input i_data_valid,
    output [7:0] A_r,
    output [7:0] A_g,
    output [7:0] A_b,
    output reg [7:0] A_min,
    output A_valid
);

reg [7:0] dark_channel_max;  
reg [23:0] rgb_best;
assign A_r = rgb_best[23:16];
assign A_g = rgb_best[15:8];
assign A_b = rgb_best[7:0];

always @(posedge i_clk) begin
    if(i_rst) begin 
        dark_channel_max <= 8'd0;
        rgb_best <= 24'd0;
    end
end

always @(*) begin
    if(i_data_valid && (dark_channel_max < i_dark_channel_val)) begin
        dark_channel_max = i_dark_channel_val;
        rgb_best = i_pixel_data;
        A_min = rgb_best[23:16];
        if(A_min > rgb_best[15:8])
            A_min = rgb_best[15:8];
        if(A_min > rgb_best[7:0])
            A_min = rgb_best[7:0];
    end
end

assign A_valid = i_data_valid;

endmodule
