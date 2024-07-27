//~ `New testbench
`timescale 1ns / 1ps

module counter_tb;

  // counter Parameters
  parameter PERIOD = 400;


  // counter Inputs
  reg        clock = 0;

  // counter Outputs
  wire [4:0] q;


  initial begin
    forever #(PERIOD / 2) clock = ~clock;
  end

  //   initial begin
  //     #(PERIOD * 2) rst_n = 1;
  //   end

  counter u_counter (
      .clock(clock),

      .q(q[4:0])
  );

  //   initial begin

  //     $finish;
  //   end

endmodule
