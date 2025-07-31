`timescale 1ns/1ps

package rv32i_pkg;
  // Architecture
  parameter int unsigned XLEN      = 64;      // Register Length
  parameter int unsigned ILEN      = 32;      // Instruction Length
  parameter int unsigned IALIGN    = 32;      // Instruction alignment in bits (32 or 16 for compressed)

  // Simulation
  parameter int unsigned clk_period = 10;     // 10ns

  // Register file
  parameter int unsigned REG_COUNT      = 32;
  parameter int unsigned REG_ADDR_WIDTH = $clog2(REG_COUNT);

  // Program Counter
  parameter int unsigned PC_WIDTH = XLEN;

  // Instruction Memory
  parameter int unsigned INSTR_MEM_WORDS      = 4096;
  parameter int unsigned INSTR_MEM_ADDR_WIDTH = $clog2(INSTR_MEM_WORDS);
  parameter int unsigned INSTR_MEM_DATA_WIDTH = 32;

  // Data Memory

  parameter int unsigned DATA_MEM_WORDS       = 4096;
  // Opcode Mnemonic
  parameter logic [6:0] OPCODE_R_TYPE      = 7'b0110011; //testing
  parameter logic [6:0] OPCODE_I_TYPE_ALU  = 7'b0010011; //testing
  parameter logic [6:0] OPCODE_I_TYPE_LD   = 7'b0000011; //testing
  parameter logic [6:0] OPCODE_S_TYPE      = 7'b0100011; //testing
  parameter logic [6:0] OPCODE_B_TYPE      = 7'b1100011; //testing
  parameter logic [6:0] OPCODE_LUI         = 7'b0110111;
  parameter logic [6:0] OPCODE_AUIPC       = 7'b0010111;
  parameter logic [6:0] OPCODE_J_TYPE      = 7'b1101111;
  parameter logic [6:0] OPCODE_I_TYPE_JALR = 7'b1100111; //testing
  parameter logic [6:0] OPCODE_SYSTEM      = 7'b1110011;
  parameter logic [6:0] OPCODE_FENCE       = 7'b0001111;

  // ALU OPs
  parameter logic [3:0] ALU_ADD  = 4'b0000; // ADD & address calc
  parameter logic [3:0] ALU_SUB  = 4'b0001; // SUB & BEQ/BNE compare
  parameter logic [3:0] ALU_AND  = 4'b0010;
  parameter logic [3:0] ALU_OR   = 4'b0011;
  parameter logic [3:0] ALU_XOR  = 4'b0100;
  parameter logic [3:0] ALU_SLL  = 4'b0101; // SHL is same whether arithmetic or logical
  parameter logic [3:0] ALU_SRL  = 4'b0110;
  parameter logic [3:0] ALU_SRA  = 4'b0111;
  parameter logic [3:0] ALU_SLT  = 4'b1000; // signed
  parameter logic [3:0] ALU_SLTU = 4'b1001; // unsigned
  parameter logic [3:0] ALU_NOP  = 4'b1111;

  // Helper Macros
  `define sEXT(val, width) {{(XLEN - width){val[width-1]}}, val[width-1:0]}

endpackage