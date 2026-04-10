/********************************************
   ROM Modules for "FPGA Gaplus"

			 Copyright (c) 2007,2019 MiSTer-X
*********************************************/
/*
module DLROM #(parameter AW,parameter DW)
(
	input							CL0,
	input [(AW-1):0]			AD0,
	output reg [(DW-1):0]	DO0,

	input							CL1,
	input [(AW-1):0]			AD1,
	input	[(DW-1):0]			DI1,
	input							WE1
);

reg [DW:0] core[0:((2**AW)-1)];

always @(posedge CL0) DO0 <= core[AD0];
always @(posedge CL1) if (WE1) core[AD1] <= DI1;

endmodule
*/

module MAIN_ROM
(
	input				clk,
	input  [15:0]	ad,
	output  [7:0]	dt //,

//	input				ROMCL,
//	input	 [17:0]	ROMAD,
//	input	  [7:0]	ROMDT,
//	input				ROMEN
);

wire [7:0] dt0, dt1, dt2;

//DLROM #(13,8) mrom0( clk, ad[12:0], dt0, ROMCL,ROMAD[12:0],ROMDT,ROMEN & (ROMAD[17:13]==5'b00_000) );
//DLROM #(13,8) mrom1( clk, ad[12:0], dt1, ROMCL,ROMAD[12:0],ROMDT,ROMEN & (ROMAD[17:13]==5'b00_001) );
//DLROM #(13,8) mrom2( clk, ad[12:0], dt2, ROMCL,ROMAD[12:0],ROMDT,ROMEN & (ROMAD[17:13]==5'b00_010) );

gaplus_mrom0 mrom0(
.clk(clk),
.addr(ad[12:0]),
.data(dt0)
);

gaplus_mrom1 mrom1(
.clk(clk),
.addr(ad[12:0]),
.data(dt1)
);

gaplus_mrom2 mrom2(
.clk(clk),
.addr(ad[12:0]),
.data(dt2)
);

