package tb_pkg

    // N-Cycle delay
    task wait_cycles(input int cycles);
        repeat (cycles)
            #(clk_period);
    endtask

endpackage