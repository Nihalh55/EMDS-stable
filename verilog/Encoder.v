
//Module to implement a 4 bit counter=> Each time it reaches 8 it return one
module counter4Bit(clock, isItEight);
	
	input 		clock;
	output reg	isItEight;					//Every eight cycle we need to load into the registers in the PISO

	integer i = 0;
	
	always @ (posedge clock)
	begin
		if(i == 8)
		begin
			isItEight = 1;
			i = 0;
		end
	
		else
		begin
			isItEight = 0;
			i = i + 1;
		end
	end
endmodule

//Module to implement PISO
module PISO(clock, message, serialOut);

	input		clock;
	input [7:0] 	message; 
	output reg	serialOut;

	wire		_load, serialIn;
	reg [7:0] 	tempMessage, load;
	integer 	i;

	counter4Bit	counter(.clock(clock), .isItEight(_load));
	assign serialIn = 0;

	always @ (posedge clock)
	begin
	
		load = ~(_load);					//If load is 1=> shift,  else load

		if(load == 0)
			tempMessage = message;

		if(load == 1)
		begin
	
			serialOut = tempMessage[0];
			for(i = 1 ; i < 7 ; i = i + 1)
			begin

				tempMessage[i - 1] = tempMessage[i];

			end
			tempMessage[7] = serialIn;
		end	
	end
endmodule

	

