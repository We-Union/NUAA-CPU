`include "./DataPath/alu_ctrl.v"
`include "./DataPath/alu.v"
`include "./DataPath/dm.v"
`include "./DataPath/Ext.v"
`include "./DataPath/im.v"
`include "./DataPath/mux.v"
`include "./DataPath/npc.v"
`include "./DataPath/pc.v"
`include "./DataPath/regfile.v"

module data_path(RegDst, Branch, MemtoReg, ALUOp, 
    MemWrite, ALUSrc, RegWrite, Jump, Ext_op, clock, reset, instruction);
    input           RegDst;
    input           Branch;
    input           MemtoReg;
    input   [ 2: 0] ALUOp;
    input           MemWrite;
    input           ALUSrc;
    input           RegWrite;
    input           Jump;
    input           Ext_op;

    input           clock;
    input           reset;

    output  [31: 0] instruction;

    // variable
    wire    [31: 0] PC;             // value of pc
    wire    [31: 0] NPC;            // next status of pc 
    wire    [31: 0] ext_out;        // extention of 16-bit   
    wire    [31: 0] instruction;    // instruction gotten by im
    wire            zero;           // zero generated by ALU

    wire    [31: 0] regfile_out1;   // out1 of regfile
    wire    [31: 0] regfile_out2;   // out2 of regfile

    wire    [ 4: 0] mux1_out;       // IF ID
    wire    [31: 0] mux2_out;       // ID EX
    wire    [31: 0] mux3_out;       // MEM WB

    wire    [ 3: 0] alu_ctrl_out;   // out of alu controller
    wire    [31: 0] alu_out;        // out of alu
    wire    [31: 0] dm_out;         // out of dm

    // pc module
    pc program_counter(
        .NPC(NPC),
        .clock(clock),
        .reset(reset),
        .PC(PC)
    );

    npc next_program_counter(
        .PC(PC),
        .branch(Branch),
        .zero(zero),
        .jump(Jump),
        .Ext(ext_out),
        .jump_Addr(instruction[25:0]),
        .NPC(NPC)
    );

    // IF module, from pc value to the cycle's instructions
    im_4k instruction_memory(
        .pc(PC),
        .out_instr(instruction)
    );

    // ID module
    mux1 IF_ID_mux(
        .rt(instruction[20:16]),
        .rd(instruction[15:11]),
        .RegDst(RegDst),
        .DstReg(mux1_out)
    );

    regfile register_files(
        .rs(instruction[25:21]),
        .rt(instruction[20:16]),
        .rd(mux1_out),
        .data(mux3_out),
        .RegWrite(RegWrite),
        .clock(clock),
        .reset(reset),
        .out1(regfile_out1),
        .out2(regfile_out2)
    );

    Ext extension_unit(
        .input_num(instruction[15:0]),
        .Ext_op(Ext_op),
        .output_num(ext_out) 
    );

    alu_ctrl ALU_controller(
        .funct(instruction[5:0]),
        .ALUOp(ALUOp),
        .alu_ctrl_out(alu_ctrl_out)
    );

    // EX module
    mux2 ID_EX_mux(
        .out2(regfile_out2),
        .Ext(ext_out),
        .ALUSrc(ALUSrc),
        .DstData(mux2_out)
    );

    alu ALU(
        .op_num1(regfile_out1),
        .op_num2(mux2_out),
        .shamt(instruction[10:6]),
        .alu_ctrl_out(alu_ctrl_out),
        .zero(zero),
        .alu_out(alu_out)
    );

    // always @(*) begin
    //     if (alu_ctrl_out)
    // end

    // MEM module
    dm_4k data_memory(
        .alu_out(alu_out),
        .out2(regfile_out2),
        .MemWrite(MemWrite),
        .clock(clock),
        .dm_out(dm_out)
    );

    // WB module
    mux3 MEM_WB_mux(
        .dm_out(dm_out),
        .alu_out(alu_out),
        .MemtoReg(MemtoReg),
        .WriteData(mux3_out)
    );

endmodule