
//Module to implement a 4 bit counter=> Each time it reaches 8 it return one
module counter4Bit(clock, isItEight);
	
	input 		clock;
	output reg	isItEight;					//Every eight cycle we need to load into the registers in the PISO

	integer i = 0;
	
	always @ (posedge clock)
	begin
		i = i + 1;

		if(i == 8)
		begin
			isItEight = 1;
			
		end

		else if(i == 9)
		begin
			isItEight = 0;
			i = 0;
		end

	end
endmodule

//Module to implement SIPO
module SIPO(clock, serialIn, message);

	input			clock;
	input			serialIn;
	output reg [7:0]	message;

	wire		_load, serialIn;
	reg [7:0] 	tempMessage, load;
	integer 	i;	

	counter4Bit	counter(.clock(clock), .isItEight(_load));
	assign tempMessage = 0;

	always @ (posedge clock)
	begin

		load = ~(_load);					//If load is 1=> shift,  else load
		
		if(load == 0)
			message = temp_message;

		if(load == 1)
		begin

			for(i = 1 ; i < 7 ; i = i + 1)
				begin

					tempMessage[i - 1] = tempMessage[i];

				end
			tempMessage[7] = serialIn;
		end	
	end
