/*
Lang Towl
ltowl0840
Major: CE
Stopwatch Final Project
*/


// HalfAdder Module Start
module HalfAdder(x, y, s, c);
	input x, y;
	output s, c;
	
	// gate level opperators of half adder
	assign s = x ^ y;
	assign c = x & y;
endmodule
// HalfAdder Module End


/* <><><><><><><><><><><><><><><><><><><><><><> */


// RippleCarry Module Start
module RCA(x, cin, s, co);
	input cin;
	input [3:0] x;
	output [3:0] s;
	output co;
	wire w1, w2, w3;

	// implementation of 4 bit ripple carry adder
	HalfAdder c1(x[0], cin, s[0], w1);
	HalfAdder c2(x[1], w1, s[1], w2);
	HalfAdder c3(x[2], w2, s[2], w3);
	HalfAdder c4(x[3], w3, s[3], co);
endmodule
// RippleCarry Module End


/* <><><><><><><><><><><><><><><><><><><><><><> */


// BDC To Seven Segment Display Controller Start
module BCDController(A, B, C, D, a, b, c, d, e, f, g);
	input A, B , C, D;
	output a, b, c, d, e, f, g;

	// a= BC'D'+A'B'C'D
	assign a = (B&~C&~D) | (~A&~B&~C&D);

	//b= BC'D+BCD'
	assign b = (B&~C&D) | (B&C&~D);

	//c= B'CD'
	assign c = (~B&C&~D);

	// d= BC'D'+B'C'D+BCD
	assign d = (B&~C&~D) | (~B&~C&D) | (B&C&D);

	// e=D+ BC'
	assign e = (D) | (B&~C);

	// f=CD+ A'B'D+ B'C
	assign f = (C&D) | (~A&~B&D) | (~B&C);

	// g= BCD+A'B'C'
	assign g = (B&C&D) | (~A&~B&~C);
endmodule
// BDC To Seven Segment Display Controller End


/* <><><><><><><><><><><><><><><><><><><><><><> */


// Clock Module Start
module clk_divider(clock, rst, clk_out);
input clock, rst;
output clk_out;
 
wire [18:0] din;
wire [18:0] clkdiv;
 
DFF0 dff_inst0(
    .data_in(din[0]),
	 .clock(clock),
	 .reset(rst),
    .data_out(clkdiv[0])
);
 
genvar i;
generate
for (i = 1; i < 19; i=i+1) 
	begin : dff_gen_label
		 DFF0 dff_inst (
			  .data_in (din[i]),
			  .clock(clkdiv[i-1]),
			  .reset(rst),
			  .data_out(clkdiv[i])
		 );
		 end
endgenerate
 
assign din = ~clkdiv;
 
assign clk_out = clkdiv[18];
 
endmodule
// Clock Module End


/* <><><><><><><><><><><><><><><><><><><><><><> */


// D Flip-Flop Start 
module DFF0(data_in,clock,reset, data_out);
input data_in;
input clock,reset;

output reg data_out;

always@(posedge clock)
	begin
		if(reset)
			data_out<=1'b0;
		else
			data_out<=data_in;
	end	

endmodule
// D Flip-Flop End


/* <><><><><><><><><><><><><><><><><><><><><><> */


// Register Module Start
module Register(a, clock, reset, b);
	input [3:0] a;
	input clock, reset;
	output[3:0] b;

	// implementation of 4-bit DFF Register
	DFF0 dff1(a[0], clock, reset, b[0]);
	DFF0 dff2(a[1], clock, reset, b[1]);
	DFF0 dff3(a[2], clock, reset, b[2]);
	DFF0 dff4(a[3], clock, reset, b[3]);
endmodule
// Register Module End


/* <><><><><><><><><><><><><><><><><><><><><><> */


