/*
**
**
**
**
**
**
**
**************************************************************************************/

`timescale 1ns/1ps

module User(clock, in_message, encrypted_message, out_message);
    
    input  clock;
    input  [8*100:1] in_message;
    inout  [7:0] keyboard_out;
    inout  [7:0] incoming_monitor; // Monitor In
    inout  [7:0] outgoing_monitor; // done
    inout  [7:0] encrypted_monitor; // done            
    inout  transmitted_data;
    inout  incoming_data;
	inout  [8*100:1] encrypted_message;
    inout  [8*100:1] out_message;

    Keyboard keyboard(.clock(clock), .in_message(in_message), .out_character(keyboard_out));
    Messenger messenger(.clock(clock), .incoming_monitor(incoming_monitor), .keyboard_input(keyboard_out), .outgoing_monitor(outgoing_monitor), .encrypted_monitor(encrypted_monitor));
    Monitor encryptedMonitor(.clock(clock), .in_character(encrypted_monitor), .out_message(encrypted_message));
    Monitor outgoingMonitor(.clock(clock), .in_character(outgoing_monitor), .out_message(out_message));
	

endmodule

//Messenger Module

module Messenger(clock, enable, incoming_monitor, keyboard_input, outgoing_monitor, encrypted_monitor, transmitted_data, incoming_data);

    inout clock; // input
    inout enable;
    inout [7:0] incoming_monitor; 
    inout [7:0] outgoing_monitor; // done
    inout [7:0] encrypted_monitor; // done            
    inout [7:0] keyboard_input; // input
    inout transmitted_data;
    inout incoming_data;


    reg   [7:0] key = 43;
    //inout [7:0] encrypted_message;
    encrypter encrypt(.message(keyboard_input), .key(key), .encryptedMessage(encrypted_monitor));
	decrypter decrypt(.message(encrypted_monitor), .key(key), .decryptedMessage(outgoing_monitor));

    //assign encrypted_monitor = encrypted_message;
    //assign outgoing_monitor = keyboard_input;

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

