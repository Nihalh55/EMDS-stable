`timescale 1ns/1ps
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

module Monitor(clock, in_character, out_message);
    input clock;
    input [7:0] in_character;
    output [8*100:1] out_message;

    reg [8*100:1] out;
    assign out_message = out;

    integer i = 1, j = 0;

    always @(negedge clock)
        begin
            for (j = 0; j < 8; j++)
                out[i+j] = in_character[j];
            i = i+8;
        end
    
endmodule

module main;
    reg clock;
    integer file, file2, r;
    integer i = 793;
    integer j = 0;
    reg [8*100:1] message;
    inout [7:0] out_character;
    inout [8*100:1] out_message;
    reg [7:0] temp;
    initial
        begin
        file = $fopen("message.txt", "r");
        file2 = $fopen("outmessage.txt", "w");
        r = $fgets(message, file);
        //$display("%s", message);
        end

    initial
        begin
        clock = 1;  
        end

    always #10 clock = ~clock;

    Keyboard kuut(.in_message(message), .clock(clock), .out_character(out_character));
    Monitor  muut(.clock(clock), .in_character(out_character), .out_message(out_message));
    
    //initial $monitor("%s", out_message);

    initial 
        begin
            $monitor ("%s", out_message); 
            #100000

            while (i > 0)
                begin
                    for (j = 0; j < 8; j++)
                        temp[j] = out_message[i+j];
                    i = i-8;
                    $fwrite(file2, "%c", temp);
                end
            
            $fclose(file);
            $fclose(file2);            
            $finish;
        end
endmodule

module User(clock, outgoing_message, encrypted_message, incoming_data, transmitted_data);

	/*
		outgoing_message is provided by this user.
		incoming_message is received by this user from the user he's communicating with.
		encrypted_message is a proof of concept for encryption. It displays how the 
		encrypted outgoing_message looks like.
	*/
    
    input  clock;
    inout  [8*100:1] incoming_message;
    inout  [7:0] keyboard_out;
    inout  [7:0] incoming_monitor; // Monitor In
    inout  [7:0] outgoing_monitor; // done
    inout  [7:0] encrypted_monitor; // done            
    inout  [7:0] transmitted_data;
    inout  [7:0] incoming_data;
	inout  display_clock;
	inout  [8*100:1] encrypted_message;

    input  [8*100:1] outgoing_message;

	Keyboard 	keyboard		  (.clock(clock), .in_message(outgoing_message), .out_character(keyboard_out));
    Messenger 	messenger		  (.clock(clock), .incoming_monitor(incoming_monitor), .keyboard_input(keyboard_out), .display_clock(display_clock), .transmitted_data(transmitted_data), .incoming_data(incoming_data), .outgoing_monitor(outgoing_monitor), .encrypted_monitor(encrypted_monitor));
    Monitor 	outgoingMonitor	  (.clock(clock), .in_character(outgoing_monitor), .out_message(outgoing_message));
	Monitor 	incomingMonitor	  (.clock(clock), .in_character(incoming_monitor), .out_message(incoming_message));
    Monitor 	encryptedMonitor  (.clock(clock), .in_character(encrypted_monitor), .out_message(encrypted_message));

endmodule

//Messenger Module

module Messenger(clock, enable, incoming_monitor, keyboard_input, outgoing_monitor, encrypted_monitor, display_clock, transmitted_data, incoming_data);

    inout clock; // input
    inout enable;
	inout [7:0] encrypted_incoming;
    inout [7:0] incoming_monitor; // done
    inout [7:0] outgoing_monitor; // done
    inout [7:0] encrypted_monitor; // done            
    inout [7:0] keyboard_input; // input

    //inout transmitted_data; // done
    //inout incoming_data; // done

	inout [7:0] transmitted_data; // done
    inout [7:0] incoming_data; // done
	
	inout display_clock;
    reg   [7:0] key = 43;
    
	// Transmission Circuit
	assign outgoing_monitor = keyboard_input;
	encrypter encrypt(.message(keyboard_input), .key(key), .encryptedMessage(encrypted_monitor));
	assign transmitted_data = encrypted_monitor;
	//encoder encode(.clock(clock), .parallelIn(encrypted_monitor), .serialOut(transmitted_data), .keyboard_clock(display_clock));

	// Reception Circuit
	//decoder decode(.clock(clock), .serialIn(incoming_data), .parallelOut(encrypted_incoming));
	assign encrypted_incoming = incoming_data;
	decrypter decrypt(.message(encrypted_incoming), .key(key), .decryptedMessage(incoming_monitor));

endmodule
