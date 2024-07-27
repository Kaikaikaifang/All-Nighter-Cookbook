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
// CREATED		"Mon Nov 27 15:37:16 2023"

module test(
	clk,
	q
);


input wire	clk;
output wire	[7:0] q;

wire	[2:0] SYNTHESIZED_WIRE_0;





counter_8	b2v_inst(
	.clock(clk),
	.q(SYNTHESIZED_WIRE_0));


rom	b2v_inst1(
	.clock(clk),
	.address(SYNTHESIZED_WIRE_0),
	.q(q));


endmodule
