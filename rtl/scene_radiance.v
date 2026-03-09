`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/08/2026 11:50:01 AM
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
    input         i_clk,
    input         i_rst,
    input  [23:0] i_data,
    input         i_data_valid,
    input  [7:0]  A_r,
    input  [7:0]  A_g,
    input  [7:0]  A_b,
    input  [7:0]  transmission_val,
    output [23:0] o_data,
    output        o_data_valid
);

reg [23:0] recip_lut [0:255];
integer j;
initial begin
    recip_lut[0] = 24'd65535;
    for (j = 1; j < 256; j = j + 1)
        recip_lut[j] = 65536 / j;
end

reg signed [15:0] diff_s1    [2:0];
reg        [23:0] recip_s1;
reg        [7:0]  A_s1       [2:0];
reg               valid_s1;

reg signed [39:0] product_s2 [2:0];
reg        [7:0]  A_s2       [2:0];
reg               valid_s2;

reg [23:0] radiance_s3;
reg        valid_s3;

wire [7:0] A_val [2:0];
assign A_val[2] = A_r;
assign A_val[1] = A_g;
assign A_val[0] = A_b;

integer i;

always @(posedge i_clk) begin
    valid_s1  <= i_data_valid;
    recip_s1  <= recip_lut[transmission_val];
    for (i = 0; i < 3; i = i + 1) begin
        diff_s1[i] <= $signed({1'b0, i_data[i*8+:8]})
                    - $signed({1'b0, A_val[i]});
        A_s1[i]    <= A_val[i];
    end
end

always @(posedge i_clk) begin
    valid_s2 <= valid_s1;
    for (i = 0; i < 3; i = i + 1) begin
        product_s2[i] <= diff_s1[i] * $signed({1'b0, recip_s1});
        A_s2[i]       <= A_s1[i];
    end
end

reg signed [23:0] res [2:0];
always @(posedge i_clk) begin
    valid_s3 <= valid_s2;
    for (i = 0; i < 3; i = i + 1) begin
        res[i] = $signed(product_s2[i][39:8]) + $signed({1'b0, A_s2[i]});
        if      (res[i] < 0)   radiance_s3[i*8+:8] <= 8'd0;
        else if (res[i] > 255) radiance_s3[i*8+:8] <= 8'd255;
        else                   radiance_s3[i*8+:8] <= res[i][7:0];
    end
end

assign o_data       = radiance_s3;
assign o_data_valid = valid_s3;

endmodule
