// Copyright (C) 2023  Intel Corporation. All rights reserved.
// Your use of Intel Corporation's design tools, logic functions 
// and other software and tools, and any partner logic 
// functions, and any output files from any of the foregoing 
// (including device programming or simulation files), and any 
// associated documentation or information are expressly subject 
// to the terms and conditions of the Intel Program License 
// Subscription Agreement, the Intel Quartus Prime License Agreement,
// the Intel FPGA IP License Agreement, or other applicable license
// agreement, including, without limitation, that your use is for
// the sole purpose of programming logic devices manufactured by
// Intel and sold by Intel or its authorized distributors.  Please
// refer to the applicable agreement for further details, at
// https://fpgasoftware.intel.com/eula.

// PROGRAM		"Quartus Prime"
// VERSION		"Version 22.1std.2 Build 922 07/20/2023 SC Lite Edition"
// CREATED		"Mon Nov 27 20:11:54 2023"

module twoask (
    clk,
    m_squence,
    fpga_ext_trig,
    pin_da_wr,
    pin_da_reset,
    pin_da_sel,
    pin_da_clk,
    f_ref_c,
    pin_da_dataout,
    two_ask
);


  input wire clk;
  output wire m_squence;
  output wire fpga_ext_trig;
  output wire pin_da_wr;
  output wire pin_da_reset;
  output wire pin_da_sel;
  output wire pin_da_clk;
  output wire f_ref_c;
  output wire [9:0] pin_da_dataout;
  output wire [7:0] two_ask;

  wire       SYNTHESIZED_WIRE_0;
  wire       SYNTHESIZED_WIRE_1;
  wire       SYNTHESIZED_WIRE_10;
  wire [7:0] SYNTHESIZED_WIRE_3;
  wire       SYNTHESIZED_WIRE_11;
  wire [2:0] SYNTHESIZED_WIRE_6;
  wire [7:0] SYNTHESIZED_WIRE_7;
  wire       SYNTHESIZED_WIRE_8;

  assign m_squence          = SYNTHESIZED_WIRE_10;
  assign fpga_ext_trig      = SYNTHESIZED_WIRE_10;
  assign two_ask            = SYNTHESIZED_WIRE_7;
  assign SYNTHESIZED_WIRE_0 = 1;
  assign SYNTHESIZED_WIRE_1 = 1;




  freq_div b2v_inst (
      .clk  (clk),
      .rst_n(SYNTHESIZED_WIRE_0),

      .out8(SYNTHESIZED_WIRE_11)

  );


  freq_div b2v_inst1 (
      .clk  (clk),
      .rst_n(SYNTHESIZED_WIRE_1),



      .out256(SYNTHESIZED_WIRE_8)
  );


  gate b2v_inst11 (
      .gate(SYNTHESIZED_WIRE_10),
      .data(SYNTHESIZED_WIRE_3),
      .q   (SYNTHESIZED_WIRE_7)
  );


  counter_8 b2v_inst3 (
      .clock(SYNTHESIZED_WIRE_11),
      .q    (SYNTHESIZED_WIRE_6)
  );


  rom b2v_inst4 (
      .clock  (SYNTHESIZED_WIRE_11),
      .address(SYNTHESIZED_WIRE_6),
      .q      (SYNTHESIZED_WIRE_3)
  );


  dac_bus_out b2v_inst6 (
      .clk_in   (clk),
      .dac_in0_i(SYNTHESIZED_WIRE_7),

      .r_ref_c  (f_ref_c),
      .dac_sel  (pin_da_sel),
      .dac_clk  (pin_da_clk),
      .dac_wr   (pin_da_wr),
      .dac_reset(pin_da_reset),
      .dac_data (pin_da_dataout)
  );



  m_gen b2v_inst8 (
      .clk  (SYNTHESIZED_WIRE_8),
      .m_out(SYNTHESIZED_WIRE_10)
  );



endmodule
