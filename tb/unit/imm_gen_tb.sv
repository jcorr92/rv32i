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
    string line, opcode;
    int    imm_val, x;
    logic [63:0] expected;

    // drive dut
    initial begin
        // create dump.vcd
        $dumpfile("dump.vcd");
        // dump module, children & grandchildren (dump all)
        $dumpvars(2, imm_gen_tb);
        // Open a file for writing (overwrite if exists)
        logfile = $fopen("imm_gen_test.log", "w");
        test_vectors = $fopen("gen/immediates.list", "r");

        if (!logfile || !test_vectors) begin
            $fatal(0,  "Could not open log or test file");
        end

        while(!$feof(test_vectors)) begin
            x = $fgets(line, test_vectors);
            // $display(line);
            $fdisplay(logfile, "read string: %s from file", line);
            if ($sscanf(line, "%s %d %h", opcode, imm_val, expected) == 3) begin
                test_imm(opcode, imm_val, expected);
            end else begin
                $fdisplay(logfile, "Skipping invalid line: %s", line);
                $display("WARNING: INVALID LINE DETECTED IN TEST INPUT: \n%s", line);
            end
        end

        $fclose(logfile);
        $fclose(test_vectors);

        check_logs(logfile);

        $finish;
    end

    // Helper task
    task test_imm (input string instr_type, input [ILEN-1:0] imm_val, input [XLEN-1:0] expected);
        $fdisplay(logfile, "received opcode: %s, imm: %d, exp: %x from file", instr_type, $signed(imm_val), expected);
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
                    pkd_inst = {imm_val[11:5], 5'd3, 5'd2, 3'b000, imm_val[4:0], OPCODE_S_TYPE};
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

        $fdisplay(logfile, "packed instr: %b", instr_in);
        wait_cycles(1);
        if(imm_out == expected) begin
            $fdisplay(logfile, "PASS: imm val = %x, expected %x\n", imm_out, expected);
        end else begin
            $fdisplay(logfile, "FAIL: imm val = %x, expected %x\n", imm_out, expected);
            $display("FAIL: imm val = %x, expected %x", imm_out, expected);
        end
    endtask
endmodule