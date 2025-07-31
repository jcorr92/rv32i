`timescale 1ns/1ps
`default_nettype none

module generic_memory
import rv32i_pkg::*;
#(
    parameter DATA_MEM        = 0,                           // 0 = instr mem, 1 = data mem
    parameter MEM_SIZE        = 4096,                        // Number of words
    parameter BYTES_PER_WORD  = (DATA_MEM ? 8 : 4),          // Bytes per access
    parameter MEM_BYTES       = MEM_SIZE * BYTES_PER_WORD,
    parameter MEM_WIDTH       = $clog2(MEM_BYTES),           // Word address width
    parameter WORD_ALIGN_BITS = $clog2(BYTES_PER_WORD),
    parameter MLEN            = (DATA_MEM ? 64 : 32)         // Access width in bits
)
(
    // clk & reset
    input wire logic                           clk,
    input wire logic                           aresetn,
    input wire logic [2:0]                     funct3,

    // Preload interface (for simulation)
    `ifdef SIMULATION
    input wire logic                           preload_en,
    input wire logic [MEM_WIDTH-1 :0]  preload_addr,
    input wire logic [7:0]                     preload_data,
    `endif

    // Read interface
    input  wire logic [MEM_WIDTH-1 :0] rd_addr,
    output      logic [MLEN-1:0]               rd_data,

    // Write interface
    input  wire logic [MLEN-1:0]               wr_data,
    input  wire logic [MEM_WIDTH-1 :0] wr_addr,
    input  wire logic                          wr_en,

    //exception
    output wire logic                          error
);

// Byte-addressable memory array
logic [7:0] mem_reg [0:(MEM_BYTES) - 1];
logic [BYTES_PER_WORD-1:0] byte_lane = '0;
// Optional memory preload from file (e.g., hex)
`ifdef SIMULATION
    initial begin
        if(!DATA_MEM)
            $readmemh("./../software/hex_files/instr_decode.hex", mem_reg);
    end
`endif

// Synchronous write logic
always_ff @(posedge clk or negedge aresetn) begin
    if (!aresetn) begin
        // do nothing for now
    end else begin
        // Memory write (only if data memory)
        if (DATA_MEM && wr_en) begin
            for (int i = 0; i < BYTES_PER_WORD; i++) begin
                mem_reg[wr_addr + i] <= wr_data[i*8 +: 8];
            end
        end

        // Optional preload during simulation
        `ifdef SIMULATION
        if (preload_en) begin
            mem_reg[preload_addr] <= preload_data;
        end
        `endif
    end
end

// Asynchronous read logic (little-endian)
always_comb begin
    rd_data = '0;
    case(funct3[1:0]):
        2'b00: begin //byte load/store
            for (int i = 0; i < BYTES_PER_WORD; i++) begin
                // light up byte lane corresponding to byte read
                byte_lane[i] = (i == rd_addr[WORD_ALIGN_BITS-1:0]) ? 1 : 0;
            end
        end
        2'b01: begin // halfword
            if(rd_addr[0])
                misaligned_read(rd_addr, funct3);
            else begin
                for (int i = 0; i < BYTES_PER_WORD; i++) begin
                    // light up byte lanes corresponding to hw read
                    byte_lane[i] = (i[WORD_ALIGN_BITS-1:1] == rd_addr[WORD_ALIGN_BITS-1:1]) ? 1 : 0;
                end
            end
        end
        2'b10: begin // word (32b)
            if(rd_addr[1] | rd_addr[0])
                misaligned_read(rd_addr, funct3);
            else begin
                for (int i = 0; i < BYTES_PER_WORD; i++) begin
                    // light up byte lanes corresponding to word read
                    byte_lane[i] = (i[WORD_ALIGN_BITS-1:2] == rd_addr[WORD_ALIGN_BITS-1:2]) ? 1 : 0;
                end
            end
        end
    endcase
    for (int i = 0; i < BYTES_PER_WORD; i++) begin
        // take 8 bits ascending from 0 - i.e 7:0
        rd_data[i*8 +: 8] = byte_lane[i] ? mem_reg[{rd_addr[MEM_WIDTH-1:WORD_ALIGN_BITS], {WORD_ALIGN_BITS{1'b0}}} + i] : 8'b0;
    end
end

task automatic misaligned_read(logic [MEM_WIDTH-1:0] addr, int f3)
    $display("ERROR: Misaligned read, read addr:%0x on funct3=%0d", addr, f3);
endtask
endmodule
