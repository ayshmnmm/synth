`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 01.11.2025 11:55:30
// Design Name: 
// Module Name: jstk2_interface_tb
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


module jstk2_interface_tb;
    // --- Testbench signals ---
    reg clk;
    reg rst;
    reg en;
    
    wire [9:0] smpX, smpY;
    wire [7:0] fsButtons;
    wire done;
    
    wire pmod_sclk;
    wire pmod_ss;
    wire pmod_mosi;
    wire pmod_miso; // This is an output from the slave, so it's a wire here

    // --- Instantiate the Device Under Test (DUT) ---
    jstk2_interface uut (
        .clk(clk),
        .rst(rst),
        .en(en),
        .done(done),
        .smpX_latest(smpX),
        .smpY_latest(smpY),
        .fsButtons_latest(fsButtons),
        .pmod_sclk(pmod_sclk),
        .pmod_ss(pmod_ss),
        .pmod_mosi(pmod_mosi),
        .pmod_miso(pmod_miso)
    );
    
    // --- Clock Generation (100MHz) ---
    always #5 clk = ~clk; 
    
    // --- SPI Slave Model (Unaltered logic, as requested) ---
    reg [7:0] slave_shift_reg;
    
    // Note: Corrected signal names from sclk/ss/mosi to pmod_sclk/pmod_ss/pmod_mosi
    always @(negedge pmod_sclk or posedge pmod_ss) begin
        if (pmod_ss) begin
            slave_shift_reg <= 8'hA4; // Load slave with a known value
        end else begin
            slave_shift_reg <= {slave_shift_reg[6:0], slave_shift_reg[7]};
        end
    end
    
    // Corrected signal names from miso to pmod_miso
    assign pmod_miso = slave_shift_reg[7]; // Slave sends out MSB
    
    
    // --- Test Sequence ---
    initial
    begin
        // Initialize Inputs
        clk = 0;
        rst = 1;
        en = 0;

        // Reset the DUT
        #20;
        rst = 0;
        #20;

        $display("Time: %0t ns -> Testbench started. Sending 'en' pulse.", $time);
        
        // Send a single-cycle 'en' pulse to start the interface
        en <= 1;
        #10; // 1 clock cycle
        en <= 0;

        $display("Time: %0t ns -> 'en' pulse sent. Waiting for 'data_valid'...", $time);

        // Wait for the DUT to signal it has completed a transaction
        wait(done);
                
        $display("Time: %0t ns -> 'data_valid' was asserted!", $time);
        
        // Display the data received. 
        // Note: This data will be garbage because the slave model isn't
        // sending the correct JSTK2 response. This is expected.
        $display("Data: X=0x%h, Y=0x%h, Buttons=0x%b", smpX, smpY, fsButtons);

        // End of simulation
        #100; // Wait a bit to see signals in the waveform
        $display("Time: %0t ns -> Testbench finished.", $time);
        $finish;
    end
endmodule
