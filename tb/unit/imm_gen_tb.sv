`timescale 1ns/1ps

module imm_gen_tb();
    // packages
    import rv32i_pkg::*;
    import tb_pkg::*;
    // signals
    logic [XLEN-1:0]imm_out;
    logic [ILEN-1:0]instr_in;
    logic [ILEN-1:0]pkd_inst;

    //instantiate uut
    imm_gen u_dut (
        .imm_out(imm_out),
        .instr_in(instr_in)
    );

    integer logfile, test_vectors;
    string line;

    // drive dut
    initial begin
        // Open a file for writing (overwrite if exists)
        logfile = $fopen("imm_gen_test.log", "w");
        test_vectors = $fopen("gen/immediates.list", "r");

        if (!logfile || !test_vectors) begin
            $fatal(0,  "Could not open log or test file");
        end

        while(!$feof(test_vectors)) begin
            void'($fgets(line, test_vectors));
            $display(line);
        end

        // init
        instr_in = 32'b0;

        $fclose(logfile);
        $fclose(test_vectors);
        $finish;
    end

    // Helper task
    task test_imm (input string instr_type, input [ILEN-1:0] imm_val, input integer expected);
        begin
            // pack instruction from log file
            case(instr_type)
                "OPCODE_I_TYPE_ALU":
                    pkd_inst = {imm_val[11:0], 5'd1, 3'b000, 5'd2, OPCODE_I_TYPE_ALU};
                "OPCODE_I_TYPE_LD":
                    pkd_inst = {imm_val[11:0], 5'd1, 3'b000, 5'd2, OPCODE_I_TYPE_LD};
                "OPCODE_I_TYPE_JALR":
                    pkd_inst = {imm_val[11:0], 5'd1, 3'b000, 5'd2, OPCODE_I_TYPE_JALR};
                "OPCODE_S_TYPE":
                    pkd_inst = {imm_val[11:5], 5'd3, 5'd2, 3'b000, 5'd1, OPCODE_S_TYPE};
                "OPCODE_B_TYPE":
                    pkd_inst = {imm_val[12], imm_val[10:5], 5'd1, 5'd0, 3'b000, imm_val[4:1], imm_val[11], OPCODE_B_TYPE};
                "OPCODE_LUI":
                    pkd_inst = {imm_val[31:12], 5'd2, OPCODE_LUI};
                "OPCODE_AUIPC":
                    pkd_inst = {imm_val[31:12], 5'd2, OPCODE_AUIPC};
                "OPCODE_J_TYPE":
                    pkd_inst = {imm_val[20], imm_val[10:1], imm_val[11], imm_val[19:12], 5'd2, OPCODE_J_TYPE};
                default:
                    $fatal(0, "Unknown instruction type: %s", instr_type);
            endcase
        end
        instr_in = pkd_inst;
        wait_cycles(1);
        if(imm_out == expected)
            $fdisplay(logfile, "PASS: imm val = %x, expected %x", imm_out, expected);
        else
            $fdisplay(logfile, "FAIL: imm val = %x, expected %x", imm_out, expected);

    endtask

endmodule