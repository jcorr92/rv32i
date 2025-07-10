module alu (
    output reg [31:0] result,
    input      signed [31:0] src_a,
    input      signed [31:0] src_b,
    input             aresetn,  // currently unused
    input       [3:0] instr
);

    always @(*) begin
        case (instr)
            4'b0000: result = src_a + src_b;                                  // ADD
            4'b0001: result = src_a - src_b;                                  // SUB
            4'b0010: result = src_a & src_b;                                  // AND
            4'b0011: result = src_a | src_b;                                  // OR
            4'b0100: result = src_a ^ src_b;                                  // XOR
            4'b0101: result = src_a << src_b;                                 // SHL
            4'b0110: result = src_a >>> src_b;                                // Arithmetic right shift
            4'b0111: result = (src_a < src_b) ? 1 : 0;                        // SLT (signed)
            4'b1000: result = (src_a == src_b) ? 1 : 0;                       // EQ
            4'b1001: result = (src_a != src_b) ? 1 : 0;                       // NEQ
            4'b1010: result = (src_a >= src_b) ? 1 : 0;                       // GTE (signed)
            4'b1011: result = ($unsigned(src_a) < $unsigned(src_b)) ? 1 : 0;  // LTU
            4'b1100: result = ($unsigned(src_a) >= $unsigned(src_b)) ? 1 : 0; // GTU
            4'b1101: result = src_a * src_b;                                  // MUL
            4'b1110: result = src_a / src_b;                                  // DIV
            4'b1111: result = src_a % src_b;                                  // MOD
            default: result = 0;
        endcase
    end

endmodule
