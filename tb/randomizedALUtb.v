module randomizedALUtb;
    reg [7:0] I1;
    reg [7:0] I2;
    reg [2:0] sel;
    reg c_in;
    wire [7:0] op;
    wire c_out;
    wire zero_flag;
    wire neg_flag;
    wire of_flag;

    integer i;

    ALU UUT(
        .I1(I1),
        .I2(I2),
        .sel(sel),
        .c_in(c_in),
        .op(op),
        .c_out(c_out),
        .zero_flag(zero_flag),
        .neg_flag(neg_flag),
        .of_flag(of_flag)
    );
    
    initial begin

        $monitor("Sel = %b | I1 = %b | I2 = %b | Output = %b | Output = %d | Zero = %b | Negative = %b | Carry = %b | Overflow = %b",
        sel,
        I1,
        I2,
        op,
        op,
        zero_flag,
        neg_flag,
        c_out,
        of_flag);

        I1 = {4'b0000, 4'b1111 & $random};
        I2 = {4'b0000, 4'b1111 & $random};
        c_in = 1'b0;

        for (i = 0; i < 9; i = i + 1) begin
            sel = i;
            #10;
        end
        
    end
endmodule