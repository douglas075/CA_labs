module ALU_Control
(
    input       [6:0]   funct7_i,
    input       [2:0]   funct3_i,
    input       [1:0]   ALUOp_i,
    output  reg [2:0]   alu_ctrl_o
);

localparam [2:0]
    ALU_ADD = 3'd0, ALU_SUB = 3'd1, ALU_AND = 3'd2, ALU_XOR = 3'd3,
    ALU_SLL = 3'd4, ALU_SRA = 3'd5, ALU_MUL = 3'd6, ALU_EOF = 3'd7;


always @ (*) begin
    alu_ctrl_o = ALU_EOF;
    case (ALUOp_i)
        2'b10: begin // R-type
            case ({funct7_i, funct3_i})
                10'b0000000_000: alu_ctrl_o = ALU_ADD; 
                10'b0000000_001: alu_ctrl_o = ALU_SLL; 
                10'b0000000_100: alu_ctrl_o = ALU_XOR; 
                10'b0000000_111: alu_ctrl_o = ALU_AND; 
                10'b0100000_000: alu_ctrl_o = ALU_SUB; 
                10'b0000001_000: alu_ctrl_o = ALU_MUL; 
            endcase
        end 

        2'b11: begin // I-type
            case (funct3_i)
                3'b000: alu_ctrl_o = ALU_ADD;
                3'b101: begin
                    case (funct7_i)
                        7'b0100000: alu_ctrl_o = ALU_SRA; 
                    endcase
                end 
            endcase
        end

        2'b00: begin // memory
           alu_ctrl_o = ALU_ADD;
        end

        2'b01: begin // branch
           alu_ctrl_o = ALU_ADD;
        end

    endcase
end

endmodule
