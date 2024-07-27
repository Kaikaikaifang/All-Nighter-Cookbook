//~ `New testbench
`timescale 1ns / 1ps

module m_tb;

  // test Parameters
  parameter PERIOD = 25600;


  // test Inputs
  reg  clk = 0;

  // test Outputs
  wire m_out;


  initial begin
    forever #(PERIOD / 2) clk = ~clk;
  end


  m_gen u_m_gen (
      .clk(clk),

      .m_out(m_out)
  );

  //   initial begin

  //     $finish;
  //   end

endmodule