assign dt = ( ad[15:13] == 3'b101 ) ? dt0 :
				( ad[15:13] == 3'b110 ) ? dt1 :
				( ad[15:13] == 3'b111 ) ? dt2 :
				8'h00;

endmodule


module SUB_ROM
(
	input				clk,
	input  [15:0]	ad,
	output  [7:0]	dt //,

//	input				ROMCL,
//	input	 [17:0]	ROMAD,
//	input	  [7:0]	ROMDT,
//	input				ROMEN
);

wire [7:0] dt0, dt1, dt2;

//DLROM #(13,8) srom0( clk, ad[12:0], dt0, ROMCL,ROMAD[12:0],ROMDT,ROMEN & (ROMAD[17:13]==5'b00_100) );
//DLROM #(13,8) srom1( clk, ad[12:0], dt1, ROMCL,ROMAD[12:0],ROMDT,ROMEN & (ROMAD[17:13]==5'b00_101) );
//DLROM #(13,8) srom2( clk, ad[12:0], dt2, ROMCL,ROMAD[12:0],ROMDT,ROMEN & (ROMAD[17:13]==5'b00_110) );

gaplus_srom0 srom0(
.clk(clk),
.addr(ad[12:0]),
.data(dt0)
);

gaplus_srom1 srom1(
.clk(clk),
.addr(ad[12:0]),
.data(dt1)
);

gaplus_srom2 srom2(
.clk(clk),
.addr(ad[12:0]),
.data(dt2)
);


assign dt = ( ad[15:13] == 3'b101 ) ? dt0 :
				( ad[15:13] == 3'b110 ) ? dt1 :
				( ad[15:13] == 3'b111 ) ? dt2 :
				8'h00;

endmodule


module BGCH_ROM
(
   input				clk,
   input  [13:0]	ad,
   output  [7:0]	dt //,

//	input				ROMCL,
//	input	 [17:0]	ROMAD,
//	input	  [7:0]	ROMDT,
//	input				ROMEN
);

wire [7:0] dt0;
//DLROM #(13,8) rom( clk, ad[12:0], dt0, ROMCL,ROMAD[12:0],ROMDT,ROMEN & (ROMAD[17:13]==5'b00_111));

gaplus_gfx1 gfx1(
.clk(clk),
.addr(ad[12:0]),
.data(dt0)
);

reg ad13;
always @( posedge clk ) ad13 <= ad[13];

assign dt = ad13 ? {4'h0,dt0[7:4]} : dt0;

endmodule


module SPCH_ROM
(
   input				clk,
   input  [14:0]	ad,
   output [15:0]	dt //,

//	input				ROMCL,
//	input	 [17:0]	ROMAD,
//	input	  [7:0]	ROMDT,
//	input				ROMEN
);

wire [7:0] dt0, dt1, dt2, dt3;

//DLROM #(13,8) rom0( clk, ad[12:0], dt0, ROMCL,ROMAD[12:0],ROMDT,ROMEN & (ROMAD[17:13]==5'b01_000) );
//DLROM #(13,8) rom1( clk, ad[12:0], dt1, ROMCL,ROMAD[12:0],ROMDT,ROMEN & (ROMAD[17:13]==5'b01_001) );
//DLROM #(13,8) rom2( clk, ad[12:0], dt2, ROMCL,ROMAD[12:0],ROMDT,ROMEN & (ROMAD[17:13]==5'b01_010) );
//DLROM #(13,8) rom3( clk, ad[12:0], dt3, ROMCL,ROMAD[12:0],ROMDT,ROMEN & (ROMAD[17:13]==5'b01_011) );

gaplus_spch0 spch0(
.clk(clk),
.addr(ad[12:0]),
.data(dt0)
);

gaplus_spch1 spch1(
.clk(clk),
.addr(ad[12:0]),
.data(dt1)
);

gaplus_spch2 spch2(
.clk(clk),
.addr(ad[12:0]),
.data(dt2)
);

gaplus_spch3 spch3(
.clk(clk),
.addr(ad[12:0]),
.data(dt3)
);

reg [1:0] _ad;
always @( posedge clk ) _ad <= ad[14:13];

assign dt = ( _ad == 2'b11 ) ? { 8'h0, dt3 } :
				( _ad == 2'b10 ) ? { 8'h0, dt2 } :
				( _ad == 2'b01 ) ? {  dt3, dt1 } :
			/*	( _ad == 2'b00 )?*/{  dt3, dt0 } ;

endmodule


module CLUT1_ROM
(
	input				clk,
	input   [8:0]	adr,
	output  [7:0] 	data //,

//	input				ROMCL,
//	input	 [17:0]	ROMAD,
//	input	  [7:0]	ROMDT,
//	input				ROMEN
);

//DLROM #(9,4) clut1l( clk, adr, data[3:0], ROMCL,ROMAD[8:0],ROMDT[3:0],ROMEN & (ROMAD[17:9]==9'b10_0000_000) );
//DLROM #(9,4) clut1h( clk, adr, data[7:4], ROMCL,ROMAD[8:0],ROMDT[3:0],ROMEN & (ROMAD[17:9]==9'b10_0000_001) );

wire [7:0] clut1l_data;
wire [7:0] clut1h_data;

gaplus_clut1l clut1l(
.clk(clk),
.addr(adr),
.data(clut1l_data)
);

gaplus_clut1h clut1h(
.clk(clk),
.addr(adr),
.data(clut1h_data)
);

assign data[3:0] = clut1l_data[3:0];
assign data[7:4] = clut1h_data[3:0];

endmodule


module PALET_ROM
(
	input				clk,
	input   [7:0]	ad,
	output [11:0]	dt //,

//	input				ROMCL,
//	input	 [17:0]	ROMAD,
//	input	  [7:0]	ROMDT,
//	input				ROMEN
);

//DLROM #(8,4) pr( clk, ad, dt[ 3:0], ROMCL,ROMAD[7:0],ROMDT[3:0],ROMEN & (ROMAD[17:8]==10'h205) );
//DLROM #(8,4) pg( clk, ad, dt[ 7:4], ROMCL,ROMAD[7:0],ROMDT[3:0],ROMEN & (ROMAD[17:8]==10'h206) );
//DLROM #(8,4) pb( clk, ad, dt[11:8], ROMCL,ROMAD[7:0],ROMDT[3:0],ROMEN & (ROMAD[17:8]==10'h207) );

wire [7:0] pr_data;
wire [7:0] pg_data;
wire [7:0] pb_data;

gaplus_pr pr(
.clk(clk),
.addr(ad),
.data(pr_data)
);

gaplus_pg pg(
.clk(clk),
.addr(ad),
.data(pg_data)
);

gaplus_pb pb(
.clk(clk),
.addr(ad),
.data(pb_data)
);

assign dt[3:0] = pr_data[3:0];
assign dt[7:4] = pg_data[3:0];
assign dt[11:8] = pb_data[3:0];


endmodule

