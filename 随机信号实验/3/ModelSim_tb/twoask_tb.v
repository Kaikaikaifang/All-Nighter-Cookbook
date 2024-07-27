//~ `New testbench
`timescale 1ns / 1ps

module twoask_tb;

  // twoask Parameters
  parameter PERIOD = 38.5;


  // twoask Inputs
  reg        clk = 0;

  // twoask Outputs
  wire       m_squence;
  wire       fpga_ext_trig;
  wire       pin_da_wr;
  wire       pin_da_reset;
  wire       pin_da_sel;
  wire       pin_da_clk;
  wire       f_ref_c;
  wire [9:0] pin_da_dataout;
  wire [7:0] two_ask;


  initial begin
    forever #(PERIOD / 2) clk = ~clk;
  end

  twoask u_twoask (
      .clk(clk),

      .m_squence     (m_squence),
      .fpga_ext_trig (fpga_ext_trig),
      .pin_da_wr     (pin_da_wr),
      .pin_da_reset  (pin_da_reset),
      .pin_da_sel    (pin_da_sel),
      .pin_da_clk    (pin_da_clk),
      .f_ref_c       (f_ref_c),
      .pin_da_dataout(pin_da_dataout[9:0]),
      .two_ask       (two_ask[7:0])
  );


endmodule
