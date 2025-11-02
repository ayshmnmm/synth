`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 01.11.2025 10:40:04
// Design Name: 
// Module Name: jstk2_interface
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


module jstk2_interface(
    input clk,
    input rst,
    input en,
    
    output reg [9:0] smpX_latest,
    output reg [9:0] smpY_latest,
    output reg [7:0] fsButtons_latest,
    output reg done,
    
    output pmod_sclk,
    output pmod_ss,
    output pmod_mosi,
    input  pmod_miso
    );
    
    reg [9:0] smpY, smpX;
    reg [7:0] fsButtons;
    reg [7:0] tx_byte;
    wire [7:0] rx_byte;
    reg tx_valid;
    wire rx_valid, tx_ready;
    
    spi_master sm (
        .rst(rst),
        .clk(clk),
        .tx_byte(tx_byte),
        .tx_valid(tx_valid),
        .tx_ready(tx_ready),
        .rx_byte(rx_byte),
        .rx_valid(rx_valid),
        .sclk(pmod_sclk),
        .ss(pmod_ss),
        .mosi(pmod_mosi),
        .miso(pmod_miso)
    );
    
    localparam IDLE = 2'd0;
    localparam TRANS = 2'd1;
    localparam BYTE_DONE = 2'd2;
    localparam DONE = 2'd3;
    
    reg [1:0] state;
    reg [7:0] byte_counter;  // current byte sequence num being transmitted
    
    always @(posedge clk or posedge rst)
    begin
        if(rst)
        begin
            tx_byte <= 8'b0;
            tx_valid <= 0;
            smpX <= 10'b0;
            smpY <= 10'b0;
            smpX_latest <= 10'b0;
            smpY_latest <= 10'b0;
            fsButtons <= 8'b0;
            byte_counter <= 8'b0;
            done <= 0;
            state <= IDLE;
        end
        else
        begin
            case(state)
                IDLE:
                begin
                    if(en)
                    begin
                        byte_counter <= 8'd0;
                        state <= TRANS;
                    end
                end
                
                TRANS:
                begin
                    if(tx_ready)
                    begin
                        case(byte_counter)
                            8'd0,8'd1,8'd2,8'd3,8'd4:
                            begin
                                tx_byte <= 8'b0;
                                tx_valid <= 1;     // start transfer of byte and wait for rx_valid
                            end
                        endcase
                        
                        state <= BYTE_DONE;
                    end
                end
                
                BYTE_DONE:
                begin
                    if(rx_valid)
                    begin
                        tx_valid <= 0;
                        case(byte_counter)
                            8'd0:
                            begin
                                smpX[7:0] <= rx_byte;
                            end
                            
                            8'd1:
                            begin
                                smpX[9:8] <= rx_byte;
                            end
                            
                            8'd2:
                            begin
                                smpY[7:0] <= rx_byte;
                            end
                            
                            8'd3:
                            begin
                                smpY[9:8] <= rx_byte;
                            end
                            
                            8'd4:
                            begin
                                fsButtons <= rx_byte;
                            end
                        endcase
                        
                        byte_counter <= byte_counter + 1;
                        if(byte_counter == 8'd4) // last byte of the transaction has been received
                        begin
                            tx_valid <= 0;
                            smpX_latest <= smpX;
                            smpY_latest <= smpY;
                            fsButtons_latest <= fsButtons;
                            done <= 1;
                            state <= DONE;
                        end
                        else
                        begin
                            state <= TRANS;
                        end
                    end
                end
                
                DONE:
                begin
                    done <= 0;
                    state <= IDLE; // TODO: implement delay
                end
            endcase
        end
    end
endmodule
