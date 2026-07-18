module ALU (
    input [7:0] I1,
    input [7:0] I2,
    input [2:0] sel,
    input c_in,
    output reg [7:0] op,
    output reg c_out,
    output reg zero_flag,
    output reg neg_flag,
    output reg of_flag
);
// sel 000 addition, sel 001 subtraction, sel 010 shift right /2, sel 011 shift left *2, sel 100 bitwise AND, sel 101 bitwise XOR, sel 110 bitwise OR, sel 111 aritmetik shift <<<

    always @(*) begin

        c_out = 1'b0;
        zero_flag = 1'b0; 
        of_flag = 1'b0;
        op = 8'b0;
        neg_flag = 1'b0;

        case (sel)
        

            3'b000 : begin 
                {c_out,op} = I1 + I2 + {7'b0, c_in};
                of_flag = (~op[7] & I1[7] & I2[7]) | (op[7] & ~I1[7] & ~I2[7]);
            end 
            3'b001 : begin 
                {c_out,op} = I1 - I2;
                of_flag = (op[7] & ~I1[7] & I2[7]) | (~op[7] & I1[7] & ~I2[7]);
            end
            3'b010 : begin //shift right
                c_out = I1[0];
                op = {1'b0, I1[7:1]};
            end
            3'b011 : begin //shift left
                c_out = I1[7];
                op = {I1[6:0], 1'b0};
                of_flag = (op[7] ^ I1[7]);
            end
            3'b100 : begin
                op = I1 & I2;
            end
            3'b101 : begin
                op = I1 ^ I2;
            end
            3'b110 : begin
                op = I1 | I2;
            end
            3'b111 : begin // aritmetik right shift
                c_out = I1[0];
                op = {I1[7],I1[7:1]};
            end

            default: ; 
        endcase
        zero_flag = ~|op;
        neg_flag = op[7];
    end
    
endmodule
