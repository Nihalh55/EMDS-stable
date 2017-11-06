module main;
    reg clock;
    integer file, file2, r;
    integer i = 793;
    integer j = 0;
    reg [8*100:1] message;
    inout [8*100:1] out_message;
    inout [8*100:1] encrypted_message;
    
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

    User uut(.clock(clock), .in_message(message), .encrypted_message(encrypted_message), .out_message(out_message));
    
    //initial $monitor("%s", out_message);

    initial 
        begin
            #100000
            $display ("%s\n\n%s", encrypted_message, out_message); 

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