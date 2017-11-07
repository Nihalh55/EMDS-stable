`timescale 1ns / 1ps

module testbench;

	reg 		clock;
	reg [7:0]	parallelIn;
	wire		serialOut;
	
	initial
        begin
        	clock = 1;
		parallelIn = 8'b10101000; 
        end
   	always #1 clock = ~clock;

	encoder	tester(.clock(clock), .parallelIn(parallelIn), .serialOut(serialOut));

	initial 
	begin
	$dumpfile("en-decoder.vcd");
	$dumpvars(0,testbench);

	#32 $finish;
	
	end

	initial 
	begin
		$monitor("\nClock = %d Serial Out = %d", clock,  serialOut);
	end
endmodule
