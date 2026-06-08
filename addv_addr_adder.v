`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Module Name: addv_addr_adder
// Description: Combinational base + count adder with internal 2:1 base mux.
//              base_sel = 0 -> xrs + count   (used in LOAD_A / STORE)
//              base_sel = 1 -> xrt + count   (used in LOAD_B)
//////////////////////////////////////////////////////////////////////////////////


module addv_addr_adder(input [31:0] xrs,
                       input [31:0] xrt,
                       input [31:0] count,
                       input base_sel,
                       output reg [31:0] addr);

always@(*)
begin
    case(base_sel)
        1'b0: addr = xrs + count;
        1'b1: addr = xrt + count;
    endcase
end
endmodule
