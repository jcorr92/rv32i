module top(
    input clk, areset_n,
    //tests
    input [31:0] wdata_in,
    input [3:0]  alu_test,
    input [4:0]  ra0,ra1,wa,
    input        wr_en, jump
);
// Wires
wire [31:0] pc_mux, alu_out, pc;
wire [31:0] rs0, rs1, wdata;
reg alu_sel = 0;
// Module Instantiations

// mem input mux
assign wdata = alu_sel ? alu_out : wdata_in;

register_file f0(
    .rdata0(rs0),
    .rdata1(rs1),
    .wdata(wdata),
    .rd_addr0(ra0), 
    .rd_addr1(ra1), 
    .wr_addr(wa),
    .clk(clk), 
    .aresetn(rst), 
    .wr_en(wr_en)
);

//next pc+4 or alu output
assign pc_mux = jump ? alu_out : pc + 4;

pc pc0(
    .pc(pc),
    .next_pc(pc_mux),
    .clk(clk),
    .rst(areset_n)
);

alu alu0(
    .result(alu_out),
    .src_a(rs0),
    .src_b(rs1),
    .aresetn(areset_n),
    .instr(alu_test)
);

endmodule