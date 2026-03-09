`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/08/2026 11:35:57 AM
// Design Name: 
// Module Name: dcp_top
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


module dcp_top(
    input i_clk,
    input i_rst,
    input [23:0] i_pixel_data,
    input i_pixel_valid,
    output [23:0] o_pixel_data,
    output o_pixel_valid
);

wire [7:0]   rgb_min_pixel;
wire [391:0] line_buffer_out;
wire         line_buffer_out_valid;
wire [7:0]   A_r, A_g, A_b, A_min;
wire         A_valid;
wire [7:0]   min_filter_out;
wire         min_filter_out_valid;
wire [7:0]   transmission_out;
wire         transmission_out_valid;
wire [23:0]  delay_pixel_out;
wire         delay_pixel_out_valid;

// Shift register: tap at [0] for ambientLight (1 cycle extra)
//                 tap at [2] for scene_radiance (3 cycles extra)
reg [23:0] pixel_sr  [0:2];
reg        valid_sr  [0:2];
integer k;
always @(posedge i_clk) begin
    pixel_sr[0] <= delay_pixel_out;
    valid_sr[0] <= delay_pixel_out_valid;
    for(k = 1; k < 3; k = k + 1) begin
        pixel_sr[k] <= pixel_sr[k-1];
        valid_sr[k] <= valid_sr[k-1];
    end
end

wire [23:0] ambient_pixel = pixel_sr[0];   // 3585 cycles, aligns with min_filter_out_valid
wire        ambient_valid  = valid_sr[0] & min_filter_out_valid;

wire [23:0] aligned_pixel = pixel_sr[2];   // 3587 cycles, aligns with transmission_out_valid
wire        aligned_valid  = valid_sr[2] & transmission_out_valid;

rgb_min rgb(
    .i_pixel_data(i_pixel_data),
    .i_pixel_valid(i_pixel_valid),
    .o_min(rgb_min_pixel)
);

lineBufferArray lba(
    .i_clk(i_clk),
    .i_rst(i_rst),
    .i_data(rgb_min_pixel),
    .i_data_valid(i_pixel_valid),
    .i_rd_data(1'b1),
    .o_data(line_buffer_out),
    .o_data_valid(line_buffer_out_valid)
);

minFilter mf(
    .i_clk(i_clk),
    .i_rst(i_rst),
    .i_window(line_buffer_out),
    .window_valid(line_buffer_out_valid),
    .o_data(min_filter_out),
    .o_data_valid(min_filter_out_valid)
);

ambientLight a(
    .i_clk(i_clk),
    .i_rst(i_rst),
    .i_pixel_data(ambient_pixel),
    .i_dark_channel_val(min_filter_out),
    .i_data_valid(ambient_valid),
    .A_r(A_r),
    .A_g(A_g),
    .A_b(A_b),
    .A_min(A_min),
    .A_valid(A_valid)
);

transmission_estimator tx(
    .i_clk(i_clk),
    .i_rst(i_rst),
    .i_data(min_filter_out),
    .i_data_valid(min_filter_out_valid),
    .A_min(A_min),
    .o_data(transmission_out),
    .o_data_valid(transmission_out_valid)
);

pixelDelayBuffer pdb(
    .i_clk(i_clk),
    .i_rst(i_rst),
    .i_pixel(i_pixel_data),
    .i_pixel_valid(i_pixel_valid),
    .o_pixel(delay_pixel_out),
    .o_pixel_valid(delay_pixel_out_valid)
);

scene_radiance sr(
    .i_clk(i_clk),
    .i_rst(i_rst),
    .i_data(aligned_pixel),
    .i_data_valid(aligned_valid),
    .A_r(A_r),
    .A_g(A_g),
    .A_b(A_b),
    .transmission_val(transmission_out),
    .o_data(o_pixel_data),
    .o_data_valid(o_pixel_valid)
);

endmodule
