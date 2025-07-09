
module alu (
    output reg [31:0] result,
    input      [31:0] src_a, 
    input      [31:0] src_b,
    input             aresetn,
    input       [3:0] instr
);

    always_comb begin
        case (instr) 
            // 0:ADD
            4'b0000: result = src_a + src_b;
            // 1:SUB
            4'b0001: result = src_a - src_b;
            // 2:AND
            4'b0010: result = src_a & src_b;
            // 3:OR
            4'b0011: result = src_a | src_b;
            // 4:XOR
            4'b0100: result = src_a ^ src_b;
            // 5:SHL
            4'b0101: result = src_a << src_b;
            // 6:SHR
            4'b0110: result = src_a >> src_b;
            // 7:LT
            4'b0111: result = (signed'(src_a) < signed'(src_b)) ? 1 : 0;
            // 8:EQ
            4'b1000: result = (src_a == src_b) ? 1 : 0;
            // 9:NEQ
            4'b1001: result = (src_a == src_b) ? 0 : 1;
            // 10:GTE
            4'b1010: result = (signed'(src_a) >= signed'(src_b)) ? 1 : 0;
            // 11:LTU
            4'b1011: result = (src_a < src_b) ? 1 : 0;
            // 12:GTU
            4'b1100: result = (src_a >= src_b) ? 1 : 0;
            // 13:MUL
            4'b1101: result = src_a * src_b;
            // 14:DIV
            4'b1110: result = src_a / src_b;
            // 15:MOD
            4'b1111: result = src_a % src_b;
        endcase
            
    end
endmodule