`timescale 1ns/1ps

module pc
import rv32i_pkg::*;
(
    output logic [PC_WIDTH-1:0] pc,
    input        [PC_WIDTH-1:0] next_pc,
    input                       clk, rst
);

    always @ (posedge clk, negedge rst) begin
        if(!rst) begin
            pc = '0;
        end else begin
            pc <= next_pc;
        end
    end

endmodule