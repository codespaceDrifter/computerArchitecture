`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Module Name: addr_mux_3to1
// Description: 3:1 32-bit MUX in front of the data-memory address port.
//              sel = 00 -> normal ALU/xrs address (non-ADDV)
//              sel = 01 -> addr_adder output (xrs+i in LOAD_A/STORE)
//              sel = 10 -> addr_adder output (xrt+i in LOAD_B)
//////////////////////////////////////////////////////////////////////////////////


module addr_mux_3to1(input [31:0] in0,
                     input [31:0] in1,
                     input [31:0] in2,
                     input [1:0] sel,
                     output reg [31:0] out);

always@(*)
begin
    case(sel)
        2'b00:   out = in0;
        2'b01:   out = in1;
        2'b10:   out = in2;
        default: out = in0;
    endcase
end
endmodule
