module Control
(
    input           [6:0]   opcode_i,
    input                   NoOp_i,
    output  reg             RegWrite_o,
    output  reg             MemtoReg_o,
    output  reg             MemRead_o,
    output  reg             MemWrite_o,
    output  reg     [1:0]   ALUOp_o,
    output  reg             ALUSrc_o,
    output  reg             Branch_o
);


always @ (*) begin
    ALUOp_o     = 2'b0;
    ALUSrc_o    = 0;
    Branch_o    = 0;
    MemRead_o   = 0;
    MemWrite_o  = 0;
    RegWrite_o  = 0;
    MemtoReg_o  = 0;

    if (~NoOp_i) begin
        case (opcode_i)
            7'b0110011: begin // R-type
                ALUOp_o     = 2'b10;
                ALUSrc_o    = 0;
                Branch_o    = 0;
                MemRead_o   = 0;
                MemWrite_o  = 0;
                RegWrite_o  = 1;
                MemtoReg_o  = 0;
            end 

            7'b0010011: begin // I-type
                ALUOp_o     = 2'b11;
                ALUSrc_o    = 1;
                Branch_o    = 0;
                MemRead_o   = 0;
                MemWrite_o  = 0;
                RegWrite_o  = 1;
                MemtoReg_o  = 0;
            end

            7'b0000011: begin // lw
                ALUOp_o     = 2'b00;
                ALUSrc_o    = 1;
                Branch_o    = 0;
                MemRead_o   = 1;
                MemWrite_o  = 0;
                RegWrite_o  = 1;
                MemtoReg_o  = 1;
            end

            7'b0100011: begin // sw
                ALUOp_o     = 2'b00;
                ALUSrc_o    = 1;
                Branch_o    = 0;
                MemRead_o   = 0;
                MemWrite_o  = 1;
                RegWrite_o  = 0;
                MemtoReg_o  = 1'bx;
            end

            7'b1100011: begin // branch
                ALUOp_o     = 2'b01;
                ALUSrc_o    = 0;
                Branch_o    = 1;
                MemRead_o   = 0;
                MemWrite_o  = 0;
                RegWrite_o  = 0;
                MemtoReg_o  = 1'bx;
            end
        endcase
    end
end

endmodule