// Module Cout10 Start
module count10(clock, inc, reset, Count);
	input clock, inc, reset;
	output [3:0] Count;
	
	wire FFReset;
	wire RCACarry;
	wire eq_count_9;
	wire [3:0] wr;
	
	// checks to see if current count has reached 9, and if so sets eq_count_9 to high
	assign eq_count_9 = (Count == 4'b1001) ? 1 : 0;
	assign FFReset = (eq_count_9 & inc | reset);
	
	// determines the current count and passes it to the ripple carry adder
	Register r1(wr, clock, FFReset, Count);
	RCA g1(Count, inc, wr, RCACarry);
endmodule
// Module Count10 End


/* <><><><><><><><><><><><><><><><><><><><><><> */


// Module Count6 Start
module count6(clock, inc, reset, Count);
	input clock, inc, reset;
	output [3:0] Count;
	
	wire FFReset;
	wire RCACarry;
	wire eq_count_5;
	wire [3:0] wr;
	
	// checks to see if current count has reached 6, and if so sets eq_count_5 to high
	assign eq_count_5 = (Count == 4'b0101) ? 1 : 0;
	assign FFReset = (eq_count_5 & inc | reset);
	
	// determines the current count and passes it to the ripple carry adder
	Register r1(wr, clock, FFReset, Count);
	RCA g1(Count, inc, wr, RCACarry);
endmodule
// Module Count6 End


/* <><><><><><><><><><><><><><><><><><><><><><> */


// T-FLip Flop Start (provided)
module TFF0 (
data  , // Data Input
clk   , // Clock Input
reset , // Reset input
q       // Q output
);
//-----------Input Ports---------------
input data, clk, reset ; 
//-----------Output Ports---------------
output q;
//------------Internal Variables--------
reg q;
//-------------Code Starts Here---------
always @ ( posedge clk or posedge reset)
if (reset) begin
  q <= 1'b0;
end else if (data) begin
  q <= !q;
end
// T-Flip Flop End


/* <><><><><><><><><><><><><><><><><><><><><><> */


// BCDOutput Module Start
module BCDOutput(inc, res, clock, a, b, c, d, e, f, g);
	input inc, res, clock;
	output a, b, c, d, e, f, g;

	// slows down the internal clock to desired speed and sets it to clock_out
	wire clock_out;
	clk_divider(clock, res, clock_out);
	
	// determines current count value and stores it as a 4 bit value Count
	wire [3:0] Count;
	count10(clock_out, inc, res, Count);
	
	// Passes Count to the BCD controller to get outputs a - g
	BCDController(Count[3], Count[2], Count[1], Count[0], a, b, c, d, e, f, g);
endmodule
// BCDOutput Module Start


/* <><><><><><><><><><><><><><><><><><><><><><> */


// Stop watch module start
module stopwatch(inc, res, clock, a, b, c, d, e, f, g);
	input inc, res, clock;
	output [3:0] a;
	output [3:0] b;
	output [3:0] c;
	output [3:0] d;
	output [3:0] e;
	output [3:0] f;
	output [3:0] g;
	
	// slows down the internal clock to desired speed and sets it to clock_out
	wire clock_out;
	// reset is 0 so that the switch can reset to all zeros
	clk_divider(clock, 1'b0, clock_out); 
	
	wire [2:0] increment;
	wire [3:0] cten1;
	wire [3:0] cten2;
	wire [3:0] cten3;
	wire [3:0] csix1;
	wire q;
	
	// assigning increment to determine which display to increment
	assign increment[0] = (cten1 == 4'b1001) ? 1 : 0; 
	assign increment[1] = (cten1 == 4'b1001 && cten2 == 4'b1001) ? 1 : 0;
	assign increment[2] = (cten1 == 4'b1001 && cten2 == 4'b1001 && cten3 == 4'b1001) ? 1 : 0;
	
	
	// determines current count value and stores it 
	count10(clock_out, q, res, cten1);
	count10(clock_out, increment[0], res, cten2);
	count10(clock_out, increment[1], res, cten3);
	count6(clock_out, increment[2], res, csix1);
	
	// Passes the current count to the BCD controller to get outputs a - g
	BCDController seg4(cten1[3], cten1[2], cten1[1], cten1[0], a[0], b[0], c[0], d[0], e[0], f[0], g[0]);
	BCDController seg3(cten2[3], cten2[2], cten2[1], cten2[0], a[1], b[1], c[1], d[1], e[1], f[1], g[1]);
	BCDController seg2(cten3[3], cten3[2], cten3[1], cten3[0], a[2], b[2], c[2], d[2], e[2], f[2], g[2]);
	BCDController seg1(csix1[3], csix1[2], csix1[1], csix1[0], a[3], b[3], c[3], d[3], e[3], f[3], g[3]);

	// sets push button on FPGA using T flip flop
	TFF0(1, inc, 0, q); 
endmodule
// Stop watch module end


/* <><><><><><><><><><><><><><><><><><><><><><> */
