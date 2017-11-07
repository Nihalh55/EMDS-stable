`timescale 1ns / 1ps

module testbench;

	reg 		clock;
	wire [7:0]	parallelOut;
	reg		serialIn;
	
	initial
        begin
        	clock = 1;
		serialIn = 0; 
        end
   	always #1 clock = ~clock;

	decoder	tester(.clock(clock), .serialIn(serialIn), .parallelOut(parallelOut));

	initial 
	begin
	$dumpfile("en-decoder.vcd");
	$dumpvars(0,testbench);

	#2	serialIn = 1;
	#10	serialIn = 1;
	#12	serialIn = 0;
	#2	serialIn = 1;
	#10	serialIn = 1;
	#12	serialIn = 0;
	#2	serialIn = 1;
	#10	serialIn = 1;
	#12	serialIn = 0;	
	#60	$finish;
	
	end

	initial 
	begin
		$monitor("\nClock = %d Parallel Out = %d%d%d%d%d%d%d%d", clock,  parallelOut[7],parallelOut[6],parallelOut[5],parallelOut[4],parallelOut[3],parallelOut[2],parallelOut[1],parallelOut[0],);
	end
endmodule
