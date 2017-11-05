`define EOF 32'hFFFF_FFFF
`define NULL 0
module script;
integer file, file2, r;
reg [80*8:1] command;
reg [31:0] addr, data;
initial
    begin 
    file = $fopen("script.txt", "r");
    file2 = $fopen("script_out.txt", "w");
    
    while (!$feof(file))
        begin
        r = $fscanf(file, " %s %h %h \n", command, addr, data);
        case (command)
        "read":
            begin
            $display("READ mem[%h], expect = %h", addr, data);
            $fwrite(file2, "READ mem[%h], expect = %h \n", addr, data);
            end
        "write":
            begin
            $display("WRITE mem[%h] = %h", addr, data);
            $fwrite(file2, "WRITE mem[%h] = %h \n", addr, data);
            end           
        default:
            $display("Unknown command '%0s'", command);
        endcase
        end // while not EOF

    $fwrite(file2, "%c", 32'hFFFF_FFFF);
    $fclose(file);
    $fclose(file2);

    end // initial
endmodule // script