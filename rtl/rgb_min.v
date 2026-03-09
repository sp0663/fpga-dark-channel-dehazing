`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/08/2026 11:37:43 AM
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
    input i_pixel_valid,
    output [7:0] o_min              //min of rgb
    );
    
    reg [7:0] curr_min;
    
    always @(*) begin
        if(i_pixel_valid) begin
            curr_min = i_pixel_data[23:16];
            if(curr_min > i_pixel_data[15:8])
                curr_min = i_pixel_data[15:8];
            if(curr_min > i_pixel_data[7:0])
                curr_min = i_pixel_data[7:0];
        end
        else
            curr_min = 8'd0;
    end
    
    assign o_min = curr_min;
    
endmodule

