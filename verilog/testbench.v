module main;
    reg clock;
    integer outgoing_file_user1;
    integer outgoing_file_user2;

    integer incoming_file_user1;
    integer incoming_file_user2;

    reg [8*100:1] outgoing_message_user1;
    reg [8*100:1] outgoing_message_user2;    

    inout [8*100:1] incoming_message_user1;
    inout [8*100:1] incoming_message_user2;
    
    inout [8*100:1] encrypted_message_user1;
    inout [8*100:1] encrypted_message_user2;    
    
    integer i = 793;
    integer j = 0;
    integer r1, r2;
    
    initial
        begin
        outgoing_file_user1 = $fopen("outgoing_message_user1.txt", "r");
        outgoing_file_user2 = $fopen("outgoing_message_user2.txt", "r");

        incoming_file_user1 = $fopen("incoming_message_user1.txt", "w");
        incoming_file_user2 = $fopen("incoming_message_user2.txt", "w");

        r1 = $fgets(outgoing_message_user1, outgoing_file_user1);
        r2 = $fgets(outgoing_message_user2, outgoing_file_user2);        
        end

    initial
        begin
        clock = 1;  
        end

    always #10 clock = ~clock;

    User user1(.clock(clock), .outgoing_message(outgoing_message_user1), .encrypted_message(encrypted_message_user1), .incoming_message(incoming_message_user1));
    User user2(.clock(clock), .outgoing_message(outgoing_message_user2), .encrypted_message(encrypted_message_user2), .incoming_message(incoming_message_user2));
    
    reg [7:0] temp1
    reg [7:0] temp2;
    initial 
        begin
            #100000
            $display ("USER1\n\n%s\n\n%s\n\n%s", outgoing_message_user1, encrypted_message_user1, incoming_message_user1);
            $display ("USER2\n\n%s\n\n%s\n\n%s", outgoing_message_user2, encrypted_message_user2, incoming_message_user2);              

            while (i > 0)
                begin
                    for (j = 0; j < 8; j++)
                    begin
                        temp1[j] = incoming_message_user1[i+j];
                        temp2[j] = incoming_message_user2[i+j];
                    end
                    i = i-8;
                    $fwrite(incoming_file_user1, "%c", temp1);
                    $fwrite(incoming_file_user2, "%c", temp2);
                end
            
            $fclose(file);
            $fclose(file2);            
            $finish;
        end
endmodule