module registerfile (
    input clk,
    input rst,
    input [7:0] I,
    input we,
    input [2:0] wsel,
    input [2:0] rsel_1,
    input [2:0] rsel_2,
    output [7:0] Q1,
    output [7:0] Q2
);

    integer i;

    reg [7:0] registers [0:7];

    always @(posedge clk or posedge rst) begin
        if (rst == 1'b1) begin
            for (i = 0 ; i < 8 ; i = i + 1) begin
                registers[i] <= 8'b0;
            end
        end
            else if (we == 1'b1) begin
                registers[wsel] <= I;
            end
    end

    assign Q1 = registers[rsel_1];
    assign Q2 = registers[rsel_2];

endmodule
