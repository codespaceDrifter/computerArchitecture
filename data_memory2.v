//`timescale 1ns / 1ps
////////////////////////////////////////////////////////////////////////////////////
//// Company: 
//// Engineer: 
//// 
//// Create Date: 02/07/2024 08:41:27 PM
//// Design Name: 
//// Module Name: data_memory
//// Project Name: 
//// Target Devices: 
//// Tool Versions: 
//// Description: 
//// 
//// Dependencies: 
//// 
//// Revision:
//// Revision 0.01 - File Created
//// Additional Comments:
//// 
////////////////////////////////////////////////////////////////////////////////////


//module data_memory(output reg [31:0] data_out, 
//                   input [31:0]  data_in, 
//                   input [31:0] address, 
//                   input read, 
//                   input write, 
//                   input clk);
//// Limit memory to 2^16 address for simulation purposes
//reg [31:0] memory [65535:0];

//integer ii;
//initial
//begin
//    data_out = 0;
//    // Zero-initialise entire memory
//    for (ii = 0; ii < 65536; ii = ii + 1) memory[ii] = 0;

//    // Array a : [-9, -12, 6, 11, 0, -10, 4]  at addresses 2-8
//    memory[2]  = -9;
//    memory[3]  = -12;
//    memory[4]  =  6;
//    memory[5]  =  11;
//    memory[6]  =  0;
//    memory[7]  = -10;
//    memory[8]  =  4;

//    // Array b : [-2, 7, -9, 16, -32, -10, 0]  at addresses 12-18
//    memory[12] = -2;
//    memory[13] =  7;
//    memory[14] = -9;
//    memory[15] =  16;
//    memory[16] = -32;
//    memory[17] = -10;
//    memory[18] =  0;
//end


//always@(negedge clk)
//begin
//    if(read == 1)begin
//        data_out = memory[address[15:0]];
//    end
    
//    if(write == 1)begin
//        memory[address[15:0]] = data_in;
//    end
//end

//endmodule