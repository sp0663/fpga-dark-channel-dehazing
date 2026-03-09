`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/08/2026 11:51:25 AM
// Design Name: 
// Module Name: tb
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


`timescale 1ns / 1ps

module tb();
    parameter CLK_PERIOD = 10;  // 100MHz clock
    parameter IMG_WIDTH = 512;
    parameter IMG_HEIGHT = 512;
    parameter TOTAL_PIXELS = IMG_WIDTH * IMG_HEIGHT;

    // Testbench signals
    reg clk;
    reg rst;
    
    // AXI Slave signals (TB drives to DUT)
    reg [23:0] pixel_in;
    reg        pixel_valid;
    wire       pixel_ready;
    reg        pixel_tlast;
    reg        pixel_tuser;

    // AXI Master signals (DUT drives to TB)
    wire [23:0] pixel_out;
    wire        pixel_out_valid;
    wire        pixel_out_tlast;
    wire        pixel_out_tuser;
    reg         m_ready; 

    // Memory to store input/output images
    reg [23:0] input_image [0:TOTAL_PIXELS-1];
    reg [23:0] output_image [0:TOTAL_PIXELS-1];

    integer i;
    integer output_file;
    integer output_count;

    // Instantiate DUT (Device Under Test) 
    dcp_axi_wrapper #(
        .IMG_WIDTH(IMG_WIDTH),
        .IMG_HEIGHT(IMG_HEIGHT)
    ) dut (
        .aclk(clk),
        .aresetn(~rst),      // AXI standard uses active-low reset 
        .s_axis_tdata(pixel_in),
        .s_axis_tvalid(pixel_valid),
        .s_axis_tready(pixel_ready),
        .s_axis_tlast(pixel_tlast),  // End of line indicator 
        .s_axis_tuser(pixel_tuser),  // Start of frame indicator 
        .m_axis_tdata(pixel_out),
        .m_axis_tvalid(pixel_out_valid),
        .m_axis_tready(m_ready),
        .m_axis_tlast(pixel_out_tlast),
        .m_axis_tuser(pixel_out_tuser)
    );

    // Clock generation
    initial begin
        clk = 0;
        forever #(CLK_PERIOD/2) clk = ~clk;
    end

    // Test sequence
    initial begin
        // Initialize
        rst = 1;
        pixel_in = 24'h0;
        pixel_valid = 0;
        pixel_tlast = 0;
        pixel_tuser = 0;
        m_ready = 1; // Testbench is always ready to receive 
        output_count = 0;
        
        // Load input image from hex file
        $display("Loading input image...");
        $readmemh("input_image.hex", input_image);
        $display("Input image loaded!");
        
        // Reset
        #(CLK_PERIOD*10);
        rst = 0;
        #(CLK_PERIOD*5);
        
        $display("Starting image processing...");
        
        // Feed pixels one by one
        for (i = 0; i < TOTAL_PIXELS; i = i + 1) begin
            pixel_in = input_image[i];
            pixel_valid = 1;
            
            // AXI Video Framing
            pixel_tuser = (i == 0); // Start of frame on very first pixel
            pixel_tlast = ((i + 1) % IMG_WIDTH == 0); // End of line
            
            @(posedge clk);
            
            // AXI Handshake: Wait if DUT is not ready [cite: 7, 8]
            while (!pixel_ready) begin
                @(posedge clk);
            end
        end
        
        // Feed flush pixels to clear the pipeline
        for (i = 0; i < 3584; i = i + 1) begin  
            pixel_in = 24'h0;  
            pixel_valid = 1;   
            pixel_tuser = 0;
            pixel_tlast = ((i + 1) % IMG_WIDTH == 0);
            
            @(posedge clk);
            while (!pixel_ready) begin
                @(posedge clk);
            end
        end
        
        // Stop feeding pixels
        pixel_valid = 0;
        pixel_tlast = 0;
        pixel_tuser = 0;
        
        $display("All input pixels sent!");
        $display("Waiting for pipeline to flush...");
        
        // Wait for pipeline to finish (enough time for all outputs)
        #(CLK_PERIOD * 20000);  // Adjust if needed
        
        $display("Simulation complete!");
        $display("Total output pixels: %d", output_count);
        
        // Write output to file
        output_file = $fopen("output_image.hex", "w");
        for (i = 0; i < output_count; i = i + 1) begin
            $fwrite(output_file, "%06X\n", output_image[i]);
        end
        $fclose(output_file);
        
        $display("Output written to output_image.hex");
        
        // Display internal signals by tapping into the instantiated module 
        $display("=== Final Atmospheric Light Values ===");
        $display("A_r: %d", dut.u_dcp_top.A_r);
        $display("A_g: %d", dut.u_dcp_top.A_g);
        $display("A_b: %d", dut.u_dcp_top.A_b);
        $display("A_min: %d", dut.u_dcp_top.A_min);
        
        $finish;
    end

    // Capture output pixels
    always @(posedge clk) begin
        if (pixel_out_valid && m_ready) begin
            output_image[output_count] <= pixel_out;
            output_count <= output_count + 1;
            
            if (output_count % 10000 == 0 && output_count > 0)
                $display("Captured %d pixels...", output_count);
        end
    end

endmodule