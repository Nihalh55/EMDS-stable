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

    integer i = 793;
    integer j = 0;
    integer r1, r2;

    initial
        begin
        $dumpfile ("EMDS.vcd");
        $dumpvars (0, User1, User2);
        enter_message_here_user1 = $fopen("outgoing_message_user1.txt", "r");
        enter_message_here_user2 = $fopen("outgoing_message_user2.txt", "r");

        incoming_file_user1 = $fopen("incoming_message_user1.txt", "w");
        incoming_file_user2 = $fopen("incoming_message_user2.txt", "w");

        r1 = $fgets(message_user1, enter_message_here_user1);
        r2 = $fgets(message_user2, enter_message_here_user2);        
        end

    //inout [7:0] user1_to_user2;
    //inout [7:0] user2_to_user1;
    inout user1_to_user2;
    inout user2_to_user1;
    User User1 (.clock(clock), .enter_text_here(message_user1), .receiving_message_to_file(write_to_file1), .out(user1_to_user2), .in(user2_to_user1));
    User User2 (.clock(clock), .enter_text_here(message_user2), .receiving_message_to_file(write_to_file2), .out(user2_to_user1), .in(user1_to_user2));

    reg [7:0] temp1;
    reg [7:0] temp2;
    initial 
        begin
            #10000
            $display ("\n\n\tUSER1\n\n Outgoing Message:%s\n\n Incoming Message:%s", message_user1, write_to_file1);              
            $display ("\n\n\tUSER2\n\n Outgoing Message:%s\n\n Incoming Message:%s", message_user2, write_to_file2);              
            
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