module register_file
import rv32i_pkg::*;
(
    output [XLEN-1          :0] rdata0,rdata1,
    input  [XLEN-1          :0] wdata,
    input  [REG_ADDR_WIDTH-1:0] rd_addr0, rd_addr1, wr_addr,
    input                       clk, aresetn, wr_en
);

// 32, 64-bit registers
logic [XLEN-1:0] gp_reg[0:REG_COUNT-1];

// Asynchronous read (always return x0 from r0)
assign rdata0 = (rd_addr0 == 0) ? '0 : gp_reg[rd_addr0];
assign rdata1 = (rd_addr1 == 0) ? '0 : gp_reg[rd_addr1];

always @ (posedge clk, negedge aresetn) begin
    //reset logic
    if(!aresetn)begin
        for(integer i = 0; i < REG_COUNT; i = i + 1) begin
            gp_reg[i] <= '0;
        end
    // write logic (always block writes to r0)
    end else if(wr_en & (wr_addr != 0)) begin
        gp_reg[wr_addr] <= wdata;
    end
end

endmodule