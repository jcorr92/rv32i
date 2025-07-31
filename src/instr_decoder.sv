`default_nettype none

module instr_decoder
import rv32i_pkg::*;
(
    input  wire logic [31:0] instr,
    output      logic        memRead,
    output      logic        aluSrc,
    output      logic [3 :0] aluCtrl,
    output      logic        jump,
    output      logic        branchCtrl,
    output      logic        memWrite,
    output      logic [1 :0] mem2Reg,
    output      logic        alu2pc,
    output      logic        regWrite
);
    logic [6:0] opcode;
    logic [6:0] funct7;
    logic [2:0] funct3;
    always_comb begin
        opcode = instr[6 :0 ];
        funct7 = instr[31:25];
        funct3 = instr[14:12];
        case(opcode)
            // I-Type (immediate-type) instructions
            // alu op on rs1 & imm, save in rd
            (OPCODE_I_TYPE_ALU): begin
                memRead    = 1'b0;  // don't read dmem
                aluSrc     = 1'b1;  // select imm as ALU i2
                jump       = 1'b0;  // next pc = pc+4
                branchCtrl = 1'b0;  // not a branch
                memWrite   = 1'b0;  // don't write dmem
                mem2Reg    = 2'b00; // pass alu_out to reg file input
                regWrite   = 1'b1;  // store input to reg file
                case(funct3)        // alu op decoder
                    (3'b000):
                        aluCtrl = (instr[30]) ? ALU_SUB : ALU_ADD;
                    (3'b001):
                        aluCtrl = ALU_SLL;
                    (3'b010):
                        aluCtrl = ALU_SLT;
                    (3'b011):
                        aluCtrl = ALU_SLTU;
                    (3'b100):
                        aluCtrl = ALU_XOR;
                    (3'b101):
                        aluCtrl = (instr[30]) ? ALU_SRA : ALU_SRL;
                    (3'b010):
                        aluCtrl = ALU_OR;
                    (3'b010):
                        aluCtrl = ALU_AND;
                endcase
            end
            // alu op (add) on rs1 and imm, output is the address to load
            // loaded val stored into rd
            (OPCODE_I_TYPE_LD): begin
                memRead    = 1'b1;  // read dmem addr: alu_out
                aluSrc     = 1'b1;  // select imm as ALU i2
                jump       = 1'b0;
                branchCtrl = 1'b0;  // not a branch
                memWrite   = 1'b0;
                mem2Reg    = 2'b01; // pass dmem_out to reg file
                regWrite   = 1'b1;
                aluCtrl    = ALU_ADD;
            end
            // jump to rs1+imm, save return pc in rd
            (OPCODE_I_TYPE_JALR): begin
                memRead    = 1'b0;
                aluSrc     = 1'b1;  // select imm as ALU i2
                jump       = 1'b1;  // next pc = pc+imm
                branchCtrl = 1'b0;  // not a branch
                memWrite   = 1'b0;
                mem2Reg    = 2'b10; // pass pc+4 to reg file
                regWrite   = 1'b1;
                aluOp      = 1'b1;
            end
            // R-type (Register type) Instructions
            // alu op on rs1 & rs2, save output in rd
            (OPCODE_R_TYPE): begin
                memRead    = 1'b0;
                aluSrc     = 1'b0;  // select rs2 as ALU i2
                jump       = 1'b0;
                branchCtrl = 1'b0;  // not a branch
                memWrite   = 1'b0;
                mem2Reg    = 2'b00; // pass alu_out to reg file input
                regWrite   = 1'b1;  // store alu_out in rd
                aluOp      = 1'b1;
            end
            // S-type (Store type) Instructions
            // store rs2 in memory location rs1+imm
            (OPCODE_S_TYPE): begin
                memRead    = 1'b0;
                aluSrc     = 1'b1; // imm as ALU in
                jump       = 1'b0;
                branchCtrl = 1'b0;  // not a branch
                memWrite   = 1'b1; // store to dmem
                mem2Reg    = 2'b00;
                regWrite   = 1'b0;
                aluOp      = 1'b1;
            end
            // B-type (Branch type) Instructions
            //
            (OPCODE_B_TYPE): begin
                memRead    = 1'b0;
                aluSrc     = 1'b1; // imm as ALU in
                jump       = 1'b0;
                branchCtrl = 1'b1; // cond branch
                memWrite   = 1'b1; // store to dmem
                mem2Reg    = 2'b00;
                regWrite   = 1'b0;
                aluOp      = 1'b1;
            end
            default: begin
                memRead    = 0;
                aluSrc     = 0;
                aluCtrl    = 0;
                jump       = 0;
                branchCtrl = 0;
                memWrite   = 0;
                mem2Reg    = 0;
                regWrite   = 0;
                aluOp      = 0;
            end
        endcase
    end
endmodule