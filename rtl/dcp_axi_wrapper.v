`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/08/2026 02:01:56 PM
// Design Name: 
// Module Name: dcp_axi_wrapper
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


module dcp_axi_wrapper #(
        parameter IMG_WIDTH  = 512, 
    parameter IMG_HEIGHT = 512  
)(
    input  wire        aclk,
    input  wire        aresetn,      
    
    input  wire [23:0] s_axis_tdata,
    input  wire        s_axis_tvalid,
    output wire        s_axis_tready,
    input  wire        s_axis_tlast, 
    input  wire        s_axis_tuser, 
    
    output wire [23:0] m_axis_tdata,
    output wire        m_axis_tvalid,
    input  wire        m_axis_tready,
    output wire        m_axis_tlast,
    output wire        m_axis_tuser
);

    wire [23:0] dcp_out_data;
    wire        dcp_out_valid;
    
    wire rst_high = ~aresetn;

    assign s_axis_tready = m_axis_tready; 

    dcp_top u_dcp_top (
        .i_clk         (aclk),
        .i_rst         (rst_high),
        .i_pixel_data  (s_axis_tdata),
        .i_pixel_valid (s_axis_tvalid & s_axis_tready), 
        .o_pixel_data  (dcp_out_data),
        .o_pixel_valid (dcp_out_valid)
    );

    assign m_axis_tdata  = dcp_out_data;
    assign m_axis_tvalid = dcp_out_valid;

    reg [11:0] x_cnt;
    reg [11:0] y_cnt;

    always @(posedge aclk) begin
        if (~aresetn) begin
            x_cnt <= 12'd0;
            y_cnt <= 12'd0;
        end else if (dcp_out_valid && m_axis_tready) begin
            if (x_cnt == IMG_WIDTH - 1) begin
                x_cnt <= 12'd0;
                if (y_cnt == IMG_HEIGHT - 1)
                    y_cnt <= 12'd0;
                else
                    y_cnt <= y_cnt + 1;
            end else begin
                x_cnt <= x_cnt + 1;
            end
        end
    end

    assign m_axis_tlast = (x_cnt == IMG_WIDTH - 1);
    
    assign m_axis_tuser = (x_cnt == 0 && y_cnt == 0);

endmodule