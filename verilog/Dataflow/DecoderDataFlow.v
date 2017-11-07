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

//Module to implement a SIPO to be used in the decoder
module SIPO(clock, serialIn, parallelOut);
	
	input			clock;
	input			serialIn;
	output reg [7:0]	parallelOut;

	

	
