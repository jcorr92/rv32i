`timescale 1ns/1ps

module alu
import rv32i_pkg::*;
(
    output logic  [XLEN-1:0] result,
    output logic             zero,
    input  signed [XLEN-1:0] src_a,
    input  signed [XLEN-1:0] src_b,
    input         [3     :0] alu_ctrl
);
    always_comb begin
        case (alu_ctrl)
            ALU_ADD : result = src_a + src_b;
            ALU_SUB : result = src_a - src_b;
            ALU_AND : result = src_a & src_b;
            ALU_OR  : result = src_a | src_b;
            ALU_XOR : result = src_a ^ src_b;
            ALU_SLL : result = src_a << src_b[4:0];
            ALU_SRL : result = $unsigned(src_a) >> src_b[4:0];
            ALU_SRA : result = src_a >>> src_b[4:0];
            ALU_SLT : result = (src_a < src_b) ? 1 : 0;
            ALU_SLTU: result = ($unsigned(src_a) < $unsigned(src_b)) ? 1 : 0;
            ALU_NOP : result = '0;
            default : result = '0;
        endcase
    end
    // set zero if result = 0
    assign zero = ~|result;

endmodule
