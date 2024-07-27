//~ `New testbench
`timescale 1ns / 1ps

module counter_8_tb;

  // counter_8 Parameters
  parameter PERIOD = 400;


  // counter_8 Inputs
  reg        clock = 0;

  // counter_8 Outputs
  wire [2:0] q;


  initial begin
    forever #(PERIOD / 2) clock = ~clock;
  end

  //   initial begin
  //     #(PERIOD * 2) rst_n = 1;
  //   end

  counter_8 u_counter_8 (
      .clock(clock),

      .q(q[2:0])
  );

  //   initial begin

  //     $finish;
  //   end

endmodule
