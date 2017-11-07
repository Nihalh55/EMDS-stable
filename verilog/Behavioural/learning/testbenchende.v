`timescale 1ns / 1ps

module testbench;

	reg			clock;
	reg   [7:0]	parallelIn;
	inout [7:0]	parallelOut;			
	wire 		serialOut;

	initial
        begin
        	clock = 1; 
        end
   	always #1 clock = ~clock;

	PISO	tester (.clock(clock), .parallelIn(parallelIn), .serialOut(serialOut));
	SIPO	tester2(.clock(clock), .serialIn(serialOut), .parallelOut(parallelOut));

	initial 
	begin
	$dumpfile("en-decoder.vcd");
	$dumpvars(0,testbench);

	parallelIn = 8'b00001111;
	#100 $finish;

	end

	/*initial begin
		$monitor("\nTime = %d Serial out = %d", $time,  serialOut);
	end*/
endmodule
