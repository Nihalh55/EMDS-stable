
//Module to to logically shift bits to the left by 1
module logicalLeftShift(beforeShift, afterShift);

	input [2:0]	beforeShift;
	output [2:0]	afterShift;

	assign afterShift[0] = beforeShift[2];
	assign afterShift[1] = beforeShift[0];
	assign afterShift[2] = beforeShift[1];

endmodule

//Module to decrypt 8 bit message 
module decrypter(message, key, decryptedMessage);

	input [7:0]	message;
	input [7:0]	key;
	output [7:0]	decryptedMessage;

	wire [2:0] b;
	wire [2:0] a;
	wire [7:0] intermediateMessage;

	assign	intermediateMessage = key ^ message;

	assign	decryptedMessage[0] = ~intermediateMessage[0];
	assign	decryptedMessage[2] = ~intermediateMessage[2];
	assign	decryptedMessage[4] = ~intermediateMessage[4];
	assign	decryptedMessage[6] = ~intermediateMessage[6];

	assign	b[0]	=	intermediateMessage[1];
	assign	b[1]	=	intermediateMessage[3];
	assign	b[2]	=	intermediateMessage[5];

	logicalLeftShift	gate1(.beforeShift(b), .afterShift(a));
	
	assign	decryptedMessage[1] = a[0];
	assign	decryptedMessage[3] = a[1];
	assign	decryptedMessage[5] = a[2];
	assign	decryptedMessage[7] = message[7];

endmodule 

