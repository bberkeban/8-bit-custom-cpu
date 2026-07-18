module CPU(
    input clk,
    input rst,
    output [7:0] debug_op
    );

    wire zero; // to CU from SR
    wire negative;
    wire overflow;
    wire carry;
    wire [15:0] instr;

    wire we_reg;
    wire [2:0] wsel_reg;
    wire [2:0] rsel_1_reg;
    wire [2:0] rsel_2_reg;
    wire [7:0] im_reg;

    wire [2:0] sel_ALU;

    wire load_PC;
    wire [7:0] load_data_PC;
    wire mux_sel_PC;

    wire we_ram;

    wire we_sr;

    wire [2:0] MUX_sel_reg;

    wire [7:0] Q1;
    wire [7:0] Q2;

    wire [7:0] PCSEL;
    reg [7:0] finalizedPCload;

    reg [7:0] registerwritedata;

    wire [7:0] op; //ALU op and flag outputs
    wire c_out_ALU_op;
    wire zero_flag_ALU_op;
    wire neg_flag_ALU_op;
    wire of_flag_ALu_op;

    wire [7:0] ram_read_data;

    always @(*) begin //register write data selection MUX
        case (MUX_sel_reg)
            3'b000 : registerwritedata = op; //ALU op wire tanımla
            3'b001 : registerwritedata = ram_read_data; //ram read data wire tanımla
            3'b010 : registerwritedata = im_reg;
            3'b011 : registerwritedata = Q1;
            3'b100 : registerwritedata = PCSEL + 8'b00000001;
            default: registerwritedata = 8'b0;
        endcase
    end

    always @(*) begin //PC load data selection mux
        case (mux_sel_PC)
            1'b0 : finalizedPCload = load_data_PC;
            1'b1 : finalizedPCload = Q1; //Q1 wire tanımla
            default: finalizedPCload = 8'b0;
        endcase
    end


    ControlUnit CU(
        .instr(instr),
        .zero(zero),
        .negative(negative),
        .overflow(overflow),
        .carry(carry),

        .we_reg(we_reg),
        .wsel_reg(wsel_reg),
        .rsel_1_reg(rsel_1_reg),
        .rsel_2_reg(rsel_2_reg),
        .im_reg(im_reg),

        .sel_ALU(sel_ALU),

        .load_PC(load_PC),
        .load_data_PC(load_data_PC),
        .mux_sel_PC(mux_sel_PC),

        .we_ram(we_ram),

        .we_sr(we_sr),

        .MUX_sel_reg(MUX_sel_reg)
    );
    
    ROM READOM(
        .instruction(instr),
        .PC_select(PCSEL)
    );
    
    PC_1 PC(
        .clk(clk),
        .rst(rst),
        .I(finalizedPCload),
        .load(load_PC),
        .PC(PCSEL) //mux lazım değilmiş direct connection
    );
    
    registerfile REG(
        .clk(clk),
        .rst(rst),
        .I(registerwritedata),
        .we(we_reg),
        .wsel(wsel_reg),
        .rsel_1(rsel_1_reg),
        .rsel_2(rsel_2_reg),
        .Q1(Q1),
        .Q2(Q2)
    );
    
    ALU ALU(
        .I1(Q1),
        .I2(Q2),
        .sel(sel_ALU),
        .c_in(1'b0), //carry in?
        .op(op),
        .c_out(c_out_ALU_op),
        .zero_flag(zero_flag_ALU_op),
        .neg_flag(neg_flag_ALU_op),
        .of_flag(of_flag_ALu_op)
    );
    StatusRegister SR(
        .clk(clk),
        .rst(rst),
        .neg_flag(neg_flag_ALU_op),
        .zero_flag(zero_flag_ALU_op),
        .c_out(c_out_ALU_op),
        .of_flag(of_flag_ALu_op),
        .writeenable(we_sr),
        .negative(negative),
        .zero(zero),
        .carry(carry),
        .overflow(overflow)
    );
    
    RAM RAM(
        .ram_we(we_ram),
        .clk(clk),
        .rst(rst),
        .write_data(Q1),
        .address_sel(Q2),
        .read_data(ram_read_data)
    );

    assign debug_op = Q1;

endmodule
