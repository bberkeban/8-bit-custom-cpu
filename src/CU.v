module ControlUnit (

    input [15:0] instr, //instruction opcode!
    input zero,
    input negative,
    input overflow,
    input carry,

    output reg we_reg,
    output reg [2:0] wsel_reg,
    output reg [2:0] rsel_1_reg,
    output reg [2:0] rsel_2_reg,
    output reg [7:0] im_reg,

    output reg [2:0] sel_ALU,

    output reg load_PC,
    output reg [7:0] load_data_PC,
    output reg mux_sel_PC, // 0 load from PC, 1 load from REG

    output reg we_ram,

    output reg we_sr, //status register write enable

    output reg [2:0] MUX_sel_reg //000 ALU, 001 RAM RIN, 010 LIM, 011 Write Back, 100 PC
);
    always @(*) begin

        {we_ram, we_reg, load_PC, we_sr} = 4'b0000;
        wsel_reg = 0;
        rsel_1_reg = 0;
        rsel_2_reg = 0;
        im_reg = 0;
        sel_ALU = 0;
        load_data_PC = 0;
        mux_sel_PC = 0;
        MUX_sel_reg = 0;

        case (instr[15:12])

            4'b0000 : begin
                sel_ALU = instr[11:9];
                wsel_reg = instr[8:6];
                rsel_1_reg = instr[5:3];
                rsel_2_reg = instr[2:0];
                we_reg = 1'b1;
                MUX_sel_reg = 3'b000;
                we_sr = 1'b1;
            end
            
            4'b0001 : begin
                we_reg = 1'b1;
                wsel_reg = instr[11:9];
                im_reg = instr[7:0];
                MUX_sel_reg = 3'b010;
            end

            4'b0010 : begin
                we_reg = 1'b1;
                wsel_reg = instr[11:9];
                rsel_1_reg = instr[8:6];
                MUX_sel_reg = 3'b011;
            end

            4'b0011 : begin
                we_ram = 1'b1;
                rsel_1_reg = instr[11:9];
                rsel_2_reg = instr[8:6];
            end

            4'b0100 : begin
                we_reg = 1'b1;
                wsel_reg = instr[11:9];
                rsel_2_reg = instr[8:6];
                MUX_sel_reg = 3'b001;
            end

            4'b0101 : begin
                
                we_sr = 1'b0;
                load_PC = 1'b0;
                load_data_PC = instr[7:0];
                mux_sel_PC = 1'b0;

                case (instr[11:8])

                    4'b0000 : load_PC = zero;

                    4'b0001 : load_PC = ~zero;

                    4'b0010 : load_PC = negative ^ overflow; //<
                    
                    4'b0011 : load_PC = ~(negative ^ overflow); //>=

                    4'b0100 : load_PC = ~(negative ^ overflow) & ~zero; // >

                    4'b0101 : load_PC = (negative ^ overflow) | zero; // <=

                    4'b0110 : load_PC = carry;

                    4'b0111 : load_PC = ~carry;

                    4'b1000 : load_PC = ~(carry | zero);

                    4'b1001 : load_PC = carry | zero;

                    4'b1010 : load_PC = overflow;

                    4'b1011 : load_PC = ~overflow;

                    4'b1100 : load_PC = ~negative;

                    4'b1101 : load_PC = negative;

                    4'b1110 : load_PC = 1'b1;

                    4'b1111 : load_PC = 1'b0;

                    default: ;
                endcase
            end

            4'b1000 : begin
                load_PC = 1'b1;
                load_data_PC = instr[7:0];
                we_reg = 1'b1;
                wsel_reg = 3'b111;
                MUX_sel_reg = 3'b100;
                mux_sel_PC = 1'b0;
            end

            4'b1001 : begin
                load_PC = 1'b1;
                rsel_1_reg = 3'b111;
                mux_sel_PC = 1'b1;
            end
            default: begin
                {we_ram, we_reg, load_PC, we_sr} = 4'b0000;
            end
        endcase
    end
endmodule
