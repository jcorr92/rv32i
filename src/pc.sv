`timescale 1ns/1ps
`default_nettype none

module pc
import rv32i_pkg::*;
(
    output      logic [PC_WIDTH-1:0] pc,
    output      logic [PC_WIDTH-1:0] pc_plus_4,
    input  wire logic [PC_WIDTH-1:0] next_pc,
    input  wire logic                clk, rst
);

    always @ (posedge clk, negedge rst) begin
        if(!rst) begin
            pc = '0;
        end else begin
            pc <= next_pc;
        end
    end

    assign pc_plus_4 = pc + 4;

endmodule