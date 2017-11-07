//Module to implement a D flip flop to be used in 1 bit register
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

//Module to implement a 1 bit register to be used in PISO
module oneBitRegister(clock, serialIn, load, Din, serialOut);

	input		clock;
	input		serialIn;
	input		load;
	input		Din;
	output 		serialOut;

	wire		_load, x, y , z, temp;

	assign		_load = ~load;
	assign 		x = (_load & Din);
	assign		y = (load  & serialIn);
	assign		z = (x + y);
	
	DFlipFlop	Dff(.clock(clock), .d(z), .q(serialOut), ._q(temp));

endmodule
	
//Module to implement PISO to be used in Encoder
module PISO(clock, serialIn, load, parallelIn, serialOut);
	
	input		clock;
	input [7:0]	parallelIn;
	input		serialIn;
	input		load;
	output 		serialOut;

	wire	s7, s6, s5,s4, s3, s2, s1;

	oneBitRegister	bit7(.clock(clock), .serialIn(serialIn), .load(load), .Din(parallelIn[7]), .serialOut(s7));
	oneBitRegister	bit6(.clock(clock), .serialIn(s7), .load(load), .Din(parallelIn[6]), .serialOut(s6));
	oneBitRegister	bit5(.clock(clock), .serialIn(s6), .load(load), .Din(parallelIn[5]), .serialOut(s5));
	oneBitRegister	bit4(.clock(clock), .serialIn(s5), .load(load), .Din(parallelIn[4]), .serialOut(s4));
	oneBitRegister	bit3(.clock(clock), .serialIn(s4), .load(load), .Din(parallelIn[3]), .serialOut(s3));
	oneBitRegister	bit2(.clock(clock), .serialIn(s3), .load(load), .Din(parallelIn[2]), .serialOut(s2));
	oneBitRegister	bit1(.clock(clock), .serialIn(s2), .load(load), .Din(parallelIn[1]), .serialOut(s1));
	oneBitRegister	bit0(.clock(clock), .serialIn(s1), .load(load), .Din(parallelIn[0]), .serialOut(serialOut));

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

//Module to implement an encoder
module encoder(clock, parallelIn, serialOut);

	input		clock;
	input [7:0]	parallelIn;
	output 		serialOut;

	wire	isLoad, _isLoad;

	fourBitCounter	counter(.clock(clock), .isItEight(isLoad));

	assign	_isLoad = ~isLoad;

	PISO	PISOReg(.clock(clock), .serialIn(0), .load(_isLoad), .parallelIn(parallelIn), .serialOut(serialOut));

endmodule
