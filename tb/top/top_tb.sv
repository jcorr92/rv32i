`timescale 1ns/1ps

module top_tb();
    import rv32i_pkg::*;
    import tb_pkg::*;

    logic [XLEN-1           :0] wdata;
    logic [3                :0] alu_test;
    logic [REG_ADDR_WIDTH-1 :0] ra0, ra1, wa;
    logic                       clk, rst, wr_en, jump;

    top u_dut(
    .clk(clk),
    .areset_n(rst)
    );

    int logfile;

    initial begin
        clk = 1;
        forever #(clk_period/2) clk = ~clk;
    end

    initial begin
        $dumpfile("dump.vcd");
        $dumpvars(0, top_tb);

        toggle_reset();
        wait_cycles(100);

        print_regs();

        $finish;
    end

    task toggle_reset();
        rst = 0;
        wait_cycles(1);
        rst = 1;
        wait_cycles(1);
        rst = 0;
        wait_cycles(1);
        #(clk_period/2)
        rst = 1;
        wait_cycles(1);
    endtask

    task automatic print_regs();
        int logfile;
        logic [31:0] word;

        // print registers
        logfile = $fopen("top_tb.log", "w");
        $fdisplay(logfile, "printing registers");
        for(int i = 0; i < REG_COUNT; i++) begin
            $fdisplay(logfile, "x%0d: %x", i, u_dut.u_register_file.gp_reg[i]);
        end
        $fclose(logfile);

        //print imem
        logfile = $fopen("imem.log", "w");
        $fdisplay(logfile, "printing imem");
        for(int i = 0; i < INSTR_MEM_WORDS; i++) begin
            for (int j = 0 ; j<4; j++)
                word[j*8 +: 8] = u_dut.u_instruction_memory.mem_reg[(i*4)+j];
            $fdisplay(logfile, "x%0d: %x", i, word);
        end
        $fclose(logfile);

        //print dmem
        logfile = $fopen("dmem.log", "w");
        $fdisplay(logfile, "printing dmem");
        for(int i = 0; i < DATA_MEM_WORDS; i++) begin
            for (int j = 0 ; j<4; j++)
                word[j*8 +: 8] = u_dut.u_data_memory.mem_reg[(i*4)+j];
            $fdisplay(logfile, "x%0d: %x", i, word);
        end
        $fclose(logfile);
    endtask
endmodule