//~ `New testbench
`timescale 1ns / 1ps

module rom_tb;

  // test Parameters
  parameter PERIOD = 400;


  // test Inputs
  reg        clk = 0;

  // test Outputs
  wire [7:0] q;


  initial begin
    forever #(PERIOD / 2) clk = ~clk;
  end


  test u_test (
      .clk(clk),

      .q(q[7:0])
  );

endmodule
