`timescale 1ns / 1ps

module tb_cpu_demo();
reg clock;

// All net declarations up front to avoid forward references / implicit 1-bit nets
wire [31:0] pc_in, pc_out, i_cache_out;
wire [31:0] if_instruction_out, if_pc_out;

wire reg_wrt, alu_src, save_pc, mem_wrt, mem_rd, mem_2_reg, branch_neg, branch_zero, jump;
wire [2:0] alu_op;
wire [31:0] xrs, xrt, immidiate, pc_adder_out;
wire pc_mux_select;
wire branch_N, branch_Z;

wire id_reg_wrt, id_alu_src, id_mem_2_reg, id_mem_wrt, id_mem_rd, id_save_pc;
wire [2:0] id_alu_op;
wire [31:0] id_pc, id_imm, id_xrs, id_xrt;
wire [5:0] id_rd;

wire Z, N;
wire [31:0] b_src_mux_out, a_src_mux_out, alu_out, data_out;

wire ex_reg_wrt, ex_mem_2_reg;
wire [5:0] ex_rd;
wire [31:0] ex_alu_out, ex_data_out;

wire [31:0] xrd;

// Branch / jump PC mux select
and(branch_N, branch_neg, N);
and(branch_Z, branch_zero, Z);
or(pc_mux_select, branch_N, branch_Z, jump);

// IF stage
PC Program_Counter(pc_in, pc_out, clock);
instruction_memory_demo i_cache(i_cache_out, pc_out[7:0], clock);

// IF/ID buffer
if_id_buffer if_stage(clock, i_cache_out, pc_out, if_instruction_out, if_pc_out);

// ID stage
control_unit control(if_instruction_out[31:28], reg_wrt, alu_src, alu_op, save_pc, mem_wrt, mem_rd, mem_2_reg, branch_neg, branch_zero, jump);
register_file reg_file(xrt, xrs, xrd, ex_rd, if_instruction_out[15:10], if_instruction_out[21:16], ex_reg_wrt, clock);
imm_generator imm_gen(if_instruction_out, immidiate);
adder32 pc_adder(pc_out, 32'd1, pc_adder_out);
TwoToOneMux pc_mux(pc_adder_out, xrs, pc_mux_select, pc_in);

// ID/EX buffer
id_ex_buffer id_stage(clock, reg_wrt, mem_2_reg, mem_wrt, mem_rd, alu_op, alu_src, save_pc, if_pc_out, immidiate, xrs, xrt, if_instruction_out[27:22],
                      id_reg_wrt, id_mem_2_reg, id_mem_wrt, id_mem_rd, id_alu_op, id_alu_src, id_save_pc, id_pc, id_imm, id_xrs, id_xrt, id_rd);

// EX stage
TwoToOneMux alu_b_src_mux(.A(id_xrt), .B(id_imm), .select(id_alu_src), .out(a_src_mux_out));
TwoToOneMux alu_a_src_mux(id_xrs, id_pc, id_save_pc, b_src_mux_out);
ALU alu(a_src_mux_out, b_src_mux_out, id_alu_op, alu_out, Z, N);
data_memory d_cache(data_out, id_xrt, id_xrs, id_mem_rd, id_mem_wrt, clock);

// EX/WB buffer
ex_wb_buffer ex_stage(clock, id_mem_2_reg, id_reg_wrt, alu_out, data_out, id_rd, ex_mem_2_reg, ex_reg_wrt, ex_alu_out, ex_data_out, ex_rd);

// WB stage
TwoToOneMux mem_2_reg_mux(ex_alu_out, ex_data_out, ex_mem_2_reg, xrd);

initial
begin
    clock = 0;
    forever #2 clock = ~clock;
end

initial
begin
    $monitor("time=%0t pc_out=%0d instr=%h x1=%0d x10=%0d x11=%0d x12=%0d x13=%0d", $time, pc_out, if_instruction_out, reg_file.registers[1], reg_file.registers[10], reg_file.registers[11], reg_file.registers[12], reg_file.registers[13]);
end

initial
begin
    #1200;

    $display("");
    $display("=================================================");
    $display("            CPU DEMO ASSEMBLY TEST RESULTS");
    $display("=================================================");
    $display("Expecting the demo assembly register values after the program has executed.");
    $display("-------------------------------------------------");
    $display("x1 = %0d   (expected 100)", $signed(reg_file.registers[1]));
    $display("x2 = %0d   (expected 104)", $signed(reg_file.registers[2]));
    $display("x3 = %0d   (expected -100)", $signed(reg_file.registers[3]));
    $display("x4 = %0d   (expected 210)", $signed(reg_file.registers[4]));
    $display("x5 = %0d   (expected 100)", $signed(reg_file.registers[5]));
    $display("x6 = %0d   (expected 204)", $signed(reg_file.registers[6]));
    $display("x7 = %0d   (expected 0)", $signed(reg_file.registers[7]));
    $display("x8 = %0d   (expected 214)", $signed(reg_file.registers[8]));
    $display("x9 = %0d   (expected 95)", $signed(reg_file.registers[9]));
    $display("Mem[100] = %0d   (expected 100)", $signed(d_cache.memory[100]));
    $display("-------------------------------------------------");

    if (reg_file.registers[1] === 32'd100 &&
        reg_file.registers[2] === 32'd104 &&
        reg_file.registers[3] === -32'd100 &&
        reg_file.registers[4] === 32'd210 &&
        reg_file.registers[5] === 32'd100 &&
        reg_file.registers[6] === 32'd204 &&
        reg_file.registers[7] === 32'd0 &&
        reg_file.registers[8] === 32'd214 &&
        reg_file.registers[9] === 32'd95 &&
        d_cache.memory[100] === 32'd100)
        $display("                >>> PASS <<<");
    else
        $display("                >>> FAIL <<<");

    $display("=================================================");
    $finish;
end

endmodule
