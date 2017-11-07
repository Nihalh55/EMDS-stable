/*************************************************************************************************
*   Title
*   ------
*   EMDS - Encryptes Message Delivery System
*   
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
*   Abstract 
*   ---------
*
*   
*   In a world where security and privacy have become a top priority for citizens
*   and nations alike, encryption has become an exceedingly necessary element to
*   communication.
*
*   This mini-project aims to implement a digital circuit that can:
*   1. Allow two users to communicate with one another using text messages.
*    	* ASCII characters
*    	* Keyboard input in Logisim
*    	* Displaying Messages using a TTY in Logisim.
*    	* FIN and FOUT in Verilog.
*
*   2. Ask each user for a password to enable communication.
*    	* Use LED lights to indicate whether communication is enabled.
*    	* 4 Digit PINs for both user.
*
*   3. Encrypt the message to prevent interference.
*    	* Using some kind of homomorphic encryption
*
*   4. Transmit the message using a transmission circuit of choice.
*    	* Using wired transmission in Logisim and Verilog.
*
*
*    Possible Real World Implementation:
*    * A HT12E/D to Encode and Decode the data before and after transmission.
*    * RF434 Transmitter for the transmission.  
* 
/*************************************************************************************************/

`timescale 1ns/1ps

module VerilogDM_114_128(clock, enter_text_here, receiving_message_to_file, encrypted_message, password, out, in);
	
	input [8*100:1] enter_text_here;
	inout [8*100:1] receiving_message_to_file;
	inout [8*100:1] encrypted_message;

	inout [7:0] out, in;
	input clock;

	inout [7:0] keyboard_out_to_box;
	inout [7:0] messenger_to_incoming_monitor;
	inout [7:0] encrypted_monitor;
	inout keyboard_clock, op_when;

	input [3:0] password;
	inout enable;
	reg enbl;
	assign enable = enbl;
	inout result;
	
	/* Enable the circuit if password
	   is correct */

	passwordChecker pwd(password, result);
	always @(posedge clock)
	begin
		if (result == 1)
			enbl = 1;
	end

	Keyboard keyboard(.enable(enable), .clock(keyboard_clock), .in_message(enter_text_here), .out_character(keyboard_out_to_box));
	Messenger box (.clock(clock), .in(in), .encrypted_monitor(encrypted_monitor), .message_character(keyboard_out_to_box), .incoming_monitor(messenger_to_incoming_monitor), .out(out), .keyboard_clock(keyboard_clock), .op_when(op_when));
	Monitor incomingMonitor (.enable(enable), .clock(op_when), .in_character(messenger_to_incoming_monitor), .out_message(receiving_message_to_file));
	Monitor encryptedMonitor(.enable(enable), .clock(op_when), .in_character(encrypted_monitor), .out_message(encrypted_message));

endmodule

module Messenger(clock, in, message_character, incoming_monitor, out, keyboard_clock, op_when, encrypted_monitor);
	
	input clock;
	inout [7:0] in;
	inout [7:0] out;

	wire  [7:0] _in;
	inout incoming_character;
	inout outgoing_character;
	inout [7:0] message_character;

	reg   [7:0] key = 43;
	inout [7:0] incoming_monitor;
	inout [7:0] encrypted_monitor;
	inout keyboard_clock, op_when;
	assign _in = in;
	
	decoder decode (clock, incoming_character, _in);
	assign encrypted_monitor = in;
	decrypter decrypt(in, key, incoming_monitor);
		
	encrypter encrypt(message_character, key, out);
	encoder encode (clock, out, outgoing_character, keyboard_clock, op_when);

endmodule

//Module that splits a string into a stream of characters
module Keyboard(clock, in_message, out_character, enable);
    input clock;
    input [8*100:1] in_message;
	input enable;

    reg[7:0] out;
    integer i = 1, j = 0;

    output [7:0] out_character;
    assign out_character = out;

    always @(posedge clock)
        begin
			if (enable == 1)
			begin
	            for (j = 0; j < 8; j++)
    	            out[j] = in_message[i+j];
        	    i = i+8;
			end
        end
endmodule

//Module that concatenates stream of characters to a string
module Monitor(clock, enable, in_character, out_message, enable);
    input clock;
    input [7:0] in_character;
    output [8*100:1] out_message;
	inout enable;

    reg [8*100:1] out;
    assign out_message = out;

    integer i = 1, j = 0;

    always @(posedge clock)
        begin
			if (enable == 1)
			begin
            	for (j = 0; j < 8; j++)
	                out[i+j] = in_character[j];
	            i = i+8;
			end
		end
    
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

//Module to implement an encoder
module encoder(clock, parallelIn, serialOut, keyboard_clock, op_when);

	input		clock;
	input [7:0]	parallelIn;
	output 		serialOut;
	output keyboard_clock;
	output op_when;

	wire	isLoad, _isLoad;

	fourBitCounter	counter(.clock(clock), .isItEight(isLoad));

	assign	_isLoad = ~isLoad;
	assign keyboard_clock = _isLoad;
	assign op_when = isLoad;

	PISO	PISOReg(.clock(clock), .serialIn(1'b0), .load(_isLoad), .parallelIn(parallelIn), .serialOut(serialOut));

endmodule

//Module to implement a SIPO to be used in the decoder
module decoder(clock, serialIn, parallelOut);
	
	input			clock;
	input			serialIn;
	output [7:0]		parallelOut;

	wire		d7, d6, d5, d4, d3, d2, d1, d0, isEight;
	wire [7:0]	temp, paralleloutTemp;
	
	DFlipFlop	Dff7(.clock(clock), .d(serialIn), .q(paralleloutTemp[7]), ._q(temp[0]));
	DFlipFlop	Dff6(.clock(clock), .d(paralleloutTemp[7]), .q(paralleloutTemp[6]), ._q(temp[1]));
	DFlipFlop	Dff5(.clock(clock), .d(paralleloutTemp[6]), .q(paralleloutTemp[5]), ._q(temp[2]));
	DFlipFlop	Dff4(.clock(clock), .d(paralleloutTemp[5]), .q(paralleloutTemp[4]), ._q(temp[3]));
	DFlipFlop	Dff3(.clock(clock), .d(paralleloutTemp[4]), .q(paralleloutTemp[3]), ._q(temp[4]));
	DFlipFlop	Dff2(.clock(clock), .d(paralleloutTemp[3]), .q(paralleloutTemp[2]), ._q(temp[5]));
	DFlipFlop	Dff1(.clock(clock), .d(paralleloutTemp[2]), .q(paralleloutTemp[1]), ._q(temp[6]));
	DFlipFlop	Dff0(.clock(clock), .d(paralleloutTemp[1]), .q(paralleloutTemp[0]), ._q(temp[7]));

	fourBitCounter	counter(.clock(clock), .isItEight(isEight));

	assign		parallelOut[0] = isEight ^ paralleloutTemp[0];
	assign		parallelOut[1] = isEight ^ paralleloutTemp[1];
	assign		parallelOut[2] = isEight ^ paralleloutTemp[2];
	assign		parallelOut[3] = isEight ^ paralleloutTemp[3];
	assign		parallelOut[4] = isEight ^ paralleloutTemp[4];
	assign		parallelOut[5] = isEight ^ paralleloutTemp[5];
	assign		parallelOut[6] = isEight ^ paralleloutTemp[6];
	assign		parallelOut[7] = isEight ^ paralleloutTemp[7];

endmodule

//Module to verify password so as to enable the circuit
//If switchOff == 1 => Circuit is off
module passwordChecker(password, result);

	input [3:0]	password;
	output 	result;

	reg [3:0] pwd_storage = 4'b0101;
	wire [3:0] intermediate;

	assign intermediate = ~ (password ^ pwd_storage);
	assign result = intermediate[3] & intermediate[2] & intermediate[1] & intermediate[0];

endmodule

//Module to implement a 4 Bit binary counter => counts from 0 to 8 and return 1 when it reaches 8
module fourBitCounter(clock, isItEight);

	input		clock;
	output reg	isItEight;

	wire		a, b, c, d;
	wire		_a, _b, _c, _d;
	wire		Ja, Ka, Jb, Kb, Jc, Kc, Jd, Kd;
	
	assign		Ja = (b & c & d);
	assign		Ka = 1;
	assign		Jb = (c & d);
	assign		Kb = (c & d);
	assign		Jc = d;
	assign		Kc = d;
	assign		Jd = ~a;
	assign		Kd = 1;

	JKFlipFlop	JKffa(.clock(clock), .j(Ja), .k(Ka), .q(a), ._q(_a));
	JKFlipFlop	JKffb(.clock(clock), .j(Jb), .k(Kb), .q(b), ._q(_b));
	JKFlipFlop	JKffc(.clock(clock), .j(Jc), .k(Kc), .q(c), ._q(_c));
	JKFlipFlop	JKffd(.clock(clock), .j(Jd), .k(Kd), .q(d), ._q(_d));

	always @ (posedge clock)
	begin

		isItEight = ((~a) & (b) & (c) & (d));

	end
endmodule

//Module to implement a 1 bit register to be used in PISO
module oneBitRegister(clock, serialIn, load, Din, serialOut);

	input		clock;
	input		serialIn;
	input		load;
	input		Din;
	output 		serialOut;

	wire		_load, x, y , z, temp;

	assign		_load = ~load;
	assign 		x = (_load & Din);
	assign		y = (load  & serialIn);
	assign		z = (x + y);
	
	DFlipFlop	Dff(.clock(clock), .d(z), .q(serialOut), ._q(temp));

endmodule
	
//Module to implement PISO to be used in Encoder
module PISO(clock, serialIn, load, parallelIn, serialOut);
	
	input		clock;
	input [7:0]	parallelIn;
	input		serialIn;
	input		load;
	output 		serialOut;

	wire	s7, s6, s5,s4, s3, s2, s1;

	oneBitRegister	bit7(.clock(clock), .serialIn(serialIn), .load(load), .Din(parallelIn[7]), .serialOut(s7));
	oneBitRegister	bit6(.clock(clock), .serialIn(s7), .load(load), .Din(parallelIn[6]), .serialOut(s6));
	oneBitRegister	bit5(.clock(clock), .serialIn(s6), .load(load), .Din(parallelIn[5]), .serialOut(s5));
	oneBitRegister	bit4(.clock(clock), .serialIn(s5), .load(load), .Din(parallelIn[4]), .serialOut(s4));
	oneBitRegister	bit3(.clock(clock), .serialIn(s4), .load(load), .Din(parallelIn[3]), .serialOut(s3));
	oneBitRegister	bit2(.clock(clock), .serialIn(s3), .load(load), .Din(parallelIn[2]), .serialOut(s2));
	oneBitRegister	bit1(.clock(clock), .serialIn(s2), .load(load), .Din(parallelIn[1]), .serialOut(s1));
	oneBitRegister	bit0(.clock(clock), .serialIn(s1), .load(load), .Din(parallelIn[0]), .serialOut(serialOut));

endmodule

//Module to implement a D flip flop to be used in SIPO
module DFlipFlop(clock, d, q, _q);

	input		d;
	input		clock;
	output reg	q;
	output reg      _q;
	
	always @ (posedge clock)
	begin
	
		if(d == 0)
		begin
			q  <= 0;
			_q <= 1;
		end
		else
		begin
			q  <= 1;
			_q <= 0;
		end
	end
endmodule

//Module to implement a JK flip flop to be used in the counter
module JKFlipFlop(clock, j, k, q, _q);

	input		clock;
	input		j;
	input		k;
	output reg	q;
	output reg	_q;

	wire [1:0]	temp;
	assign 	temp[0] = k;
	assign 	temp[1] = j;

	initial
	begin
		q = 0;
	       _q = 1;
	end

	always @ (posedge clock)
	begin

		if( j == 0 && k ==0)
		begin
			q  <=  q;
			_q <= _q;
		end

		else if( j == 0 && k == 1)
		begin
			q  <=  0;
			_q <=  1;
		end

		else if( j == 1 && k == 0)
		begin
			q  <=  1;
			_q <=  0;
		end

		else 
		begin
			q  <=  ~q;
			_q <= ~_q;
		end
	
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
