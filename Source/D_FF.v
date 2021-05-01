`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/30/2021 02:43:55 PM
// Design Name: 
// Module Name: D_FF
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


module D_FF(
    input clk, reset_n,
    input D,
    output Q
    );
    
    reg Q_reg;
    wire Q_next;
    
    always @(posedge clk, negedge reset_n)
    begin
        if(~reset_n)
            Q_reg <= 'b0;
        else
            Q_reg <= Q_next;
    end
    
    //Next State Logic
    assign Q_next = D;
    
    //Output Logic
    assign Q = Q_reg;
endmodule
