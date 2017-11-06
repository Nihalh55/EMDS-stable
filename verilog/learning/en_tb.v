module en_tb;
    reg [7:0] message;
    wire [7:0] encrypted_message;
    wire [7:0] outputt;    
    reg [7:0] key;

    encrypter uut(.message(message), .key(key), .encryptedMessage(encrypted_message));
    decrypter dut(.message(encrypted_message), .key(key), .decryptedMessage(outputt));
    initial
        begin
            message = 8'b01010101;
            key = 8'b01000011;

            #10
            message = 8'b00001111;

            #10
            message = 8'b11110000 ;                       

            $finish;
        end
    
    initial $monitor("%b %b %b", message, encrypted_message, outputt);

endmodule