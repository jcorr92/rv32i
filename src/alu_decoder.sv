// `default_nettype none
// import rv32i_pkg::*;

// module alu_decode (
//     input wire logic [31:0] instr,
//     input wire logic [0 :0] aluOp,
//     output     logic [3 :0] aluCtrl
// );
//     logic [6:0] opcode;
//     logic [6:0] funct7;
//     logic [2:0] funct3;
//     always_comb begin
//         opcode = instr[6 :0 ];
//         funct7 = instr[31:25];
//         funct3 = instr[14:12];
//         if(aluOp)begin
//             case(opcode)

//             endcase
//         end else begin
//             aluCtrl = ALU_NOP;
//         end
//     end
// endmodule