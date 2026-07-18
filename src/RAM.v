module RAM (
    input ram_we,
    input clk,
    input rst,
    input [7:0] write_data,
    input [7:0] address_sel,
    output [7:0] read_data
);

    integer i;
    integer k;

    reg [7:0] RAM [0:255];

    initial begin
        for (i = 0; i < 256; i = i + 1) begin //for loop shouldn't be in here if its a real cpu, i set ram array to 0 for simulations
            RAM[i] = 8'b0;
        end
    end

    always @(posedge clk or posedge rst) begin
        if (rst == 1'b1) begin
            for (k = 0; k < 256; k = k + 1) begin
                RAM[k] <= 8'b0;
            end
        end
        else if (ram_we == 1'b1) begin
            RAM[address_sel] <= write_data;
        end
    end

    assign read_data = RAM[address_sel]; //asenkron read

endmodule
