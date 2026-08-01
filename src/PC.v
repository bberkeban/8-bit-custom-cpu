module the_incrementer (
    input [7:0] PrevPC,
    output [7:0] PCload
);

    wire c0 = PrevPC[0];
    wire c1 = &PrevPC[1:0];
    wire c2 = &PrevPC[2:0];
    wire c3 = &PrevPC[3:0];
    wire c4 = &PrevPC[4:0];
    wire c5 = &PrevPC[5:0];
    wire c6 = &PrevPC[6:0];
    
    assign PCload[0] = ~PrevPC[0];
    assign PCload[1] = PrevPC[1] ^ c0;
    assign PCload[2] = PrevPC[2] ^ c1;
    assign PCload[3] = PrevPC[3] ^ c2;
    assign PCload[4] = PrevPC[4] ^ c3;
    assign PCload[5] = PrevPC[5] ^ c4;
    assign PCload[6] = PrevPC[6] ^ c5;
    assign PCload[7] = PrevPC[7] ^ c6;

endmodule

module PC3 (
    input clk,
    input rst,
    input [7:0] I,
    input load,
    output reg [7:0] PC,
    output [7:0] incremented_PC
);

    wire [7:0] PrevPC = PC;
    wire [7:0] incrementedPC;

    the_incrementer INC(
        .PrevPC(PrevPC),
        .PCload(incrementedPC)
    );

    always @(posedge clk or posedge rst) begin
        if (rst == 1'b1) begin
            PC <= 8'd0;
        end
        else if (load == 1'b1) begin
            PC <= I;
        end
        else
            PC <= incrementedPC;
    end

    assign incremented_PC = incrementedPC;
    
endmodule

// ltp is 9