`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Module Name: cpu_top_addv
// Description: Top-level pipelined CPU wrapper that adds ADDV support on top of
//              the existing 4-stage pipeline. The original CPU modules (PC,
//              if_id_buffer, control_unit, imm_generator, id_ex_buffer,
//              TwoToOneMux, adder32, ALU, data_memory, ex_wb_buffer) are reused
//              unchanged. The register file is swapped for register_file_addv
//              (adds a 3rd combinational read port for xrd). The instruction
//              memory is instruction_memory_addv (different program).
//
// ADDV hardware additions (all from new modular files):
//   - addv_fsm           : 4-state controller (IDLE/LOAD_A/LOAD_B/STORE)
//   - addv_counter       : 32-bit loop index i
//   - addv_addr_adder    : base + i (base = xrs or xrt)
//   - addr_mux_3to1      : 3:1 mux in front of data-memory address port
//   - addv_temp_reg x3   : temp_a, temp_b, and xrd-capture register
//
// Stall handling (no edits to existing PC/IF-ID buffer):
//   - PC stall via input-side TwoToOneMux that recirculates pc_out when
//     addv_stall is high.
//   - IF/ID stall via input-side TwoToOneMux that recirculates the buffer's
//     own outputs when addv_stall is high.
//////////////////////////////////////////////////////////////////////////////////


module cpu_top_addv(input clock);

// ------------- IF stage wires -------------
wire [31:0] pc_in, pc_out, i_cache_out;
wire [31:0] pc_adder_out, pc_normal_next;

// IF/ID buffer outputs
wire [31:0] if_instruction_out, if_pc_out;

// IF/ID buffer inputs (after stall mux)
wire [31:0] if_id_inst_in, if_id_pc_in;

// ------------- ID stage wires -------------
wire reg_wrt, alu_src, save_pc, mem_wrt, mem_rd, mem_2_reg;
wire branch_neg, branch_zero, jump;
wire [2:0] alu_op;
wire [31:0] xrs, xrt, xrd_val_raw, immidiate;
wire [31:0] xrs_captured, xrt_captured, xrd_captured;
wire pc_mux_select;
wire branch_N, branch_Z;

// ------------- ID/EX outputs -------------
wire id_reg_wrt, id_alu_src, id_mem_2_reg, id_mem_wrt, id_mem_rd, id_save_pc;
wire [2:0] id_alu_op;
wire [31:0] id_pc, id_imm, id_xrs, id_xrt;
wire [5:0] id_rd;

// ------------- EX stage wires -------------
wire Z, N;
wire [31:0] a_src_normal, b_src_normal;
wire [31:0] alu_a_final, alu_b_final;
wire [2:0] alu_op_eff;
wire [31:0] alu_out, data_out;
wire [31:0] mem_addr_eff, data_in_eff;
wire mem_read_eff, mem_write_eff;
wire [31:0] addr_adder_out, count;
wire [31:0] temp_a_val, temp_b_val;

// ------------- FSM signals -------------
wire addv_stall, fsm_mem_read, fsm_mem_write;
wire counter_reset, counter_en;
wire [1:0] addr_sel;
wire base_sel, temp_a_en, temp_b_en;
wire alu_a_sel, alu_b_sel, wd_sel;
wire [2:0] fsm_alu_op;
wire loop_done;

// ------------- EX/WB outputs -------------
wire ex_reg_wrt, ex_mem_2_reg;
wire [5:0] ex_rd;
wire [31:0] ex_alu_out, ex_data_out;

// ------------- WB -------------
wire [31:0] xrd_writeback;


// =================== IF stage ===================
PC Program_Counter(pc_in, pc_out, clock);
instruction_memory_addv i_cache(i_cache_out, pc_out[7:0], clock);

// Branch / jump PC mux select
and(branch_N, branch_neg, N);
and(branch_Z, branch_zero, Z);
or(pc_mux_select, branch_N, branch_Z, jump);

adder32 pc_adder(pc_out, 32'd1, pc_adder_out);
TwoToOneMux pc_branch_mux(pc_adder_out, xrs, pc_mux_select, pc_normal_next);
// Stall: when addv_stall is high, feed pc_out back into PC so it freezes
TwoToOneMux pc_stall_mux(pc_normal_next, pc_out, addv_stall, pc_in);


// =================== IF/ID stall mux + buffer ===================
TwoToOneMux if_id_inst_mux(i_cache_out, if_instruction_out, addv_stall, if_id_inst_in);
TwoToOneMux if_id_pc_mux  (pc_out,      if_pc_out,         addv_stall, if_id_pc_in);

if_id_buffer if_stage(clock, if_id_inst_in, if_id_pc_in, if_instruction_out, if_pc_out);


// =================== ID stage ===================
control_unit control(if_instruction_out[31:28],
                     reg_wrt, alu_src, alu_op, save_pc,
                     mem_wrt, mem_rd, mem_2_reg,
                     branch_neg, branch_zero, jump);

register_file_addv reg_file(.rt_out(xrt),
                            .rs_out(xrs),
                            .rd_val_out(xrd_val_raw),
                            .data_in(xrd_writeback),
                            .rd_write_addr(ex_rd),
                            .rt_addr(if_instruction_out[15:10]),
                            .rs_addr(if_instruction_out[21:16]),
                            .rd_read_addr(if_instruction_out[27:22]),
                            .write(ex_reg_wrt),
                            .clk(clock));

imm_generator imm_gen(if_instruction_out, immidiate);

// xrs/xrt/xrd capture: latch register-file outputs the same cycle ADDV is
// decoded (counter_reset is high in IDLE when opcode==0001). Held for the
// duration of the FSM run so addr_adder and loop_done stay valid even after
// the IF/ID + ID/EX have moved on to the post-ADDV instruction stream.
addv_temp_reg xrs_capture(.clock(clock),
                          .en(counter_reset),
                          .din(xrs),
                          .dout(xrs_captured));
addv_temp_reg xrt_capture(.clock(clock),
                          .en(counter_reset),
                          .din(xrt),
                          .dout(xrt_captured));
addv_temp_reg xrd_capture(.clock(clock),
                          .en(counter_reset),
                          .din(xrd_val_raw),
                          .dout(xrd_captured));


// =================== ID/EX buffer ===================
id_ex_buffer id_stage(clock,
                      reg_wrt, mem_2_reg, mem_wrt, mem_rd, alu_op, alu_src, save_pc,
                      if_pc_out, immidiate, xrs, xrt, if_instruction_out[27:22],
                      id_reg_wrt, id_mem_2_reg, id_mem_wrt, id_mem_rd,
                      id_alu_op, id_alu_src, id_save_pc,
                      id_pc, id_imm, id_xrs, id_xrt, id_rd);


// =================== EX stage ===================
// Normal ALU input muxes (preserve original wiring/semantics)
TwoToOneMux alu_b_src_mux(.A(id_xrt), .B(id_imm), .select(id_alu_src), .out(a_src_normal));
TwoToOneMux alu_a_src_mux(id_xrs, id_pc, id_save_pc, b_src_normal);

// ADDV STORE-state override muxes - inject temp_a/temp_b into the ALU
TwoToOneMux alu_a_override(a_src_normal, temp_a_val, alu_a_sel, alu_a_final);
TwoToOneMux alu_b_override(b_src_normal, temp_b_val, alu_b_sel, alu_b_final);

// In STORE the FSM forces ADD; otherwise the ID/EX-latched ALU op runs as normal.
assign alu_op_eff = alu_a_sel ? fsm_alu_op : id_alu_op;

ALU alu(alu_a_final, alu_b_final, alu_op_eff, alu_out, Z, N);

// ADDV datapath components
addv_counter counter(clock, counter_reset, counter_en, count);

// addr_adder uses the captured xrs/xrt (not id_xrs/id_xrt) because the
// ID/EX buffer gets overwritten by the NOPs that follow ADDV in IF/ID
// once the FSM kicks in.
addv_addr_adder addr_adder(.xrs(xrs_captured),
                           .xrt(xrt_captured),
                           .count(count),
                           .base_sel(base_sel),
                           .addr(addr_adder_out));

// 3:1 address mux in front of data-memory address port
addr_mux_3to1 mem_addr_mux(.in0(id_xrs),
                           .in1(addr_adder_out),
                           .in2(addr_adder_out),
                           .sel(addr_sel),
                           .out(mem_addr_eff));

// Override data-memory read/write enables when ADDV FSM is active
assign mem_read_eff  = addv_stall ? fsm_mem_read  : id_mem_rd;
assign mem_write_eff = addv_stall ? fsm_mem_write : id_mem_wrt;

// Memory write-data: ALU result during ADDV STORE, otherwise id_xrt (normal ST)
TwoToOneMux wd_mux(id_xrt, alu_out, wd_sel, data_in_eff);

data_memory d_cache(data_out, data_in_eff, mem_addr_eff,
                    mem_read_eff, mem_write_eff, clock);

// temp_a / temp_b: passively latch the data-memory output bus on the right cycle
addv_temp_reg temp_a(.clock(clock), .en(temp_a_en), .din(data_out), .dout(temp_a_val));
addv_temp_reg temp_b(.clock(clock), .en(temp_b_en), .din(data_out), .dout(temp_b_val));

// FSM
assign loop_done = (count == xrd_captured);

addv_fsm fsm(.clock(clock),
             .opcode(if_instruction_out[31:28]),
             .loop_done(loop_done),
             .addv_stall(addv_stall),
             .fsm_mem_read(fsm_mem_read),
             .fsm_mem_write(fsm_mem_write),
             .addr_sel(addr_sel),
             .base_sel(base_sel),
             .temp_a_en(temp_a_en),
             .temp_b_en(temp_b_en),
             .counter_reset(counter_reset),
             .counter_en(counter_en),
             .alu_a_sel(alu_a_sel),
             .alu_b_sel(alu_b_sel),
             .fsm_alu_op(fsm_alu_op),
             .wd_sel(wd_sel));


// =================== EX/WB buffer ===================
ex_wb_buffer ex_stage(clock, id_mem_2_reg, id_reg_wrt, alu_out, data_out, id_rd,
                      ex_mem_2_reg, ex_reg_wrt, ex_alu_out, ex_data_out, ex_rd);


// =================== WB stage ===================
TwoToOneMux mem_2_reg_mux(ex_alu_out, ex_data_out, ex_mem_2_reg, xrd_writeback);

endmodule
