module CLL_RET;

    reg clk;
    reg rst;

    CPU UUT(
        .clk(clk),
        .rst(rst)
    );

    initial begin
        clk = 1'b0;
        forever #5 clk = ~clk;
    end

    initial begin
        $dumpfile("CLL_RET.vcd");
        $dumpvars(0, CLL_RET.clk);
        $dumpvars(0, CLL_RET.rst);
        $dumpvars(0, UUT.PC.PC);
        $dumpvars(0, UUT.READOM.instruction);
        $dumpvars(0, UUT.REG.registers[0]);
        $dumpvars(0, UUT.REG.registers[1]);
        $dumpvars(0, UUT.REG.registers[2]);
        $dumpvars(0, UUT.REG.registers[5]);
        $dumpvars(0, UUT.REG.registers[7]);

        rst = 1'b1;
        #10;

        rst = 1'b0;
        #70;

        $finish;
    end
    
    initial begin
        $monitor("Time: %3t | PC: %d | Instruction %b | Q0: %d | Q1: %d | Q2: %d | Q5: %d | Q7: %d |" ,
        $time,
        UUT.PC.PC,
        UUT.READOM.instruction,
        UUT.REG.registers[0],
        UUT.REG.registers[1],
        UUT.REG.registers[2],
        UUT.REG.registers[5],
        UUT.REG.registers[7]
        );
    end
    
endmodule