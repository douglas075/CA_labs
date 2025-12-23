module Control
(
    input           [6:0]   opcode_i,
    output  reg             RegWrite_o,
    output  reg             MemtoReg_o,
    output  reg             MemRead_o,
    output  reg             MemWrite_o,
    output  reg     [1:0]   ALUOp_o,
    output  reg             ALUSrc1_o,
    output  reg             ALUSrc2_o,
    output  reg             Branch_o,
    output  reg             Jump_o,
    output  reg             JumpR_o,
    output  reg             Finish_o
);


always @ (*) begin
    ALUOp_o     = 2'b0;
    ALUSrc1_o   = 0; // 1 for pc
    ALUSrc2_o   = 0; // 1 for imm
    Branch_o    = 0;
    MemRead_o   = 0;
    MemWrite_o  = 0;
    RegWrite_o  = 0;
    MemtoReg_o  = 0;
    Jump_o  = 0;
    JumpR_o  = 0;
    Finish_o = 0;

    case (opcode_i)
        // convention
        // 00 add (load/store)
        // 01 sub (branch)
        // 10 funct3,7 (R/I type)
        // 11 other (advanced) 

        7'b0110011: begin // R-type
            ALUOp_o     = 2'b10;
            ALUSrc1_o   = 0;
            ALUSrc2_o   = 0;
            Branch_o    = 0;
            MemRead_o   = 0;
            MemWrite_o  = 0;
            RegWrite_o  = 1;
            MemtoReg_o  = 0;
        end 

        7'b0010011: begin // ADDI, SLLI, SLTI, SRAI
            ALUOp_o     = 2'b11;
            ALUSrc1_o   = 0;
            ALUSrc2_o   = 1;
            Branch_o    = 0;
            MemRead_o   = 0;
            MemWrite_o  = 0;
            RegWrite_o  = 1;
            MemtoReg_o  = 0;
        end

        7'b0000011: begin // lw
            ALUOp_o     = 2'b00;
            ALUSrc1_o   = 0;
            ALUSrc2_o   = 1;
            Branch_o    = 0;
            MemRead_o   = 1;
            MemWrite_o  = 0;
            RegWrite_o  = 1;
            MemtoReg_o  = 1;
        end

        7'b1100111:  begin // jalr
            ALUOp_o     = 2'b00;
            ALUSrc1_o   = 0;
            ALUSrc2_o   = 1;
            Branch_o    = 0;
            MemRead_o   = 0;
            MemWrite_o  = 0;
            RegWrite_o  = 1;
            Jump_o  = 1;
            JumpR_o  = 1;
            MemtoReg_o  = 0;
        end


        7'b0100011: begin // sw
            ALUOp_o     = 2'b00;
            ALUSrc1_o   = 0;
            ALUSrc2_o   = 1;
            Branch_o    = 0;
            MemRead_o   = 0;
            MemWrite_o  = 1;
            RegWrite_o  = 0;
            MemtoReg_o  = 1'bx;
        end

        // EQ / NE → check zero
        // LT / GE → use sign bit of (rs1 - rs2)
        7'b1100011: begin // branch (beq, bne, blt, bge)
            ALUOp_o     = 2'b01;
            ALUSrc1_o   = 0;
            ALUSrc2_o   = 0;
            Branch_o    = 1;
            MemRead_o   = 0;
            MemWrite_o  = 0;
            RegWrite_o  = 0;
            MemtoReg_o  = 1'bx;
        end

        7'b0010111: begin // auipc
            ALUOp_o     = 2'b00;
            ALUSrc1_o   = 1;
            ALUSrc2_o   = 1;
            Branch_o    = 0;
            MemRead_o   = 0;
            MemWrite_o  = 0;
            RegWrite_o  = 1;
            MemtoReg_o  = 0;
        end

        7'b1101111: begin // jal
            ALUOp_o     = 2'b00; // ignored
            ALUSrc1_o   = 0; // not used
            ALUSrc2_o   = 0; // not used
            Branch_o    = 0;
            MemRead_o   = 0;
            MemWrite_o  = 0;
            RegWrite_o  = 1;
            Jump_o  = 1;
            JumpR_o  = 0;
            MemtoReg_o  = 0;
        end

        // ecall o_finish_00000073
        7'b1110011: begin
            Finish_o = 1;
        end

    endcase
end

endmodule
