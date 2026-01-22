`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 01/15/2026 06:32:19 PM
// Design Name: 
// Module Name: rgb_min
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


module rgb_min(
    input [23:0] i_pixel_data,      //rgb values of the pixel
    output [7:0] o_min              //min of rgb
    );
    
    reg [7:0] curr_min;
    
    always @(*)
    begin
        curr_min = i_pixel_data[23:16];
        if(curr_min > i_pixel_data[15:8])
            curr_min = i_pixel_data[15:8];
        if(curr_min > i_pixel_data[7:0])
            curr_min = i_pixel_data[7:0];
    end
    
    assign o_min = curr_min;
    
endmodule
