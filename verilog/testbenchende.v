
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
module PISO(clock, message, serialOut);

	input		clock;
	input [7:0] 	message; 
	output reg	serialOut;

	wire		load;
	reg [7:0] 	tempMessage;
	integer 	i;

	counter4Bit	counter(.clock(clock), .isItEight(load));
	//assign serialIn = 0;
	always @ (posedge clock)
	begin
		if(load == 1)
			tempMessage = message;

		if(load == 0)
		begin
			serialOut = tempMessage[0];
			for(i = 1 ; i < 8 ; i = i + 1)
			begin
				tempMessage[i - 1] = tempMessage[i];
			end
			tempMessage[7] = 0;
			//$display ("Serial Out = %b", serialOut);
		end
	end
endmodule

`timescale 1ns / 1ps

module testbench;

	reg		clock;
	reg [7:0]	message;
	wire 		serialOut;

	initial
        begin
        	clock = 1; 
        end
   	always #1 clock = ~clock;

	PISO	tester(.clock(clock), .message(message), .serialOut(serialOut));

	initial 
	begin
	$dumpfile("16CO128-V2.vcd");
	$dumpvars(0,testbench);

	message = 8'b00001111;
	#50 $finish;

	end

	/*initial begin
		$monitor("\nTime = %d Serial out = %d", $time,  serialOut);
	end*/
endmodule
