module tbALU_LIM_SIN_RIN;
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
        $dumpfile("ALU_LIM_SIN_RIN.vcd");
        $dumpvars(0, tbALU_LIM_SIN_RIN.clk);
        $dumpvars(0, tbALU_LIM_SIN_RIN.rst);
        $dumpvars(0, UUT.PC.PC);
        $dumpvars(0, UUT.READOM.instruction);
        $dumpvars(0, UUT.REG.registers[0]);
        $dumpvars(0, UUT.REG.registers[1]);
        $dumpvars(0, UUT.REG.registers[2]);
        $dumpvars(0, UUT.REG.registers[3]);
        $dumpvars(0, UUT.REG.registers[6]);
        $dumpvars(0, UUT.RAM.RAM[8]);
        rst = 1'b1;
        #10

        rst = 1'b0;
        
        #80;
        $finish;
    end

    initial begin
        $monitor("Time in ns: %3t , PC: %d , Instruction: %b , Q0: %d , Q1: %d , Q3: %d , Q6: %d , RAM[8]: %d", 
                 $time,
                 UUT.PC.PC,
                 UUT.READOM.instruction,
                 UUT.REG.registers[0],
                 UUT.REG.registers[1],
                 UUT.REG.registers[3],
                 UUT.REG.registers[6],
                 UUT.RAM.RAM[8]
        );
    end
endmodule