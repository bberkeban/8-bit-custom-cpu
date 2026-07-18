module ROM (
    output[15:0] instruction,
    input [7:0] PC_select
);
    reg [15:0] ROMarray [0:255];

    initial begin
        $readmemb("ROM_opcode.txt", ROMarray);
    end

    assign instruction = ROMarray[PC_select];
    
endmodule

