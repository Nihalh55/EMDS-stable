`timescale 1ns/1ps
module main;
    reg clock;
    
    initial
        begin
        clock = 1;  
        end

    always #1 clock = ~clock;

    integer enter_message_here_user1;
    integer enter_message_here_user2;    

    integer incoming_file_user1;
    integer incoming_file_user2;
    
    reg [8*100:1] message_user1;
    reg [8*100:1] message_user2;

    inout [8*100:1] write_to_file1;
    inout [8*100:1] write_to_file2;
    inout [8*100:1] encrypted_user2_message;
    inout [8*100:1] encrypted_user1_message;

    reg [3:0] password_user1;
    reg [3:0] password_user2;

    integer i = 793;
    integer j = 0;
    integer r1, r2;

    initial
        begin
        $dumpfile ("EMDS.vcd");
        $dumpvars (0, User1, User2);
        enter_message_here_user1 = $fopen("user1_enter_message_here.txt", "r");
        enter_message_here_user2 = $fopen("user2_enter_message_here.txt", "r");

        incoming_file_user1 = $fopen("incoming_message_user1.txt", "w");
        incoming_file_user2 = $fopen("incoming_message_user2.txt", "w");
        
        r1 = $fgets(message_user1, enter_message_here_user1);
        r2 = $fgets(message_user2, enter_message_here_user2);        
        end

    inout [7:0] user1_to_user2;
    inout [7:0] user2_to_user1;
    
    User User1 (.clock(clock), .enter_text_here(message_user1), .receiving_message_to_file(write_to_file1), .password(password_user1), .out(user1_to_user2), .in(user2_to_user1), .encrypted_message(encrypted_user2_message));
    User User2 (.clock(clock), .enter_text_here(message_user2), .receiving_message_to_file(write_to_file2), .password(password_user2), .out(user2_to_user1), .in(user1_to_user2), .encrypted_message(encrypted_user1_message));

    reg [7:0] temp1;
    reg [7:0] temp2;
    initial 
        begin
            password_user1 = 4'b0101;
            password_user2 = 4'b0101;
            #10000
            $display ("\n\n\tUSER1\n\n|Outgoing Message\n|%100s|\n|Incoming Message\n|%100s|\n|Undecrypted Incoming Message\n|%100s|", message_user1, write_to_file1, encrypted_user2_message);              
            $display ("\n\n\tUSER2\n\n|Outgoing Message\n|%100s|\n|Incoming Message\n|%100s|\n|Undecrypted Incoming Message\n|%100s|", message_user2, write_to_file2, encrypted_user1_message);              
            
            while (i > 0)
                begin
                    for (j = 0; j < 8; j++)
                    begin
                        temp1[j] = write_to_file1[i+j];
                        temp2[j] = write_to_file2[i+j];
                    end
                    i = i-8;
                    $fwrite(incoming_file_user1, "%c", temp1);
                    $fwrite(incoming_file_user2, "%c", temp2);
                end
            
            $fclose(enter_message_here_user1);
            $fclose(enter_message_here_user2);
            $fclose(incoming_file_user1);
            $fclose(incoming_file_user2);
            $finish;
        end
endmodule