`timescale 1ns/1ps

package tb_pkg;
import rv32i_pkg::*;

    // N-Cycle delay
    task wait_cycles(input int cycles);
        repeat (cycles)
            #(clk_period);
    endtask

    function automatic bit find_substring(string full, string sub);
        int i, j;
        int full_len = full.len();
        int sub_len = sub.len();

        if (sub_len == 0 || full_len < sub_len)
            return 0;

        for (i = 0; i <= full_len - sub_len; i++) begin
            for (j = 0; j < sub_len; j++) begin
                if (full.getc(i + j) != sub.getc(j))
                    break;
            end
            if (j == sub_len)
                return 1;
        end
        return 0;
    endfunction

    function automatic void check_logs(string logname);

        string line;
        int pass = 0, fail = 0, tests;
        int x, logfile;
        shortreal ratio;

        logfile = $fopen(logname, "r");
        if (!logfile) begin
            $fatal(0,  "Could not open logfile");
        end

        while(!$feof(logfile)) begin
            x = $fgets(line, logfile);
            if(find_substring(line, "PASS"))
                pass++;
            else if(find_substring(line, "FAIL"))
                fail++;
        end

        $fclose(logfile);

        tests = pass+fail;
        ratio = (pass/(tests)) * 100;

        $display("\n%d tests, %d tests passed, %d tests failed.\n pass ratio = %.2f\%", tests, pass, fail, ratio);
        if(ratio == 100) begin
            $display("*******************************************************************");
            $display("*                                                                 *");
            $display("*                         TEST PASSED! :)                         *");
            $display("*                                                                 *");
            $display("*******************************************************************");
        end else begin
            $display("*******************************************************************");
            $display("*                                                                 *");
            $display("*                           TEST FAIL :(                          *");
            $display("*                                                                 *");
            $display("*******************************************************************");
        end
    endfunction
endpackage