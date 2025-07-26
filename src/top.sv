`timescale 1ns/1ps

module top
import rv32i_pkg::*;
(
    input clk, areset_n,
    `ifdef SIMULATION
    input logic                             preload_en_data,
    input logic                             preload_en_instr,
    input logic [INSTR_MEM_ADDR_WIDTH-1 :0] preload_addr,
    input logic [INSTR_MEM_DATA_WIDTH-1 :0] preload_data,
    `endif
);

// Wires
wire [XLEN-1          :0] next_pc, alu_out, pc;
wire [XLEN-1          :0] rs1, rs2, mem2reg, imm;
wire [ILEN-1          :0] instr;
wire [REG_ADDR_WIDTH-1:0] rs1_addr, rs2_addr, rd_addr;
wire zero;
// Control signals
logic memRead, aluSrc, aluCtrl;

// Registers
logic alu_sel = 0;

// Module Instantiations
// Instruction Memory
generic_memory u_instruction_memory(
    .clk     (clk),
    .aresetn (areset_n),
    `ifdef SIMULATION
    .preload_en   (preload_en_instr),
    .preload_addr (preload_addr),
    .preload_data (preload_data),
    `endif
    // rd interface
    .rd_data (instr),
    .rd_addr (pc)
);

imm_gen u_imm_gen(
    .imm_out(imm),
    .instr_in(instr)
);

//rs1, rs2, rd hardwried from instruction
assign rs1_addr = instr[19:15];
assign rs2_addr = instr[24:20];
assign rd_addr  = instr[11: 7];

// mem input mux
assign wdata = alu_sel ? alu_out : rs2;

register_file u_register_file(
    .rdata1   (rs1       ),
    .rdata2   (rs2       ),
    .wdata    (wdata     ),
    .rd_addr1 (rs1_addr  ),
    .rd_addr2 (rs2_addr  ),
    .wr_addr  (rd_addr   ),
    .clk      (clk       ),
    .aresetn  (areset_n  ),
    .wr_en    (wr_en     )
);

assign next_pc = jump ? pc + imm : pc + 4;

pc u_pc(
    .pc      (pc      ),
    .next_pc (next_pc ),
    .clk     (clk     ),
    .rst     (areset_n)
);

assign alu_src = aluSrc ? imm_out : rs2;

alu u_alu(
    .result    (alu_out ),
    .zero      (zero    ),
    .src_a     (rs1     ),
    .src_b     (alu_src ),
    .alu_ctrl  (aluCtrl )
);

// Data Memory
generic_memory u_data_memory(
    .clk     (clk),
    .aresetn (areset_n),
    `ifdef SIMULATION
    .preload_en   (preload_en_data),
    .preload_addr (preload_addr),
    .preload_data (preload_data),
    `endif
    // rd interface
    .rd_data (dmem_out ),
    .rd_addr (alu_out  ),
    // write interface
    .wr_data (rs2     ),
    .wr_addr (alu_out ),
    .wr_en   (memRead )
);

// writeback mux
assign mem2reg = memWrite ? dmem_out : alu_out;

endmodule