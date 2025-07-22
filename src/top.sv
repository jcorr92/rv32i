`timescale 1ns/1ps

module top
import rv32i_pkg::*;
(
    input clk, areset_n,
    `ifdef SIMULATION
    input logic                             preload_en,
    input logic [INSTR_MEM_ADDR_WIDTH-1 :0] preload_addr,
    input logic [INSTR_MEM_DATA_WIDTH-1 :0] preload_data,
    `endif
    //tests
    input [XLEN-1          :0] wdata_in,
    input [3               :0] alu_test,
    input [REG_ADDR_WIDTH-1:0] ra0,ra1,wa,
    input                      wr_en, jump

);

// Wires
wire [XLEN-1          :0] next_pc, alu_out, pc;
wire [XLEN-1          :0] rs1, rs2, wdata, imm;
wire [ILEN-1          :0] instr;
wire [REG_ADDR_WIDTH-1:0] rs1_addr, rs2_addr, rd_addr;
wire zero;

// Registers
logic alu_sel = 0;



// Module Instantiations

// Instruction Memory
generic_memory u_instruction_memory(
    .clk     (clk),
    .aresetn (areset_n),
    `ifdef SIMULATION
    .preload_en   (preload_en),
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

assign rs1_addr = instr[19:15];
assign rs2_addr = instr[24:20];
assign rd_addr  = instr[11: 7];

// mem input mux
assign wdata = alu_sel ? alu_out : wdata_in;

register_file u_register_file(
    .rdata0   (rs1       ),
    .rdata1   (rs2       ),
    .wdata    (wdata     ),
    .rd_addr0 (rs1_addr  ),
    .rd_addr1 (rs2_addr  ),
    .wr_addr  (rd_addr   ),
    .clk      (clk       ),
    .aresetn  (areset_n  ),
    .wr_en    (wr_en     )
);

//next pc+4 or alu output
assign next_pc = jump ? pc + imm : pc + 4;

pc u_pc(
    .pc      (pc      ),
    .next_pc (next_pc ),
    .clk     (clk     ),
    .rst     (areset_n)
);

alu u_alu(
    .result (alu_out ),
    .zero   (zero    ),
    .src_a  (rs0     ),
    .src_b  (rs1     ),
    .instr  (alu_test)
);

endmodule