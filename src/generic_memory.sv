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
    input wire logic                   clk,
    input wire logic                   aresetn,
    input wire logic [2:0]             funct3,

    // Preload interface
    `ifdef SIMULATION
    input wire logic                   preload_en,
    input wire logic [MEM_WIDTH-1 :0]  preload_addr,
    input wire logic [7:0]             preload_data,
    `endif

    // Read interface
    input  wire logic [MEM_WIDTH-1 :0] rd_addr,
    output      logic [MLEN-1:0]       rd_data,

    // Write interface
    input  wire logic [MLEN-1:0]       wr_data,
    input  wire logic [MEM_WIDTH-1 :0] wr_addr,
    input  wire logic                  wr_en,

    //exceptions [wr_ex:rd_ex]
    output      logic [1           :0] error
);

    // Byte-addressable memory array
    logic [7               :0] mem_reg [0:(MEM_BYTES) - 1];
    logic [BYTES_PER_WORD-1:0] rd_byte_lane, wr_byte_lane;
    logic [MEM_WIDTH-1     :0] rd_base_addr, wr_base_addr;
    logic [WORD_ALIGN_BITS :0] rd_extend = 0;
    logic [MLEN-1          :0] sExt_data;
    string hexfile = "./../software/hex_files/instr_decode.hex";
    int fd;
    logic load_misaligned, store_misaligned;

    // Optional memory preload from hex file
    `ifdef SIMULATION
        initial begin
            if (!DATA_MEM) begin
                fd = $fopen(hexfile, "r");
                if (fd == 0) begin
                    $fatal(1, "ERROR: Failed to open %s for instruction memory preload.", hexfile);
                end
                $fclose(fd);
                $readmemh(hexfile, mem_reg);
            end
        end
    `endif


    // Synchronous write logic
    always_ff @(posedge clk or negedge aresetn) begin
        if (!aresetn) begin
            // do nothing for now
        end else begin
            // Memory write (only if data memory)
            if (DATA_MEM && wr_en && !store_misaligned) begin
                for (logic [WORD_ALIGN_BITS:0] i = 0; i < BYTES_PER_WORD; i++) begin
                    if(wr_byte_lane[i]) begin
                        mem_reg[wr_base_addr + i] <= wr_data[i*8 +: 8];
                    end
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

    // Asynchronous  byte strobe & read logic (little-endian)
    always_comb begin
        rd_data   = '0;
        rd_extend = '0;
        case(funct3[1:0])
            2'b00: begin //byte load/store
                for (logic [WORD_ALIGN_BITS:0] i = 0; i < BYTES_PER_WORD; i++) begin
                    // light up byte lane corresponding to byte read
                    rd_byte_lane[i] = (i[WORD_ALIGN_BITS-1:0] == rd_addr[WORD_ALIGN_BITS-1:0]) ? 1 : 0;
                    wr_byte_lane[i] = (i[WORD_ALIGN_BITS-1:0] == wr_addr[WORD_ALIGN_BITS-1:0]) ? 1 : 0;
                end
            end
            2'b01: begin // halfword
                for (logic [WORD_ALIGN_BITS:0] i = 0; i < BYTES_PER_WORD; i++) begin
                    // light up byte lanes corresponding to hw read
                    rd_byte_lane[i] = (i[WORD_ALIGN_BITS-1:1] == rd_addr[WORD_ALIGN_BITS-1:1]) ? 1 : 0;
                    wr_byte_lane[i] = (i[WORD_ALIGN_BITS-1:1] == wr_addr[WORD_ALIGN_BITS-1:1]) ? 1 : 0;
                end
            end
            2'b10: begin // word (32b)
                for (logic [WORD_ALIGN_BITS:0] i = 0; i < BYTES_PER_WORD; i++) begin
                    // light up byte lanes corresponding to word read
                    rd_byte_lane[i] = (i[WORD_ALIGN_BITS-1:2] == rd_addr[WORD_ALIGN_BITS-1:2]) ? 1 : 0;
                    wr_byte_lane[i] = (i[WORD_ALIGN_BITS-1:2] == wr_addr[WORD_ALIGN_BITS-1:2]) ? 1 : 0;
                end
            end
        endcase

        // force read & wr alignment to word/double word boundary
        rd_base_addr = {rd_addr[MEM_WIDTH-1:WORD_ALIGN_BITS], {WORD_ALIGN_BITS{1'b0}}};
        wr_base_addr = {wr_addr[MEM_WIDTH-1:WORD_ALIGN_BITS], {WORD_ALIGN_BITS{1'b0}}};

        // build full word, 0 extend
        for (int i = 0; i < BYTES_PER_WORD; i++) begin
            // take 8 bits ascending from 0 - i.e 7:0
            if(rd_byte_lane[i] && !load_misaligned) begin
                rd_data[rd_extend*8 +: 8] = mem_reg[rd_base_addr + i];
                rd_extend++;
            end
        end
        // REVISIT - sExt & zExt in parallel and then mux, this is a long comb path
        // sign extend
        sExt_data = '0;
        case(rd_extend)
            1: sExt_data = {{(MLEN-8 ){rd_data[7]}},  rd_data[7:0]};    // 8-bit
            2: sExt_data = {{(MLEN-16){rd_data[15]}}, rd_data[15:0]};   // 16-bit
            4: sExt_data = {{(MLEN-32){rd_data[31]}}, rd_data[31:0]};   // 32-bit
            8: sExt_data = rd_data;                                     // 64-bit
            default: sExt_data = rd_data; // fallback
        endcase

        // select sign or zero extend
        if(funct3[2])
            rd_data = sExt_data;
        else
            rd_data = rd_data;

    end

    // exception logic
    always_comb begin
        load_misaligned = 1'b0;
        store_misaligned = 1'b0;

        // Load misalignment check
        case (funct3[1:0])
            2'b01: if (rd_addr[0] != 0) load_misaligned = 1'b1;
            2'b10: if (rd_addr[1:0] != 0) load_misaligned = 1'b1;
            default: load_misaligned = 1'b0; // byte accesses always aligned
        endcase

        // Store misalignment check
        case (funct3[1:0])
            2'b01: if (wr_addr[0] != 0) store_misaligned = 1'b1;
            2'b10: if (wr_addr[1:0] != 0) store_misaligned = 1'b1;
            default: store_misaligned = 1'b0; // byte accesses always aligned
        endcase
        // Combine into error output: [wr_ex:rd_ex]
        error = {store_misaligned, load_misaligned};
    end

endmodule
