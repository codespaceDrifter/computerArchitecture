//`timescale 1ns / 1ps
////////////////////////////////////////////////////////////////////////////////////
//// Company: 
//// Engineer: 
//// 
//// Create Date: 02/07/2024 08:41:27 PM
//// Design Name: 
//// Module Name: instruction_memory
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


//module instruction_memory(output reg [31:0] instruction, input [7:0] address, input clk);
//reg [31:0] instructionMem [255:0];

//integer ii;
//initial
//begin
//    // Zero-init so uninitialized slots decode as NOP (avoids X propagation
//    // when PC walks past the program end on the BRZ x0 restart path).
//    for (ii = 0; ii < 256; ii = ii + 1) instructionMem[ii] = 32'b0;

//    // SVP x12, 25
//    instructionMem[0] = 32'b1111_001100__000000_000000_0000011001;
    
//    //ADD x5, x2, x3
//    instructionMem[1] = 32'b0100_000101_000010_000011_0000000000;

//    //SVPC x9, 2
//    instructionMem[2] = 32'b1111_001001_000000_000000_0000000010;

//    //SVPC x10, 11
//    instructionMem[3] = 32'b1111_001010_000000_000000_0000001011;

//    //LD x6, x2
//    instructionMem[4] = 32'b1110_000110_000010_000000_0000000000;

//   //NOP
//    instructionMem[5] = 32'b0000_000000_000000_000000_0000000000;

//   //NOP
//    instructionMem[6] = 32'b0000_000000_000000_000000_0000000000;

//    //SUB x7, x6, x4
//    instructionMem[7] = 32'b0111_000111_000110_000100_0000000000;

//    //BRN x10
//    instructionMem[8] = 32'b1011_000000_001010_000000_0000000000;
    
//    //NOP
//    instructionMem[9] = 32'b0000_000000_000000_000000_0000000000;
 
//    //SUB x4, x4, x4
//    instructionMem[10] = 32'b0111_000100_000100_000100_0000000000;

//    //NOP
//    instructionMem[11] = 32'b0000_000000_000000_000000_0000000000;

//    //NOP
//    instructionMem[12] = 32'b0000_000000_000000_000000_0000000000;

//    //ADD x4, x4, x6
//    instructionMem[13] = 32'b0100_000100_000100_000110_0000000000;

//    //INC x2, x2, 1
//    instructionMem[14] = 32'b0101_000010_000010_000000_0000000001;

//    //NOP
//    instructionMem[15] = 32'b0000_000000_000000_000000_0000000000;

//    //NOP
//    instructionMem[16] = 32'b0000_000000_000000_000000_0000000000;

//    //SUB x8, x2, x5
//    instructionMem[17] = 32'b0111_001000_000010_000101_0000000000;

//    //BRN x9
//    instructionMem[18] = 32'b1011_000000_001001_000000_0000000000;
 
//    //NOP
//    instructionMem[19] = 32'b0000_000000_000000_000000_0000000000;
    
//    // jump x12
//    instructionMem[20] = 32'b1000_000000_001100_000000_0000000000;
    
//    // NOP
//    instructionMem[21] = 32'b0000_000000_000000_000000_0000000000;
    
//    // NOP // this one shouldn't execute
//    instructionMem[22] = 32'b0000_000000_000000_000000_0000000000;
    
//    // NOP // this one shouldn't execute
//    instructionMem[23] = 32'b0000_000000_000000_000000_0000000000;
    
//    // NOP // this one shouldn't execute
//    instructionMem[24] = 32'b0000_000000_000000_000000_0000000000;
    
//    // ST x4, x0; // store max at mem[0]
//    instructionMem[25] = 32'b0011_000000_000000_000100_0000000000;
    
//    // NEG x13, x4 // store negate of max
//    instructionMem[26] = 32'b0110_001101_000100_000000_0000000000;
    
//    // NOP
//    instructionMem[27] = 32'b0000_000000_000000_000000_0000000000;
    
//    // NOP
//    instructionMem[28] = 32'b0000_000000_000000_000000_0000000000;
    
//    // add x15, x13, x4 // x15 should be zero
//    instructionMem[29] = 32'b0100_001111_001101_000100_0000000000;
    
//    // brz x0 // should return to start of program
//    instructionMem[30] = 32'b1001_000000_000000_000000_0000000000;

    

//end

//always@(*)
//begin
//    instruction = instructionMem[address];
//end

//endmodule