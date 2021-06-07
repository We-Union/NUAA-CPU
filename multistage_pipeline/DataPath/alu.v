module alu(op_num1, op_num2, shamt, alu_ctrl_out, zero, alu_out);
    input      [31:0]  op_num1;        // rs
    input      [31:0]  op_num2;        // rt
    input      [ 3:0]  alu_ctrl_out;
    input      [ 4:0]  shamt;
    output             zero;           // zero genenrated by alu
    output reg [31:0]  alu_out;        // alu_out generated by alu

    parameter ADD   = 4'b0010;
    parameter SUB   = 4'b0110;
    parameter AND   = 4'b0000;
    parameter OR    = 4'b0001;
    parameter SLT   = 4'b0111;
    parameter XOR   = 4'b0011;
    parameter NOR   = 4'b1010;
    parameter LUI   = 4'b0101;
    parameter SLL   = 4'b1000;
    parameter SRL   = 4'b0100;
    parameter SRA   = 4'b1100;

    always @(*) 
    begin
        case (alu_ctrl_out)
            AND : 
            begin
                alu_out = op_num1 & op_num2;
            end
           
            OR  : 
            begin
                alu_out = op_num1 | op_num2;
                // $display("op_num1 : %h | op_num2 : %h | or out : %h", op_num1, op_num2, alu_out);
            end

            ADD : 
            begin
                alu_out = op_num1 + op_num2;
                // $display("op_num1 : %h | op_num2 : %h | add out : %h", op_num1, op_num2, alu_out);
            end

            SUB : 
            begin
                alu_out = op_num1 - op_num2;
                // $display("op_num1 : %h | op_num2 : %h | sub out : %h", op_num1, op_num2, alu_out);
            end

            XOR : 
            begin
                alu_out = op_num1 ^ op_num2;
            end

            NOR:
            begin
                alu_out = ~(op_num1 | op_num2);
            end

            LUI : 
            begin
                alu_out = {op_num2, 16'h0000};
                // $display("op_num2 : %h | lui out : %h", op_num2, alu_out);
            end

            SLL : 
            begin
                alu_out = op_num2 << shamt;
                // $display("op_num2 : %h | sll out : %h", op_num2, alu_out);
            end

            SRL :
            begin
                alu_out = op_num2 >> shamt;
            end

            SRA :
            begin
                alu_out = $signed(op_num2) >>> shamt;
            end

            SLT : 
            begin
                alu_out = (op_num1 < op_num2) ? 32'b1 : 32'b0;
                // $display("op_num1 : %h | op_num2 : %h | slt out : %h", op_num1, op_num2, alu_out);
            end
        endcase
    end

    assign zero = (alu_out == 0) ? 1 : 0;

endmodule