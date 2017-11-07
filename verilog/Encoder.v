
//Module to implement a 4 bit counter=> Each time it reaches 8 it return one
module counter4Bit(clock, isItEight);
	
	input 		clock;
	output reg	isItEight;					//Every eight cycle we need to load into the registers in the PISO

	integer i = 0;
	
	always @ (posedge clock)
	begin
		if (i == 0)
			isItEight = 0;
		i = i + 1;
		if(i == 9)
		begin
			i = 0;
			isItEight = 0;
		end
		
		else if(i==8)
		begin
			isItEight = 1;
		end	

	end
endmodule

//Module to implement PISO
module Encoder(clock, parallelIn, serialOut);

	input		clock;
	input [7:0] 	parallelIn; 
	output reg	serialOut;

	wire		load;
	reg [7:0] 	tempparallelIn;
	integer 	i;

	counter4Bit	counter(.clock(clock), .isItEight(load));
	//assign serialIn = 0;
	always @ (posedge clock)
	begin
		if(load == 1)
			tempparallelIn = parallelIn;

		if(load == 0)
		begin
			serialOut = tempparallelIn[0];
			for(i = 1 ; i < 8 ; i = i + 1)
			begin
				tempparallelIn[i - 1] = tempparallelIn[i];
			end
			tempparallelIn[7] = 0;
			//$display ("Serial Out = %b", serialOut);
		end
	end
endmodule
