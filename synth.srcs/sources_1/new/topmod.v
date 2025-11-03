`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02.11.2025 03:09:36
// Design Name: 
// Module Name: topmod
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


module topmod(
    input clk,
    input rst,
    
    // pmod jstk2 ports
    input jstk_miso,
    output jstk_mosi,
    output jstk_sclk,
    output jstk_ss
);
    
    wire [9:0] x, y;
    wire [7:0] fsb;
        
    jstk2_interface jstk (
        .clk(clk),
        .rst(rst),
        .en(1'b1),
        .smpX_latest(x),
        .smpY_latest(y),
        .fsButtons_latest(fsb),
        .pmod_sclk(jstk_sclk),
        .pmod_ss(jstk_ss),
        .pmod_mosi(jstk_mosi),
        .pmod_miso(jstk_miso)
    );
    
    vio_0 detective_jstk (
      .clk(clk),              // input wire clk
      .probe_in0(x),  // input wire [9 : 0] probe_in0
      .probe_in1(y),  // input wire [9 : 0] probe_in1
      .probe_in2(fsb),  // input wire [7 : 0] probe_in2
      .probe_in3(jstk_sclk),  
      .probe_in4(jstk_ss),  
      .probe_in5(jstk_mosi),  
      .probe_in6(jstk_miso)  
    );
    
endmodule
