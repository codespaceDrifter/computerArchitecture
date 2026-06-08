`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Module Name: register_file_addv
// Description: Same register file as the original, but with a third combinational
//              read port (rd_val_out). ADDV needs to read three operands from the
//              register file in the ID stage: xrs (array A base), xrt (array B
//              base), and xrd (loop bound n-1). This module adds the rd read
//              port without disturbing the existing rs/rt ports.
//////////////////////////////////////////////////////////////////////////////////


module register_file_addv(output reg [31:0] rt_out,
                          output reg [31:0] rs_out,
                          output reg [31:0] rd_val_out,
                          input [31:0] data_in,
                          input [5:0] rd_write_addr,
                          input [5:0] rt_addr,
                          input [5:0] rs_addr,
                          input [5:0] rd_read_addr,
                          input write,
                          input clk);

reg [31:0] registers [63:0];

integer ii;
initial
begin
    rt_out = 0;
    rs_out = 0;
    rd_val_out = 0;
    for (ii = 0; ii < 64; ii = ii + 1) registers[ii] = 0;
end

always@(negedge clk)
begin
    rt_out = registers[rt_addr];
    rs_out = registers[rs_addr];
    rd_val_out = registers[rd_read_addr];
    if (write)
        registers[rd_write_addr] = data_in;
end
endmodule
