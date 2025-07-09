module register_file(
    output [31:0] rdata0,rdata1, 
    input  [31:0] wdata,
    input  [4:0]  rd_addr0, rd_addr1, wr_addr,
    input         clk, aresetn, wr_en
);

// 32, 64-b registers
logic [31:0] gp_reg[0:31];

// r0 hardwired to 0
assign gp_reg[0] = '0;

// Asynchronous read
assign rdata0 = gp_reg[rd_addr0];
assign rdata1 = gp_reg[rd_addr1];

always @ (posedge clk, negedge aresetn) begin
    //reset logic
    if(!aresetn)begin
        for(int i = 0; i < 32; i = i + 1) begin
            gp_reg[i] = '0;
        end
    end else if(wr_en) begin
        gp_reg[wr_addr] <= wdata;
    end
end

endmodule