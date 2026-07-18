module StatusRegister (
    input clk,
    input rst,
    input neg_flag,
    input zero_flag,
    input c_out,
    input of_flag,
    input writeenable,
    output reg negative,
    output reg zero,
    output reg carry,
    output reg overflow
);

    always @(posedge clk or posedge rst) begin
        if (rst == 1'b1) begin
            {negative, zero, carry, overflow} <= 0;
        end
        else if (writeenable == 1'b1) begin
            {negative, zero, carry, overflow} <= {neg_flag, zero_flag, c_out, of_flag};
        end
    end
    
endmodule