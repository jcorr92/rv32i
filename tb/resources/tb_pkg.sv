`timescale 1ns/1ps

package tb_pkg;
import rv32i_pkg::*;

    // N-Cycle delay
    task wait_cycles(input int cycles);
        repeat (cycles)
            #(clk_period);
    endtask

endpackage