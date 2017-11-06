
//Module to check if the 8 bit ASCII input is zero or not
module zeroChecker(message, result);
	
	input [7:0]	message;
	output reg [7:0]	result;

	always @ (*)
	begin
		if(message==0)		
			result = 0;
	end

endmodule

//Module to to logically shift bits to the right by 1
module logicalRightShift(beforeShift, afterShift);

	input [2:0]	beforeShift;
	output [2:0]	afterShift;

	assign afterShift[0] = beforeShift[1];
	assign afterShift[1] = beforeShift[2];
	assign afterShift[2] = beforeShift[0];

endmodule

//Module to encrypt 8 bit message => Homomorphic and private key encryption
module encrypter(message, key, encryptedMessage);

	input [7:0]	message;
	input [7:0]	key;
	output [7:0]	encryptedMessage;

	wire [2:0] b;
	wire [2:0] a;
	wire [7:0] intermediateMessage;
	wire [7:0] outZero, preFinal;

	assign	intermediateMessage[0] = ~message[0];
	assign	intermediateMessage[2] = ~message[2];
	assign	intermediateMessage[4] = ~message[4];
	assign	intermediateMessage[6] = ~message[6];

	assign	b[0]	=	message[1];
	assign	b[1]	=	message[3];
	assign	b[2]	=	message[5];

	logicalRightShift	gate1(.beforeShift(b), .afterShift(a));
	
	assign	intermediateMessage[1] = a[0];
	assign	intermediateMessage[3] = a[1];
	assign	intermediateMessage[5] = a[2];
	assign	intermediateMessage[7] = message[7];

	zeroChecker		gate2(.message(message), .result(outZero));

	assign	preFinal = key ^ intermediateMessage;
	assign	encryptedMessage = preFinal & outZero;

endmodule 	
