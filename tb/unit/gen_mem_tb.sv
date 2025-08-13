import rv32i_pkg::*;
import tb_pkg::*;
module gen_mem_tb();

    // DUT PARAMETERS
    localparam DATA_MEM        = 1;                           // 0 = instr mem; 1 = data mem
    localparam MEM_SIZE        = 4096;                        // Number of words
    localparam BYTES_PER_WORD  = (DATA_MEM ? 8 : 4);          // Bytes per access
    localparam MEM_BYTES       = MEM_SIZE * BYTES_PER_WORD;
    localparam MEM_WIDTH       = $clog2(MEM_BYTES);           // Word address width
    localparam WORD_ALIGN_BITS = $clog2(BYTES_PER_WORD);
    localparam MLEN            = (DATA_MEM ? 64 : 32);        // Access width in bits

    // TB PARAMETERS
    localparam int NUM_TESTS   = 10000;
    localparam bit force_align = 0;
    localparam string logname  = "gen_mem_tb.log";

    // DUT Signals
    logic                   clk;
    logic                   aresetn;
    logic [2:0]             funct3;

`ifdef SIMULATION
    // Preload interface
    logic                   preload_en;
    logic [MEM_WIDTH-1 :0]  preload_addr;
    logic [7:0]             preload_data;
`endif

    // Read interface
    logic [MEM_WIDTH-1 :0]  rd_addr;
    logic [MLEN-1:0]        rd_data;
    // Write interface
    logic [MLEN-1:0]        wr_data;
    logic [MEM_WIDTH-1 :0]  wr_addr;
    logic                   wr_en;
    // Exception
    logic [1           :0]  error;

    // Clock generation
    initial begin
        clk = 1;
        forever #(clk_period/2) clk = ~clk;
    end

    // Instantiate DUT
    generic_memory #(
        DATA_MEM       ,
        MEM_SIZE       ,
        BYTES_PER_WORD ,
        MEM_BYTES      ,
        MEM_WIDTH      ,
        WORD_ALIGN_BITS,
        MLEN
    ) u_dut (
        .clk          (clk          ),
        .aresetn      (aresetn      ),
        .funct3       (funct3       ),
        .preload_en   (preload_en   ),
        .preload_addr (preload_addr ),
        .preload_data (preload_data ),
        .rd_addr      (rd_addr      ),
        .rd_data      (rd_data      ),
        .wr_data      (wr_data      ),
        .wr_addr      (wr_addr      ),
        .wr_en        (wr_en        ),
        .error        (error        )
    );

    // -------------------------------
    // Clocking block for clean TB IO
    // -------------------------------
    clocking cb @(posedge clk);
        default input #1step output #0;

        output funct3;
        output wr_addr, wr_data, wr_en;
        output rd_addr;

        input  rd_data;
        input  error;
    endclocking

    default clocking default_cb @(posedge clk);
    endclocking

    // -------------------------------
    // Testbench main
    // -------------------------------
    int logfile;
    int test_addr = 0;

    initial begin
        $dumpfile("dump.vcd");
        $dumpvars(0, gen_mem_tb);
        logfile = create_log(logname);
        reset();

        for (int i = 0; i < NUM_TESTS; i++) begin
            test_addr = $urandom_range(0, MEM_BYTES-1);
            mem_rw_test(test_addr, force_align);
        end

        $fclose(logfile);
        check_logs(logname, "PASS", "FAIL");
        $finish;
    end

    // -------------------------------
    // Tasks
    // -------------------------------
    task toggle_reset();
        aresetn = 0;
        wait_cycles(1);
        aresetn = 1;
        wait_cycles(1);
        aresetn = 0;
        wait_cycles(1);
        #(clk_period/2);
        aresetn = 1;
        wait_cycles(1);
    endtask

    task automatic reset();
        cb.wr_en   <= '0;
        cb.funct3  <= '0;
        cb.wr_addr <= '0;
        cb.wr_data <= '0;
        cb.rd_addr <= '0;
        toggle_reset();
    endtask

    task automatic write_mem(
        input bit unsigned_access,
        input int bytes,
        input logic [MEM_WIDTH-1:0] addr,
        input logic [MLEN-1:0] data
    );
        if (bytes > BYTES_PER_WORD) begin
            $fdisplay(logfile, "FATAL: Access wider than bus!");
            $fatal(0, "FATAL: Access wider than bus!");
        end
        if (bytes <= 0 || (bytes & (bytes - 1)) != 0)
            $fdisplay(logfile,"ERROR: ILLEGAL ACCESS: %0d bytes requested not power of 2", bytes);

        // Drive signals through clocking block
        cb.funct3[1:0] <= log2_int(bytes);
        cb.funct3[2]   <= unsigned_access;
        cb.wr_addr     <= addr;
        cb.wr_data     <= data;
        cb.wr_en       <= 1;
        $fdisplay(logfile, "writing %0d bytes to addr: %0x - data: %0x", bytes, addr, data);

        ##1; // 1 clock
        cb.wr_en <= 0;
    endtask

    task automatic read_mem(
        input  bit unsigned_access,
        input  int bytes,
        input  logic [MEM_WIDTH-1:0] addr,
        output logic [MLEN-1:0] data
    );
        if (bytes > BYTES_PER_WORD) begin
            $fdisplay(logfile, "FATAL: Access wider than bus!");
            $fatal(0, "FATAL: Access wider than bus!");
        end
        if (bytes <= 0 || (bytes & (bytes - 1)) != 0)
            $fdisplay(logfile, "ERROR: ILLEGAL ACCESS: %0d bytes requested (not a positive power of 2)", bytes);

        $fdisplay(logfile, "reading %0d bytes from addr: %0x", bytes, addr);

        // Drive read
        cb.funct3[1:0] <= log2_int(bytes);
        cb.funct3[2]   <= unsigned_access;
        cb.rd_addr     <= addr;

        ##1; // wait for read
        data = cb.rd_data;
        $fdisplay(logfile, "read result: %0x", data);
    endtask

    task automatic check_misalignment(input bit misaligned, input bit rd_wr, output bit caught);
        caught = 0;
        if (cb.error[rd_wr] != misaligned)
            $fdisplay(logfile, "FAIL: unexpected error/misalignment. error: %0d, misaligned: %0d", cb.error[rd_wr], misaligned);
        else if ((cb.error[rd_wr] == misaligned) & misaligned) begin
            $fdisplay(logfile, "PASS: caught misalignment. error: %0d, misaligned: %0d", cb.error[rd_wr], misaligned);
            caught = 1;
        end
    endtask

    task automatic runtime_bytemask (
        input  logic [63:0] data_in,          // supports up to 64-bit input
        input  logic [2:0]  addr_offset,      // byte offset inside 64-bit word (0-7)
        input  logic [1:0]  size,             // 00=byte, 01=halfword, 10=word
        input  logic        unsigned_access,
        output logic [63:0] data_masked
    );
        logic [BYTES_PER_WORD-1:0] mask_bytes; // up to 8 bytes for 64-bit
        logic [MLEN-1        :0] byte_mask;
        integer i, j = 0;
        data_masked = 64'b0;
        case (size)
            2'b00: begin
                for (i = 0; i < BYTES_PER_WORD; i++) begin
                    if (i[2:0] == addr_offset) begin
                        data_masked[j*8 +: 8] = data_in[i*8 +: 8];
                        j++;
                    end
                end
            end
            2'b01: begin
                for (i = 0; i < BYTES_PER_WORD; i++) begin
                    if (i[2:1] == addr_offset[2:1]) begin
                        data_masked[j*8 +: 8] = data_in[i*8 +: 8];
                        j++;
                    end
                end
            end
            2'b10: begin
                for (i = 0; i < BYTES_PER_WORD; i++) begin
                    if (i[2:2] == addr_offset[2:2]) begin
                        data_masked[j*8 +: 8] = data_in[i*8 +: 8];
                        j++;
                    end
                end
            end
            2'b11: begin
                for (i = 0; i < BYTES_PER_WORD; i++) begin
                    data_masked[j*8 +: 8] = data_in[i*8 +: 8];
                    j++;
                end
            end
        endcase
        if(!unsigned_access)begin
            $fdisplay(logfile,"sign extending with sign bit %b", data_masked[(j*8)-1]);
            for(int k = (j*8) ; k < MLEN ; k++) begin
                data_masked[k] = data_masked[(j*8)-1];
            end
        end
    endtask

    task automatic mem_rw_test(input int addr, input bit force_align);
        // REVISIT - only supports up to 32b reads & writes (as per rv32i spec)
        int pow = $urandom_range(0, 2);
        int bytes = (1 << pow);
        bit unsigned_access = $urandom_range(0, 1);
        logic [MLEN-1:0] rd_data = 0;
        logic [MLEN-1:0] expected_data = 0;
        logic [MLEN-1:0] rand_data = 0;
        bit misaligned, rd_caught, wr_caught;

        rand_data = (MLEN <= 32) ? $urandom() : { $urandom(), $urandom() };
        if (force_align)
            addr &= ~(bytes - 1);
        misaligned = (addr & (bytes-1)) != 0;
        runtime_bytemask(rand_data, addr % 8, log2_int(bytes), unsigned_access,expected_data);

        write_mem(unsigned_access, bytes, addr, rand_data);
        check_misalignment(misaligned, 1, rd_caught);
        read_mem(unsigned_access, bytes, addr, rd_data);
        check_misalignment(misaligned, 0, wr_caught);

        if (rd_data == expected_data)
            $fdisplay(logfile, "PASS: Unsigned: %0d - Expected: %0x, Read: %0x", unsigned_access, expected_data, rd_data);
        else begin
            if((!rd_caught & !wr_caught))
                $fdisplay(logfile, "FAIL: Unsigned: %0d - Expected: %0x, Read: %0x", unsigned_access, expected_data, rd_data);
            else
                $fdisplay(logfile, "PASS: Unsigned: %0d - Misaligned access caught.  Expected: %0x, Read: %0x", unsigned_access, expected_data, rd_data);
        end
    endtask

endmodule