`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/30/2021 10:59:16 AM
// Design Name: 
// Module Name: Morse2ASCII
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


module Morse2ASCII(
    input b, reset, read, clk,
    output emptyLED,
    output DP,
    output [6:0] SEG,
    output [7:0] AN
    );
    
    wire bDeb, readDeb, dot, dash, lg, wg, wg_delayed, full;
    wire [4:0] symbol;
    wire [2:0] symbol_count;
    wire [7:0] ROMaddress, ROMdata, FIFOout;
    
    button B (
        .clk(clk),
        .reset_n(~reset),
        .noisy(b),
        .debounced(bDeb)
    );
    
    button Read (
        .clk(clk),
        .reset_n(~reset),
        .noisy(read),
        .p_edge(readDeb)
    );
    
    morse_decoder_2 #(.TIMER_FINAL_VALUE(4_999_999)) MD (
        .clk(clk),
        .reset_n(~reset),
        .b(bDeb),
        .dot(dot),
        .dash(dash),
        .lg(lg),
        .wg(wg)
    );
    
    Shift_Register_nbit #(.N(5)) Shift (
        .clk(clk),
        .reset_n(~(lg | wg)),
        .SI(dash),
        .shift(dot ^ dash),
        .Q(symbol)
    );
    
    udl_counter #(.BITS(3)) Counter (
        .clk(clk),
        .reset_n(~(lg | wg)),
        .enable(dot ^ dash),
        .up(1'b1),
        .load(symbol_count == 3'd5),
        .D('b0),
        .Q(symbol_count)
    );
    
    D_FF FF0 (
        .clk(clk),
        .reset_n(~reset),
        .D(wg),
        .Q(wg_delayed)
    );
    
    mux_2x1_nbit #(.N(8)) MUX (
        .w0({symbol_count,symbol}),
        .w1(8'b1110_0000),
        .s(wg),
        .f(ROMaddress)
    );
    
    synch_rom ROM (
        .clk(clk),
        .addr(ROMaddress),
        .data(ROMdata)
    );
    
    //----------- Begin Cut here for INSTANTIATION Template ---// INST_TAG
    fifo_generator_0 FIFO0 (
      .clk(clk),      // input wire clk
      .srst(~reset),    // input wire srst
      .din(ROMdata),      // input wire [7 : 0] din
      .wr_en(~full & (lg | wg | wg_delayed)),  // input wire wr_en
      .rd_en(readDeb),  // input wire rd_en
      .dout(FIFOout),    // output wire [7 : 0] dout
      .full(full),    // output wire full
      .empty(emptyLED)  // output wire empty
    );
        
    sseg_driver Display (
        .I7({1'b1,FIFOout[7:4],1'b0}),
        .I6({1'b1,FIFOout[3:0],1'b0}),
        .I5(6'b0),
        .I4({4'b1000,symbol[4],1'b0}),
        .I3({4'b1000,symbol[3],1'b0}),
        .I2({4'b1000,symbol[2],1'b0}),
        .I1({4'b1000,symbol[1],1'b0}),
        .I0({4'b1000,symbol[0],1'b0}),
        .CLK100MHZ(clk),
        .SSEG(SEG),
        .AN(AN),
        .DP(DP)
    );
endmodule
