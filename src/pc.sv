module pc (
    output reg [31:0] pc,
    input      [31:0] next_pc,
    input             clk, rst
);

    always @ (posedge clk, negedge rst) begin
        if(!rst) begin
            pc = '0;
        end else begin
            pc <= next_pc;
        end
    end

endmodule