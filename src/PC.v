module PC_1 (
    input clk,
    input rst,
    input [7:0] I,
    input load,
    output reg [7:0] PC
);
    integer i;


    always @(posedge clk or posedge rst) begin
        if (rst == 1'b1) begin
            for (i = 0; i < 8; i = i + 1) begin // the for loop is redundant, a basic <= 16'b0 is enough!
                PC[i] <= 0;
            end
        end
        else if (load == 1'b1) begin
            PC <= I;
        end
        else
            PC <= PC + 1'b1;
        end
endmodule
