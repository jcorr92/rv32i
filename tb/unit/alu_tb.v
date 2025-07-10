`timescale 1ns / 1ps

module alu_tb;

  // Inputs
  reg [31:0] src_a;
  reg [31:0] src_b;
  reg [3:0]  instr;
  reg        aresetn;

  // Output
  wire [31:0] result;

  // Instantiate the ALU
  alu dut (
    .result(result),
    .src_a(src_a),
    .src_b(src_b),
    .aresetn(aresetn),
    .instr(instr)
  );

  initial begin
    $dumpfile("dump.vcd");
    $dumpvars(0, alu_tb);

    aresetn = 1;         // Not used yet but wired
    src_a = 32'd10;
    src_b = 32'd3;

    // ADD
    instr = 4'b0000; #10;
    // SUB
    instr = 4'b0001; #10;
    // AND
    instr = 4'b0010; #10;
    // OR
    instr = 4'b0011; #10;
    // XOR
    instr = 4'b0100; #10;
    // SHL
    instr = 4'b0101; #10;
    // SHR
    instr = 4'b0110; #10;
    // SLT (signed)
    instr = 4'b0111; #10;
    // EQ
    instr = 4'b1000; #10;
    // NEQ
    instr = 4'b1001; #10;
    // GTE (signed)
    instr = 4'b1010; #10;
    // LTU (unsigned)
    instr = 4'b1011; #10;
    // GTU (unsigned)
    instr = 4'b1100; #10;
    // MUL
    instr = 4'b1101; #10;
    // DIV
    instr = 4'b1110; #10;
    // MOD
    instr = 4'b1111; #10;

    $finish;
  end

endmodule
