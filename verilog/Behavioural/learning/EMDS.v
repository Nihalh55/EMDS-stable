/*************************************************************************************************
*   Team Member Details
*   --------------------
*   
*   Member 1
*   ----------
*   NAME: Gurupungav Narayanan
*   ROLL: 16CO114
*   -----------------------------
*   
*   Member 2
*   ----------
*   NAME: Nihal Haneef
*   ROLL: 16CO128
*   -----------------------------
*   
*   Date: 6th November 2018
*
*   Included Files: 
*   ----------------
*   
/*************************************************************************************************/

`timescale 1ns/1ps

module User(clock, enter_text_here, receiving_message_to_file, out, in);
	input [8*100:1] enter_text_here;
	inout [8*100:1] receiving_message_to_file;

	//inout [7:0] out, in;
	inout out, in;
	input clock;

	inout [7:0] keyboard_out_to_box;
	inout [7:0] messenger_to_incoming_monitor;

	inout keyboard_clock, op_when;

	Keyboard keyboard(.clock(keyboard_clock), .in_message(enter_text_here), .out_character(keyboard_out_to_box));
	Messenger box (.clock(clock), .in(in), .message_character(keyboard_out_to_box), .incoming_monitor(messenger_to_incoming_monitor), .out(out), .keyboard_clock(keyboard_clock), .op_when(op_when));
	Monitor incomingMonitor (.clock(op_when), .in_character(messenger_to_incoming_monitor), .out_message(receiving_message_to_file));
endmodule

module Messenger(clock, in, message_character, incoming_monitor, out, keyboard_clock, op_when);
	
	input clock;
	//inout [7:0] in;
	//inout [7:0] out;
	inout in, out;
	//inout [7:0] _in;
	//inout incoming_character;
	//inout outgoing_character;
	inout [7:0] incoming_character;
	inout [7:0] outgoing_character;
	inout [7:0] message_character;

	reg   [7:0] key = 43;
	inout [7:0] incoming_monitor; // Decrypted incoming_character

	inout keyboard_clock, op_when;
	//decrypter decrypt(in, key, incoming_monitor);
	//encrypter encrypt(message_character, key, out);
	//assign _in = in;

	decoder decode (clock, in, incoming_character);
	decrypter decrypt(incoming_character, key, incoming_monitor);
	
	encrypter encrypt(message_character, key, outgoing_character);
	encoder encode (clock, outgoing_character, out, keyboard_clock, op_when);
endmodule

//Module that splits a string into a stream of characters
module Keyboard(clock, in_message, out_character);
    input clock;
    input [8*100:1] in_message;

    reg[7:0] out;
    integer i = 1, j = 0;

    output [7:0] out_character;
    assign out_character = out;

    always @(posedge clock)
        begin
            for (j = 0; j < 8; j++)
                out[j] = in_message[i+j];
            i = i+8;
        end
endmodule

//Module that concatenates stream of characters to a string
module Monitor(clock, in_character, out_message);
    input clock;
    input [7:0] in_character;
    output [8*100:1] out_message;

    reg [8*100:1] out;
    assign out_message = out;

    integer i = 1, j = 0;

    always @(posedge clock)
        begin
            for (j = 0; j < 8; j++)
                out[i+j] = in_character[j];
            i = i+8;
        end
    
endmodule

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

//Module to logically shift bits to the right by 1
module logicalRightShift(beforeShift, afterShift);

	input [2:0]	beforeShift;
	output [2:0]	afterShift;

	assign afterShift[0] = beforeShift[1];
	assign afterShift[1] = beforeShift[2];
	assign afterShift[2] = beforeShift[0];

endmodule

//Module to to logically shift bits to the left by 1
module logicalLeftShift(beforeShift, afterShift);

	input [2:0]	beforeShift;
	output [2:0]	afterShift;

	assign afterShift[0] = beforeShift[2];
	assign afterShift[1] = beforeShift[0];
	assign afterShift[2] = beforeShift[1];

endmodule

//Module to encrypt 8 bit message => Homomorphic and private key encryption
module encrypter(message, key, encryptedMessage);

	input [7:0]	message;
	input [7:0]	key;
	output [7:0]	encryptedMessage;

	wire [2:0] b;
	wire [2:0] a;
	wire [7:0] intermediateMessage;
	wire [7:0] preFinal;

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

	assign preFinal = key ^ intermediateMessage;
	assign	encryptedMessage = preFinal;
	//assign	encryptedMessage = intermediateMessage;
	
endmodule 	

//Module to decrypt 8 bit message
module decrypter(message, key, decryptedMessage);

	input   [7:0]	message;
	input   [7:0]	key;
	output  [7:0]	decryptedMessage;

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
module encoder(clock, parallelIn, serialOut, keyboard_clock, op_when);

	input		clock;
	input [7:0] 	parallelIn; 
	output reg	serialOut;

	wire		eight;
	reg [7:0] 	tempparallelIn;
	integer 	i;

	output keyboard_clock;
	output op_when;	

	counter4Bit	counter(.clock(clock), .isItEight(eight));

	assign keyboard_clock = ~eight;
	assign op_when = eight;
	//assign serialIn = 0;
	always @ (posedge clock)
	begin
		if(eight == 1)
			tempparallelIn = parallelIn;

		if(eight == 0)
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

//Module to implement SIPO
module decoder(clock, serialIn, parallelOut);

	input			clock;
	input			serialIn;
	output reg [7:0]	parallelOut;

	wire 		load;
	reg [7:0] 	tempparallelOut = 0;
	integer 	i;	

	counter4Bit	counter(.clock(clock), .isItEight(load));

	//always @(posedge load)
	always @ (posedge clock)
	begin
		
		if (load == 1)
		parallelOut = tempparallelOut;
	
		else if(load == 0)
		begin
			tempparallelOut[7] = serialIn;
			for(i = 7 ; i > 0 ; i = i - 1)
				begin
					tempparallelOut[i - 1] = tempparallelOut[i];
				end
		end	
	end
endmodule