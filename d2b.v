// Copyright (C) 2020  Intel Corporation. All rights reserved.
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
// VERSION		"Version 20.1.1 Build 720 11/11/2020 SJ Lite Edition"
// CREATED		"Wed Dec 13 18:33:17 2023"

module d2b(
	d0,
	d1,
	d2,
	d3,
	d4,
	d5,
	d6,
	d7,
	d8,
	d9,
	b
);


input wire	d0;
input wire	d1;
input wire	d2;
input wire	d3;
input wire	d4;
input wire	d5;
input wire	d6;
input wire	d7;
input wire	d8;
input wire	d9;
output wire	[3:0] b;

wire	[3:0] b_ALTERA_SYNTHESIZED;
wire	SYNTHESIZED_WIRE_15;
wire	SYNTHESIZED_WIRE_1;
wire	SYNTHESIZED_WIRE_3;
wire	SYNTHESIZED_WIRE_5;
wire	SYNTHESIZED_WIRE_7;
wire	SYNTHESIZED_WIRE_8;
wire	SYNTHESIZED_WIRE_9;
wire	SYNTHESIZED_WIRE_10;
wire	SYNTHESIZED_WIRE_11;
wire	SYNTHESIZED_WIRE_12;
wire	SYNTHESIZED_WIRE_13;
wire	SYNTHESIZED_WIRE_14;




assign	SYNTHESIZED_WIRE_14 = d3 | d1;

assign	b_ALTERA_SYNTHESIZED[0] = SYNTHESIZED_WIRE_15 & SYNTHESIZED_WIRE_1;

assign	b_ALTERA_SYNTHESIZED[1] = SYNTHESIZED_WIRE_15 & SYNTHESIZED_WIRE_3;

assign	b_ALTERA_SYNTHESIZED[2] = SYNTHESIZED_WIRE_15 & SYNTHESIZED_WIRE_5;

assign	b_ALTERA_SYNTHESIZED[3] = SYNTHESIZED_WIRE_15 & SYNTHESIZED_WIRE_7;

assign	SYNTHESIZED_WIRE_10 = d7 | d6;

assign	SYNTHESIZED_WIRE_11 = d3 | d2;

assign	SYNTHESIZED_WIRE_9 = d5 | d4;

assign	SYNTHESIZED_WIRE_8 = d7 | d6;

assign	SYNTHESIZED_WIRE_5 = SYNTHESIZED_WIRE_8 | SYNTHESIZED_WIRE_9;

assign	SYNTHESIZED_WIRE_3 = SYNTHESIZED_WIRE_10 | SYNTHESIZED_WIRE_11;

assign	SYNTHESIZED_WIRE_15 =  ~d0;

assign	SYNTHESIZED_WIRE_13 = d9 | SYNTHESIZED_WIRE_12;

assign	SYNTHESIZED_WIRE_1 = SYNTHESIZED_WIRE_13 | SYNTHESIZED_WIRE_14;

assign	SYNTHESIZED_WIRE_7 = d9 | d8;

assign	SYNTHESIZED_WIRE_12 = d7 | d5;

assign	b = b_ALTERA_SYNTHESIZED;

endmodule
