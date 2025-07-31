import rv32i_pkg::*;
import tb_pkg::*;

module gen_mem_tb();

    logic                   clk;
    logic                   aresetn;
    logic [2:0]             funct3;
    // Preload interface
    `ifdef SIMULATION
    logic                   preload_en;
    logic [MEM_WIDTH-1 :0]  preload_addr;
    logic [7:0]             preload_data;
    `endif
    // Read interface
    logic [MEM_WIDTH-1 :0] rd_addr;
    logic [MLEN-1:0]       rd_data;
    // Write interface
    logic [MLEN-1:0]       wr_data;
    logic [MEM_WIDTH-1 :0] wr_addr;
    logic                  wr_en;
    //exception
    logic                  error;

    initial begin
        clk = 1;
        forever #(clk_period/2) clk = ~clk;
    end

localparam DATA_MEM        = 0;                           // 0 = instr mem; 1 = data mem
localparam MEM_SIZE        = 4096;                        // Number of words
localparam BYTES_PER_WORD  = (DATA_MEM ? 8 : 4);          // Bytes per access
localparam MEM_BYTES       = MEM_SIZE * BYTES_PER_WORD;
localparam MEM_WIDTH       = $clog2(MEM_BYTES);           // Word address width
localparam WORD_ALIGN_BITS = $clog2(BYTES_PER_WORD);
localparam MLEN            = (DATA_MEM ? 64 : 32);        // Access width in bits

    generic_memory u_dut
    #(
        DATA_MEM       ,
        MEM_SIZE       ,
        BYTES_PER_WORD ,
        MEM_BYTES      ,
        MEM_WIDTH      ,
        WORD_ALIGN_BITS,
        MLEN
    )(
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

    int logfile;
    int test_addr;
    int NUM_TESTS = 10000;
    initial begin
        $dumpfile("dump.vcd");
        $dumpvars(0, gen_mem_tb);
        string logname = "gen_mem_tb.log"
        logfile = create_log(logname);
        toggle_reset();

        for(int i = 0; i < NUM_TESTS; i++) begin
            test_addr = $urandom_range(0, MEM_BYTES);
            mem_rw_test(test_addr);
        end
        $fclose(logfile);
        check_logs(logname, "PASS", "FAIL");
    end

    task automatic write_mem(
        input bit                   unsigned_access,
        input int                   bytes,
        input logic [MEM_WIDTH-1:0] addr,
        input logic [MLEN-1     :0] data
    );
        if(bytes > BYTES_PER_WORD)begin
            $fdisplay(logfile, "FATAL: Access wider than bus!")
            $fatal("FATAL: Access wider than bus!");
        end

        if (bytes <= 0 || (bytes & (bytes - 1)) != 0)
            $fdisplay(logfile,"ERROR: ILLEGAL ACCESS: %0d bytes requested not power of 2", bytes);

        // build access
        funct3[2]   <= unsigned_access;
        funct3[1:0] <= log2_int(bytes);
        wr_addr     <= addr;
        wr_data     <= data;
        wr_en       <= 1;
        $fdisplay(logfile, "writing %d bytes - data: %0x to addr: %0x", bytes, wr_data, wr_addr);
        @(posedge clk)
        wr_en       <= 0;
    endtask

    task automatic logic [MLEN-1:0]  read_mem(
        input   bit                     unsigned_access,
        input   int                     bytes,
        input   logic [MEM_WIDTH-1  :0] addr,
        output  logic [MLEN-1       :0] data
    );
        if (bytes > BYTES_PER_WORD) begin
            $fdisplay(logfile, "FATAL: Access wider than bus!");
            $fatal("FATAL: Access wider than bus!");
        end

        if (bytes <= 0 || (bytes & (bytes - 1)) != 0)
            $fdisplay(logfile, "ERROR: ILLEGAL ACCESS: %0d bytes requested (not a positive power of 2)", bytes);

        // Log the read attempt
        $fdisplay(logfile, "reading %0d bytes from addr: %0x", bytes, addr);

        // Build the funct3 signal for the read
        funct3[2]   <= unsigned_access;
        funct3[1:0] <= log2_int(bytes);
        rd_addr     <= addr;

        // Wait one cycle to capture the data
        @(posedge clk);
        data = rd_data;

        // Log the value read
        $fdisplay(logfile, "read result: %0x", data);
    endtask

    task automatic void check_misalignment(input bit misaligned);
        if(error ^ misaligned)
            fdisplay(logfile, "FAIL: unexpected error/misalignment. error: %0d, misaligned: %0d", error, misaligned);
    endtask

    task automatic mem_rw_test(input int addr);
        // find addr alignment
        int mod_addr = addr % BYTES_PER_WORD;
        int pow = $urandom_range(1,BYTES_PER_WORD);
        int bytes = (1<<pow);
        bit unsigned_access = $urandom_range(0, 1);
        logic [MLEN-1:0] rand_data = $urandom_range(0, (1<<MLEN)-1);
        logic [MLEN-1:0] rd_data = 0;
        bit misaligned;
        // create a mask for misaligned bits. eg if the access is 4 bytes
        // bytes-1 = 11, so & will light up any bits that are in the wrong column
        if(addr & (bytes-1))
            misaligned = 1;

        write_mem(unsigned_access, bytes, addr, rand_data);
        check_misalignment(misaligned);
        rd_data = read_mem(addr);
        check_misalignment(misaligned);
        if(rd_data == rand_data)
            fdisplay(logfile, "PASS: Expected: %0x, Read: %0x");
        else
            fdisplay(logfile, "FAIL: Expected: %0x, Read: %0x");
    endtask

endmodule