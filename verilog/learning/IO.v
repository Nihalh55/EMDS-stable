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