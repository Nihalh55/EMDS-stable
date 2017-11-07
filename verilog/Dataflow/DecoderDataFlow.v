//Module to implement a D flip flop to be used in SIPO
module DFlipFlop(clock, d, q, _q);

	input		d;
	input		clock;
	output reg	q;
	output reg      _q;
	
	always @ (posedge clock)
	begin
	
		if(d == 0)
		begin
			q  <= 0;
			_q <= 1;
		end
		else
		begin
			q  <= 1;
			_q <= 0;
		end
	end
endmodule

//Module to implement a JK flip flop to be used in the counter
module JKFlipFlop(clock, j, k, q, _q);

	input		clock;
	input		j;
	input		k;
	output reg	q;
	output reg	_q;

	wire [1:0]	temp;
	assign 	temp[0] = k;
	assign 	temp[1] = j;

	initial
	begin
		q = 0;
	       _q = 1;
	end

	always @ (posedge clock)
	begin

		if( j == 0 && k ==0)
		begin
			q  <=  q;
			_q <= _q;
		end

		else if( j == 0 && k == 1)
		begin
			q  <=  0;
			_q <=  1;
		end

		else if( j == 1 && k == 0)
		begin
			q  <=  1;
			_q <=  0;
		end

		else 
		begin
			q  <=  ~q;
			_q <= ~_q;
		end
	
	end
endmodule

//Module to implement a 4 Bit binary counter => counts from 0 to 8 and return 1 when it reaches 8
module fourBitCounter(clock, isItEight);

	input		clock;
	output reg	isItEight;

	wire		a, b, c, d;
	wire		_a, _b, _c, _d;
	wire		Ja, Ka, Jb, Kb, Jc, Kc, Jd, Kd;
	
	assign		Ja = (b & c & d);
	assign		Ka = 1;
	assign		Jb = (c & d);
	assign		Kb = (c & d);
	assign		Jc = d;
	assign		Kc = d;
	assign		Jd = ~a;
	assign		Kd = 1;

	JKFlipFlop	JKffa(.clock(clock), .j(Ja), .k(Ka), .q(a), ._q(_a));
	JKFlipFlop	JKffb(.clock(clock), .j(Jb), .k(Kb), .q(b), ._q(_b));
	JKFlipFlop	JKffc(.clock(clock), .j(Jc), .k(Kc), .q(c), ._q(_c));
	JKFlipFlop	JKffd(.clock(clock), .j(Jd), .k(Kd), .q(d), ._q(_d));

	always @ (posedge clock)
	begin

		isItEight = ((~a) & (b) & (c) & (d));

	end
endmodule


//Module to implement a SIPO to be used in the decoder
module SIPO(clock, serialIn, parallelOut);
	
	input			clock;
	input			serialIn;
	output [7:0]		parallelOut;

	wire		d7, d6, d5, d4, d3, d2, d1, d0, isEight;
	wire [7:0]	temp, paralleloutTemp;
	
	DFlipFlop	Dff7(.clock(clock), .d(serialIn), .q(paralleloutTemp[7]), ._q(temp[0]));
	DFlipFlop	Dff6(.clock(clock), .d(paralleloutTemp[7]), .q(paralleloutTemp[6]), ._q(temp[1]));
	DFlipFlop	Dff5(.clock(clock), .d(paralleloutTemp[6]), .q(paralleloutTemp[5]), ._q(temp[2]));
	DFlipFlop	Dff4(.clock(clock), .d(paralleloutTemp[5]), .q(paralleloutTemp[4]), ._q(temp[3]));
	DFlipFlop	Dff3(.clock(clock), .d(paralleloutTemp[4]), .q(paralleloutTemp[3]), ._q(temp[4]));
	DFlipFlop	Dff2(.clock(clock), .d(paralleloutTemp[3]), .q(paralleloutTemp[2]), ._q(temp[5]));
	DFlipFlop	Dff1(.clock(clock), .d(paralleloutTemp[2]), .q(paralleloutTemp[1]), ._q(temp[6]));
	DFlipFlop	Dff0(.clock(clock), .d(paralleloutTemp[1]), .q(paralleloutTemp[0]), ._q(temp[7]));

	fourBitCounter	counter(.clock(clock), .isItEight(isEight));

	assign		parallelOut[0] = isEight ^ paralleloutTemp[0];
	assign		parallelOut[1] = isEight ^ paralleloutTemp[1];
	assign		parallelOut[2] = isEight ^ paralleloutTemp[2];
	assign		parallelOut[3] = isEight ^ paralleloutTemp[3];
	assign		parallelOut[4] = isEight ^ paralleloutTemp[4];
	assign		parallelOut[5] = isEight ^ paralleloutTemp[5];
	assign		parallelOut[6] = isEight ^ paralleloutTemp[6];
	assign		parallelOut[7] = isEight ^ paralleloutTemp[7];

endmodule



	
