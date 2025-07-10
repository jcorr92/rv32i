module tb();

    localparam clk_period = 10;
    logic [31:0] wdata;
    logic [3:0] alu_test;
    logic [4:0] ra0, ra1, wa;
    logic clk, rst, wr_en, jump;

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
    rst = 0;
    wr_en = 0;
    jump = 0;
    alu_test = '0;
    ra0 = 0;
    ra1 = 0;
    wa = 0;
    #50;
    //release reset
    rst = 1;
    #10;
    //write to mem addr 1 & 2.
    wa = 1;
    wdata = 20;
    wr_en = 1;
    #10;
    wa = 2;
    wdata = 30;
    wr_en = 1;
    #10;
    wr_en = 0;
    #10;
    ra0 = 1;
    ra1 = 2;
    #10;
    //test jump
    jump = 1;
    #10;
    jump = 0;
    //test all ALU functions
    for (int i = 0; i < 16 ; i = i + 1) begin
        #10;
        alu_test = i;
    end
    $finish;
end
endmodule