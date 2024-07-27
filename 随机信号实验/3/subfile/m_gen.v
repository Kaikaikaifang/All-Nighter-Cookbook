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
// CREATED		"Mon Nov 27 19:25:20 2023"

module m_gen(
	m_clk,
	m_out
);


input wire	m_clk;
output reg	m_out;

wire	SYNTHESIZED_WIRE_0;
wire	SYNTHESIZED_WIRE_1;
wire	SYNTHESIZED_WIRE_2;
wire	SYNTHESIZED_WIRE_3;
wire	SYNTHESIZED_WIRE_16;
wire	SYNTHESIZED_WIRE_5;
wire	SYNTHESIZED_WIRE_17;
wire	SYNTHESIZED_WIRE_8;
wire	SYNTHESIZED_WIRE_9;
wire	SYNTHESIZED_WIRE_10;
wire	SYNTHESIZED_WIRE_11;
wire	SYNTHESIZED_WIRE_12;
wire	SYNTHESIZED_WIRE_18;

assign	SYNTHESIZED_WIRE_0 = 1;
assign	SYNTHESIZED_WIRE_18 = 1;




\74175 	b2v_inst(
	.CLRN(SYNTHESIZED_WIRE_0),
	.CLK(m_clk),
	.3D(SYNTHESIZED_WIRE_1),
	.2D(SYNTHESIZED_WIRE_2),
	.1D(SYNTHESIZED_WIRE_3),
	.4D(SYNTHESIZED_WIRE_16),
	.1QN(SYNTHESIZED_WIRE_9),
	.1Q(SYNTHESIZED_WIRE_2),
	.2QN(SYNTHESIZED_WIRE_10),
	.3Q(SYNTHESIZED_WIRE_16),
	.2Q(SYNTHESIZED_WIRE_1),
	.4QN(SYNTHESIZED_WIRE_12),
	.4Q(SYNTHESIZED_WIRE_8),
	.3QN(SYNTHESIZED_WIRE_11));

assign	SYNTHESIZED_WIRE_3 = SYNTHESIZED_WIRE_5 | SYNTHESIZED_WIRE_17;


assign	SYNTHESIZED_WIRE_17 = SYNTHESIZED_WIRE_16 ^ SYNTHESIZED_WIRE_8;

assign	SYNTHESIZED_WIRE_5 = SYNTHESIZED_WIRE_9 & SYNTHESIZED_WIRE_10 & SYNTHESIZED_WIRE_11 & SYNTHESIZED_WIRE_12;


always@(posedge m_clk or negedge SYNTHESIZED_WIRE_18 or negedge SYNTHESIZED_WIRE_18)
begin
if (!SYNTHESIZED_WIRE_18)
	begin
	m_out <= 0;
	end
else
if (!SYNTHESIZED_WIRE_18)
	begin
	m_out <= 1;
	end
else
	begin
	m_out <= SYNTHESIZED_WIRE_17;
	end
end



endmodule
