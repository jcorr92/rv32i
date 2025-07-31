`timescale 1ns/1ps
`default_nettype none

module top
import rv32i_pkg::*;
(
    `ifdef SIMULATION
    input wire logic                             preload_en_data,
    input wire logic                             preload_en_instr,
    input wire logic [INSTR_MEM_ADDR_WIDTH-1 :0] preload_addr,
    input wire logic [INSTR_MEM_DATA_WIDTH-1 :0] preload_data,
    `endif
    input wire logic clk, areset_n

);

// Wires
wire [XLEN-1          :0] next_pc, alu_out, pc, pc_plus_4, dmem_out, wdata;
wire [XLEN-1          :0] rs1, rs2, reg_wData, imm_out, alu_2_in;
wire [ILEN-1          :0] instr;
wire [REG_ADDR_WIDTH-1:0] rs1_addr, rs2_addr, rd_addr;
wire zero;

// Control signals
logic memRead, aluSrc, jump, branch, branchCtrl, memWrite, regWrite, aluOp;
logic [1:0] mem2Reg;
logic [3:0] aluCtrl;
// Registers
logic alu_sel = 0;

// Module Instantiations
// Instruction Memory
generic_memory
#(.MEM_SIZE(INSTR_MEM_WORDS))
u_instruction_memory (
    .clk     (clk),
    .aresetn (areset_n),
    .funct3  (instr[14:12]),
    `ifdef SIMULATION
    .preload_en   (preload_en_instr),
    .preload_addr (preload_addr),
    .preload_data (preload_data),
    `endif
    // rd interface
    .rd_data (instr),
    .rd_addr (pc),
    .error   ()
);

imm_gen u_imm_gen(
    .imm_out(imm_out),
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
    .wdata    (reg_wData ),
    .rd_addr1 (rs1_addr  ),
    .rd_addr2 (rs2_addr  ),
    .wr_addr  (rd_addr   ),
    .clk      (clk       ),
    .aresetn  (areset_n  ),
    .wr_en    (regWrite  )
);

// conditional branch logic
assign branch = ((zero | alu_out[0]) & branchCtrl);
// pc mux
assign next_pc = (jump | branch) ? pc + imm_out : pc_plus_4;

pc u_pc(
    .pc        (pc        ),
    .pc_plus_4 (pc_plus_4 ),
    .next_pc   (next_pc   ),
    .clk       (clk       ),
    .rst       (areset_n  )
);

assign alu_2_in = aluSrc ? imm_out : rs2;

alu u_alu(
    .result    (alu_out ),
    .zero      (zero    ),
    .src_a     (rs1     ),
    .src_b     (alu_2_in ),
    .alu_ctrl  (aluCtrl )
);

// Data Memory
generic_memory
#(.DATA_MEM(1),
  .MEM_SIZE(DATA_MEM_WORDS)
) u_data_memory (
    .clk     (clk),
    .aresetn (areset_n),
    .funct3  (instr[14:12]),
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
    .wr_en   (memWrite),
    .error   ()
);

// // writeback mux
assign reg_wData = (mem2Reg == 2'b00) ? alu_out     :
                   (mem2Reg == 2'b01) ? dmem_out    :
                   (mem2Reg == 2'b10) ? pc_plus_4   :
                   32'bx; // default / don't care
// controller
instr_decoder u_instr_decoder(
    .instr      (instr),
    .memRead    (memRead),
    .aluSrc     (aluSrc),
    .aluOp      (aluOp),
    .jump       (jump),
    .branchCtrl (branchCtrl),
    .memWrite   (memWrite),
    .mem2Reg    (mem2Reg),
    .regWrite   (regWrite)
);
endmodule