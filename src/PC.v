module PC_1 (
    input clk,
    input rst,
    input [7:0] I,
    input load,
    output reg [7:0] PC
);


    always @(posedge clk or posedge rst) begin
        if (rst == 1'b1) begin
                PC <= 8'b00000000;
        end
        else if (load == 1'b1) begin
            PC <= I;
        end
        else
            PC <= PC + 1'b1;
        end
endmodule

// ltp of PC is determined as 35 without opt