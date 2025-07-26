`timescale 1ns/1ps

module generic_memory
import rv32i_pkg::*;
#(
    parameter MEM_SIZE  = 4096,
    parameter MEM_WIDTH = $clog2(MEM_SIZE),
    parameter DATA_MEM  = 0,                    // 0 if instr mem, 1 if data
    parameter MLEN      = DATA_MEM ? 64 : 32    //32b instr mem, 64b data mem
)
(
    // clk & reset
    input                   clk, aresetn,
    // preload interface
    `ifdef SIMULATION
    input logic                  preload_en,
    input logic [MEM_WIDTH-1 :0] preload_addr,
    input logic [MLEN-1      :0] preload_data,
    `endif
    // read interface
    output [MLEN-1      :0] rd_data,
    input  [MEM_WIDTH-1 :0] rd_addr,
    // write interface
    input  [MLEN-1      :0] wr_data,
    input  [MEM_WIDTH-1 :0] wr_addr,
    input                   wr_en
);

// optional rom
`ifdef SIMULATION
    initial begin
        $readmemh("rv32i_prog.hex", mem_reg);
    end
`endif

// 32, 64-bit registers
logic [MLEN-1:0] mem_reg [0:MEM_SIZE-1];

always @ (posedge clk, negedge aresetn) begin
    //reset logic
    if(!aresetn)begin
        for(integer i = 0; i < MEM_SIZE; i = i + 1) begin
            mem_reg[i] <= '0;
        end
    // write logic (data memory only)
    end else if(DATA_MEM && wr_en) begin
        mem_reg[wr_addr] <= wr_data;
    end
    `ifdef SIMULATION
    // preload logic
    if(preload_en) begin
        mem_reg[preload_addr] <= preload_data;
    end
    `endif

end

// async read (read before write)
assign rd_data = mem_reg[rd_addr];

endmodule