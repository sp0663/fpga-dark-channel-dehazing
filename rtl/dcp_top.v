`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 01/17/2026 11:57:57 AM
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
    
wire [7:0] rgb_min_pixel;
wire [1799:0] line_buffer_out;
wire line_buffer_out_valid;
wire [7:0] A_r, A_g, A_b, A_min;
wire A_valid;
wire i_ambient_light_valid;
wire [7:0] min_filter_out;
wire min_filter_out_valid;
wire [7:0] transmission_out;
wire transmission_out_valid;
wire [23:0] delay_pixel_out;
wire delay_pixel_out_valid;
wire scene_radiance_valid;
assign scene_radiance_valid = delay_pixel_out_valid & transmission_out_valid & A_valid;
assign i_ambient_light_valid = delay_pixel_out_valid & min_filter_out_valid;

rgb_min rgb(
    .i_pixel_data(i_pixel_data),      
    .o_min(rgb_min_pixel)              
);

lineBufferArray lba(
    .i_clk(i_clk),
    .i_rst(i_rst),
    .i_data(rgb_min_pixel),     //pixel min of rgb
    .i_data_valid(i_pixel_valid),
    .i_rd_data(1'b1),
    .o_data(line_buffer_out),   //vertical line of pixels of 15 line buffers
    .o_data_valid(line_buffer_out_valid)
);

ambientLight a(
    .i_clk(i_clk),
    .i_rst(i_rst),
    .i_pixel_data(delay_pixel_out),
    .i_dark_channel_val(min_filter_out),
    .i_data_valid(i_ambient_light_valid),
    .A_r(A_r),
    .A_g(A_g),
    .A_b(A_b),
    .A_min(A_min),
    .A_valid(A_valid)
);

minFilter mf(
    .i_clk(i_clk),
    .i_rst(i_rst),
    .i_window(line_buffer_out),     //15x15 patch
    .window_valid(line_buffer_out_valid),
    .o_data(min_filter_out),        //min of 15x15 pixels J(x)
    .o_data_valid(min_filter_out_valid)
);

transmission_estimator tx(
    .i_clk(i_clk),
    .i_rst(i_rst),
    .i_data(min_filter_out),     //dark channel value J(x)
    .i_data_valid(min_filter_out_valid),
    .A_min(A_min),
    .o_data(transmission_out),    //transmission map value t(x)
    .o_data_valid(transmission_out_valid)
 );
 
pixelDelayBuffer pdb(
    .i_clk(i_clk),
    .i_rst(i_rst),
    .i_pixel(i_pixel_data),        // RGB pixel input
    .i_pixel_valid(i_pixel_valid),
    .o_pixel(delay_pixel_out),       // Delayed RGB pixel output
    .o_pixel_valid(delay_pixel_out_valid)
); 
 
scene_radiance sr(
    .i_clk(i_clk),
    .i_rst(i_rst),
    .i_data(delay_pixel_out),        //rgb values of original image
    .i_data_valid(scene_radiance_valid),
    .A_r(A_r),
    .A_g(A_g),
    .A_b(A_b),
    .transmission_val(transmission_out),
    .o_data(o_pixel_data),       //dehazed rgb pixel
    .o_data_valid(o_pixel_valid)
);
    
endmodule
