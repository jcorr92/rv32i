`timescale 1ns/1ps

module top_tb();
    import rv32i_pkg::*;
    import tb_pkg::*;

    logic [XLEN-1           :0] wdata;
    logic [3                :0] alu_test;
    logic [REG_ADDR_WIDTH-1 :0] ra0, ra1, wa;
    logic                       clk, rst, wr_en, jump;

    top UUT(
    .clk(clk),
    .areset_n(rst),
    //tests
    .wdata_in(wdata),
    .alu_test(alu_test),
    .ra0(ra0),
    .ra1(ra1),
    .wa(wa),
    .wr_en(wr_en),
    .jump(jump)
    );

initial begin
    clk = 0;
    forever #(clk_period/2) clk = ~clk;
end

initial begin
    // create dump.vcd
    $dumpfile("dump.vcd");
    // dump module, children & grandchildren (dump all)
    $dumpvars(2, top_tb);

    $finish;
end
endmodule