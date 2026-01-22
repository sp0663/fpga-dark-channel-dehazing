`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 01/16/2026 11:18:06 PM
// Design Name: 
// Module Name: scene_radiance
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


module scene_radiance(
    input i_clk,
    input i_rst,
    input [23:0] i_data,        //rgb values of original image
    input i_data_valid,
    input [7:0] A_r,
    input [7:0] A_g,
    input [7:0] A_b,
    input [7:0] transmission_val,
    output [23:0] o_data,       //dehazed rgb pixel
    output o_data_valid
);

wire [23:0] A_val = {A_r, A_g, A_b};
reg [23:0] radiance;
integer i;
reg signed [15:0] diff [2:0];
reg signed [23:0] temp [2:0];
reg signed [23:0] res [2:0];

always @(*) begin
    for(i=0;i<3;i=i+1) begin 
        diff[i] = $signed({1'b0,i_data[i*8+:8]}) - $signed({1'b0,A_val[i*8+:8]});
        temp[i] = (diff[i] * 256)/$signed({1'b0,transmission_val});
        res[i] = temp[i] + $signed({1'b0,A_val[i*8+:8]});
        if(res[i]<0)
            radiance[i*8+:8] = 0;
        else if (res[i]>255)
            radiance[i*8+:8] = 8'd255;
        else
            radiance[i*8+:8] = res[i][7:0];
    end
end

assign o_data = radiance;
assign o_data_valid = i_data_valid;

endmodule
