//Module to implement SIPO
module decoder(clock, serialIn, parallelOut);

	input			clock;
	input			serialIn;
	output reg [7:0]	parallelOut;

	wire 		load;
	reg [7:0] 	tempparallelOut = 0;
	integer 	i;	

	counter4Bit	counter(.clock(clock), .isItEight(load));

	always @(posedge load)
		parallelOut = tempparallelOut;
	
	always @ (posedge clock)
	begin

		if(load == 0)
		begin
			for(i = 1 ; i < 8 ; i = i + 1)
				begin
					tempparallelOut[i - 1] = tempparallelOut[i];
				end
			tempparallelOut[7] = serialIn;
		end	
	end
endmodule
