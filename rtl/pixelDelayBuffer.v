`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/08/2026 11:48:17 AM
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
    input  i_clk,
    input  i_rst,
    input  [23:0] i_pixel,
    input  i_pixel_valid,
    output [23:0] o_pixel,
    output        o_pixel_valid
);

reg [31:0] fill_counter;

wire [23:0] pixel_chain  [0:6];
wire        valid_chain  [0:6];  

genvar i;
generate
    for(i = 0; i < 7; i = i + 1) begin : plb_gen
        pixelLineBuffer plb_inst (
            .i_clk       (i_clk),
            .i_rst       (i_rst),
            .i_data      (i == 0 ? i_pixel        : pixel_chain[i-1]),
            .i_data_valid(i == 0 ? i_pixel_valid  : valid_chain[i-1]),  
            .o_data      (pixel_chain[i]),
            .o_data_valid(valid_chain[i]),
            .i_rd_data   (1'b1)
        );
    end
endgenerate

assign o_pixel = pixel_chain[6];  

localparam FILL_THRESHOLD = (512 * 7) + 7 - 1;

always @(posedge i_clk) begin
    if(i_rst)
        fill_counter <= 'd0;
    else if(i_pixel_valid && fill_counter < FILL_THRESHOLD)
        fill_counter <= fill_counter + 'd1;
end

assign o_pixel_valid = (fill_counter >= FILL_THRESHOLD) && valid_chain[6];

endmodule
