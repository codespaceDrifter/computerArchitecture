`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/11/2024 07:17:22 PM
// Design Name: 
// Module Name: ex_wb_buffer
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


module ex_wb_buffer(input clock,
                    input in_mem_to_reg, 
                    input in_reg_wrt, 
                    input [31:0] in_alu_output, 
                    input [31:0] in_data_mem_output, 
                    input [5:0] in_rd,
                    output reg out_mem_to_reg,
                    output reg out_reg_wrt,
                    output reg [31:0] out_alu_output, 
                    output reg [31:0] out_data_mem_output,
                    output reg [5:0] out_rd );
initial begin
    out_mem_to_reg = 0;
    out_reg_wrt = 0;
    out_alu_output = 0;
    out_data_mem_output = 0;
    out_rd = 0;
end

always@(posedge clock)
begin
    out_mem_to_reg <= in_mem_to_reg;
    out_reg_wrt <= in_reg_wrt;
    out_alu_output <= in_alu_output;
    out_data_mem_output <= in_data_mem_output;
    out_rd <= in_rd;
end
              
endmodule
