module BJPtb;
    
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
        $dumpfile("BJP.vcd");
        $dumpvars(0, BJPtb.clk);
        $dumpvars(0, BJPtb.rst);
        $dumpvars(0, UUT.PC.PC);
        $dumpvars(0, UUT.READOM.instruction);
        $dumpvars(0, UUT.REG.registers[0]);
        $dumpvars(0, UUT.REG.registers[1]);
        $dumpvars(0, UUT.REG.registers[2]);
        $dumpvars(0, UUT.REG.registers[3]);

        rst = 1'b1;
        #10;

        rst = 1'b0;
        #60;
        $finish;
    end

    initial begin
        $monitor("Time: %3t , PC: %d , Instruction: %b , Q0: %d , Q1: %d , Q2: %d , Q3: %d",
            $time,
            UUT.PC.PC,
            UUT.READOM.instruction,
            UUT.REG.registers[0],
            UUT.REG.registers[1],
            UUT.REG.registers[2],
            UUT.REG.registers[3]
            );
    end
endmodule