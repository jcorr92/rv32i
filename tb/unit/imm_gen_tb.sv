`timescale 1ns/1ps

module imm_gen_tb();
    // packages
    import rv32i_pkg::*;
    import tb_pkg::*;
    // signals
    reg  [XLEN-1:0]imm_out;
    wire [ILEN-1:0]instr_in;

    //instantiate uut
    imm_gen u_dut (
        .imm_out(imm_out),
        .instr_in(instr_in)
    );

    // Helper task
    task test_imm (input string instr_type, input [ILEN-1:0] imm_val, input integer expected);
        begin
            // pack instruction from log file
            case(instr_type)
                "OPCODE_I_TYPE_ALU":
                    instr_in = {imm_val[11:0], 5'd1, 3'b000, 5'd2, OPCODE_I_TYPE_ALU}
                "OPCODE_I_TYPE_LD":
                    instr_in = {imm_val[11:0], 5'd1, 3'b000, 5'd2, OPCODE_I_TYPE_LD}
                "OPCODE_I_TYPE_JALR":
                    instr_in = {imm_val[11:0], 5'd1, 3'b000, 5'd2, OPCODE_I_TYPE_JALR}
                "OPCODE_S_TYPE":
                    instr_in = {imm_val[11:5], 5'd3, 5'd2, 3'b000, 5'd1, OPCODE_S_TYPE}
                "OPCODE_B_TYPE":
                    instr_in = {imm_val[12], imm_val[10:5], 5'd1, 5'd0, 3'b000, imm_val[4:1], imm_val[11], OPCODE_B_TYPE}
                "OPCODE_LUI":
                    instr_in = {imm_val[31:12], 5'd2, OPCODE_LUI}
                "OPCODE_AUIPC":
                    instr_in = {imm_val[31:12], 5'd2, OPCODE_AUIPC}
                "OPCODE_J_TYPE":
                    instr_in = {imm_val[20], imm_val[10:1], imm_val[11], imm_val[19:12], 5'd2, OPCODE_J_TYPE}
                default:
                    $fatal("Unknown instruction type: %s", instr_type);
            endcase
        end
        wait_cycles(1);
        if(imm_out == expected) begin

        end
    endtask

    integer logfile;

    // drive dut
    initial begin
        // Open a file for writing (overwrite if exists)
        logfile = $fopen("imm_gen_test.log", "w");

        // init
        instr_in = 32'b0;

    end
endmodule