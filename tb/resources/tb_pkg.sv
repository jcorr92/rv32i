`timescale 1ns/1ps

package tb_pkg;
import rv32i_pkg::*;

    // N-Cycle delay
    task wait_cycles(input int cycles);
        repeat (cycles)
            #(clk_period);
    endtask
    // returns $floor(log_2(int))
    function int log2_int(input int val);
        int res;
        res = 0;
        while ((1 << res) < val) res++;
        return res;
    endfunction

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

    function automatic int create_log(string logname);
        int logfile = $fopen(logname, "w");
        if (!logfile) begin
            $fatal(0,  "Could not create logfile");
        end
        return logfile;
    endfunction

    function automatic int open_log(string logname);
        int logfile = $fopen(logname, "r");
        if (!logfile) begin
            $fatal(0,  "Could not open logfile");
        end
        return logfile;
    endfunction

    function automatic void check_logs(string logname, string pass_token, string fail_token);

        string line;
        int pass = 0, fail = 0, tests;
        int x, logfile;
        real ratio;

        logfile = open_log(logname);

        while(!$feof(logfile)) begin
            x = $fgets(line, logfile);
            if(find_substring(line, pass_token))
                pass++;
            else if(find_substring(line, fail_token))
                fail++;
        end

        $fclose(logfile);

        tests = pass+fail;
        ratio = (real'(pass) / real'(tests)) * 100.0;


        $display("\n%0d tests, %0d tests passed, %0d tests failed.\n pass ratio = %.2f", tests, pass, fail, ratio);
        if(ratio > 99) begin
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