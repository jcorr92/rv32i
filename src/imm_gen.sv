`timescale 1ns/1ps

module imm_gen
import rv32i_pkg::*;
(
    output reg [XLEN-1:0]imm_out,
    input      [ILEN-1:0]instr_in
);

// immediate fields
logic [11:0] imm_i;
logic [11:0] imm_s;
logic [12:0] imm_b;
logic [19:0] imm_u;
logic [20:0] imm_j;

always_comb begin
    // Extract fields
    imm_i  = instr_in[31:20];
    imm_s  = {instr_in[31:25], instr_in[11:7]};
    imm_b  = {instr_in[31], instr_in[7], instr_in[30:25], instr_in[11:8], 1'b0};
    imm_u  = instr_in[31:12];
    imm_j  = {instr_in[31], instr_in[19:12], instr_in[20], instr_in[30:21], 1'b0};

    // sign extension logic
    case(instr_in[6:0])
        OPCODE_I_TYPE_ALU :
            imm_out = `SIGN_EXTEND(imm_i, 12);
        OPCODE_I_TYPE_LD  :
            imm_out = `SIGN_EXTEND(imm_i, 12);
        OPCODE_I_TYPE_JALR:
            imm_out = `SIGN_EXTEND(imm_i, 12);
        OPCODE_S_TYPE     :
            imm_out = `SIGN_EXTEND(imm_s, 12);
        OPCODE_B_TYPE     :
            imm_out = `SIGN_EXTEND(imm_b, 13);
        OPCODE_LUI        :
            imm_out = {32'b0, imm_u, 12'b0};
        OPCODE_AUIPC      :
            imm_out = {32'b0, imm_u, 12'b0};
        OPCODE_J_TYPE     :
            imm_out = `SIGN_EXTEND(imm_j, 21);
        default:
            imm_out = '0;
    endcase
end

endmodule