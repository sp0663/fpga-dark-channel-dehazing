`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/08/2026 11:47:42 AM
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
    input wire i_clk,
    input wire i_rst,
    input wire [7:0] i_data,      // dark channel value J(x)
    input wire i_data_valid,
    input wire [7:0] A_min,
    output reg [7:0] o_data,      // transmission map value t(x)
    output reg o_data_valid
);

    reg [15:0] inv_A_rom [0:255];
    integer i;
    initial begin
        inv_A_rom[0] = 16'd0; // Prevent divide-by-zero crashes
        for (i = 1; i < 256; i = i + 1) begin
            // Calculates (243 * 256) / A_min
            inv_A_rom[i] = (243 * 256) / i; 
        end
    end

    reg [7:0]  data_reg;
    reg [15:0] inv_A_reg;
    reg        valid_reg1, valid_reg2;
    reg [23:0] mult_result;
    
    wire [15:0] temp;
    wire [7:0]  t0 = 8'd153;

    assign temp = mult_result[23:8]; 

    always @(posedge i_clk) begin
        if (i_rst) begin
            o_data <= 8'd0;
            o_data_valid <= 1'b0;
            valid_reg1 <= 1'b0;
            valid_reg2 <= 1'b0;
            data_reg <= 8'd0;
            inv_A_reg <= 16'd0;
            mult_result <= 24'd0;
        end else begin
            inv_A_reg  <= inv_A_rom[A_min];
            data_reg   <= i_data;
            valid_reg1 <= i_data_valid;

            mult_result <= data_reg * inv_A_reg;
            valid_reg2  <= valid_reg1;

            if (temp < t0) begin
                o_data <= t0;
            end else begin
                o_data <= 9'd256 - temp[7:0]; 
            end
            
            o_data_valid <= valid_reg2;
        end
    end

endmodule

