
//Module to verify password so as to enable the circuit
//If switchOff == 1 => Circuit is off
module passwordChecker(password, switchOff, result);

	input [3:0]	password;
	input		switchOff;
	output reg	result;

	always @ (*)
	begin
		if((password == 4'b0101) && (switchOff == 0))
			result = 1;
		else
			result = 0;
	end

endmodule
