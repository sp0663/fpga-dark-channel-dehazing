`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/08/2026 11:48:55 AM
// Design Name: 
// Module Name: pixelLineBuffer
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


module pixelLineBuffer(
    input  i_clk,
    input  i_rst,
    input  [23:0] i_data,
    input  i_data_valid,
    output [23:0] o_data,
    output o_data_valid,        
    input  i_rd_data
);

(* ram_style = "block" *) reg [23:0] line [511:0];
reg [8:0]  wrPntr;
reg [8:0]  rdPntr;
reg [23:0] o_data_reg;
reg        o_data_valid_reg;


always @(posedge i_clk) begin
    if(i_data_valid)
        line[wrPntr] <= i_data;
end

always @(posedge i_clk) begin
    if(i_rst)
        wrPntr <= 'd0;
    else if(i_data_valid)
        wrPntr <= wrPntr + 'd1;
end


wire [8:0] fillLevel = wrPntr - rdPntr;
wire       rd_safe   = i_rd_data && (fillLevel > 9'd0);


always @(posedge i_clk) begin
    o_data_reg <= line[rdPntr];
end

assign o_data = o_data_reg;


always @(posedge i_clk) begin
    if(i_rst)
        o_data_valid_reg <= 1'b0;
    else
        o_data_valid_reg <= rd_safe;
end

assign o_data_valid = o_data_valid_reg;


always @(posedge i_clk) begin
    if(i_rst)
        rdPntr <= 'd0;
    else if(rd_safe)
        rdPntr <= rdPntr + 'd1;
end

endmodule

