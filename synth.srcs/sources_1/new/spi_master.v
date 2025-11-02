`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 31.10.2025 04:11:51
// Design Name: 
// Module Name: spi_master
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


// mode 0 SPI master (CPOL = 0, CPHA = 0)
// assuming that tx_byte remains unchanged throughout the transfer operation
module spi_master(
    input rst,
    input clk,

    input [7:0] tx_byte,
    input tx_valid, // tx byte is valid and must be sent out next
    output reg tx_ready, // master is ready to send the next byte 

    output reg [7:0] rx_byte, // received byte 
    output reg rx_valid, // rx_byte can be read now 

    // spi stuff 
    output reg sclk,
    output reg ss,
    output reg mosi,
    input miso
);

    localparam IDLE = 3'd0;
    localparam PRE_DELAY = 3'd1;
    localparam TRANS = 3'd2;
    localparam BYTE_DELAY = 3'd3;
    localparam POST_DELAY = 3'd4;
    

    reg [2:0] state;
    reg [2:0] byte_indexer;
    reg [7:0] clk_div_counter;
    reg [16:0] multi_purpose_counter;

    always @(posedge clk or posedge rst)
    begin
        if(rst)
        begin
            state <= IDLE;
            ss <= 1;
            mosi <= 0;
            tx_ready <= 0;
            byte_indexer <= 7;
            sclk <= 0;
            rx_valid <= 0;
            clk_div_counter <= 0;
            rx_byte <= 0;
        end
        else
        begin
        case(state)
            IDLE:
            begin
                tx_ready <= 1;
                if(tx_valid)
                begin
                    byte_indexer <= 7;
                    tx_ready <= 0;
                    ss <= 0;
                    rx_valid <= 0;
                    clk_div_counter <= 0;
                    multi_purpose_counter <= 0;
                    mosi <= tx_byte[7];
                    state <= PRE_DELAY;
                end
            end
            
            // multi_purpose_counter purpose - for delay (1500 clock cycles - 15 us)
            PRE_DELAY:   // delay after pulling SS low
            begin
                if(multi_purpose_counter == 16'd1499)
                begin
                    state <= TRANS;
                    multi_purpose_counter <= 0;
                    byte_indexer <= byte_indexer - 1;
                end
                else
                begin
                    multi_purpose_counter <= multi_purpose_counter + 1;
                end
            end
            
            // multi_purpose_counter purpose - to keep track of sclk edges (should be 16 for 1 byte transferred)
            TRANS:
            begin
                clk_div_counter <= clk_div_counter + 1;
                
                
                if(clk_div_counter == 8'd49)  // 100 clock cycles - 1 sclk clock cycle (toggle every 50th clock cycle)
                begin
                    clk_div_counter <= 0;
                    sclk <= ~sclk;
                    multi_purpose_counter <= multi_purpose_counter + 1;
                    
                    if(sclk == 0) // next is 1 (rising edge) (sample miso)
                    begin
                        rx_byte <= {rx_byte[6:0], miso};
                    end
                    else // next is 0 (falling edge) (shift mosi)
                    begin
                        mosi <= tx_byte[byte_indexer]; 
                        byte_indexer <= byte_indexer - 1;
                    end
                    
                    if (multi_purpose_counter == 15) // one byte transferred
                    begin
                        rx_valid <= 1;
                        tx_ready <= 1; // ready to transfer next byte
                        state <= BYTE_DELAY;
                        multi_purpose_counter <= 0;
                    end
                end
                
                
            end
            
            
            // multi_purpose_counter purpose - for delay (1000 clock cycles - 10 us)
            BYTE_DELAY:
            begin
                rx_valid <= 0;
                if(multi_purpose_counter == 16'd999)
                begin
                    if(tx_valid) //more bytes to be sent
                    begin
                        byte_indexer <= 6;
                        tx_ready <= 0;
                        clk_div_counter <= 0;
                        state <= TRANS;
                        mosi <= tx_byte[7];
                        multi_purpose_counter <= 0;
                    end
                    else // end transaction
                    begin
                        ss <= 1;
                        state <= POST_DELAY;
                        multi_purpose_counter <= 0;
                    end
                end
                else
                begin
                    multi_purpose_counter <= multi_purpose_counter + 1;
                end
            end
            
            // multi_purpose_counter purpose - for delay (2500 clock cycles - 25 us)
            POST_DELAY:
            begin
                if(multi_purpose_counter == 16'd2499)
                begin
                    state <= IDLE;
                    multi_purpose_counter <= 0;
                    tx_ready <= 1;
                end
                else
                begin
                    multi_purpose_counter <= multi_purpose_counter + 1;
                end
            end
        endcase
        end
    end     
endmodule
