`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 31.10.2025 10:25:25
// Design Name: 
// Module Name: spi_master_tb
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


module spi_master_tb;
    reg clk;
    reg rst;
    reg [7:0] tx_byte;
    reg tx_valid;
    wire tx_ready;

    wire [7:0] rx_byte;
    wire rx_valid;

    wire sclk;
    wire ss;
    wire mosi;
    wire  miso;

    spi_master sm (
        .rst(rst),
        .clk(clk),
        .tx_byte(tx_byte),
        .tx_valid(tx_valid),
        .tx_ready(tx_ready),
        .rx_byte(rx_byte),
        .rx_valid(rx_valid),
        .sclk(sclk),
        .ss(ss),
        .mosi(mosi),
        .miso(miso)
    );
    
    always #5 clk = ~clk; // 10ns - 100Mhz clock
    
    // spi slave
    reg [7:0] slave_shift_reg;
    always @(negedge sclk or posedge ss) begin
        if (ss) begin
            slave_shift_reg <= 8'hA4; // Load slave with a known value
        end else begin
            slave_shift_reg <= {slave_shift_reg[6:0], mosi};
        end
    end
    assign miso = slave_shift_reg[7]; // Slave sends out MSB
    
    
    initial
    begin
        // Initialize Inputs
        clk = 0;
        rst = 1;
        tx_byte = 0;
        tx_valid = 0;

        // Reset the DUT
        #20;
        rst = 0;
        #20;

        // Wait for the master to be ready
        wait(tx_ready);
        $display("Time: %0t ns -> Master is ready.", $time);
        
        // --- Test Case 1: Send one byte ---
        tx_byte <= 8'h00;
        tx_valid <= 1;
//        #10; // Hold valid for one cycle
//        tx_valid <= 0;
        
        $display("Time: %0t ns -> Sent byte 0x%h. Waiting for completion...", $time, tx_byte);

        // Wait for the received byte to be valid
        wait(rx_valid);
        $display("Time: %0t ns -> Received byte 0x%h. Expected ~0xA5 based on slave model.", $time, rx_byte);
        #10;

        // Wait for master to be ready again for the next transaction
        wait(tx_ready);
        $display("Time: %0t ns -> Master is ready again.", $time);
        
        // --- Test Case 2: Send one byte ---
        tx_byte <= 8'hD1;
        tx_valid <= 1;
        
        
        $display("Time: %0t ns -> Sent byte 0x%h. Waiting for completion...", $time, tx_byte);

        // Wait for the received byte to be valid
        #10;
        wait(rx_valid);
        tx_valid <= 0;
        $display("Time: %0t ns -> Received byte 0x%h. Expected ~0xA5 based on slave model.", $time, rx_byte);

        // Wait for master to be ready again for the next transaction
        wait(tx_ready);
        $display("Time: %0t ns -> Master is ready again.", $time);
        
        // --- End of simulation ---
        #5000;
        $display("Time: %0t ns -> Testbench finished.", $time);
        $finish;
        
        #50000;
        
        $finish;
    end
endmodule
