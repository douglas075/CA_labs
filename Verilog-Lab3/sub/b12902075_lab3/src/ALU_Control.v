module ALU_Control
(
    input       [6:0]   funct7_i,
    input       [2:0]   funct3_i,
    input       [1:0]   ALUOp_i,
    output  reg [3:0]   alu_ctrl_o  // Changed to 4 bits
);
    // ===== ALU operation encoding in ALU =====
    // Must match the parameters in ALU module
    localparam [3:0]
        ALU_ADD = 4'd0,
        ALU_SUB = 4'd1,
        ALU_AND = 4'd2,
        ALU_XOR = 4'd3,
        ALU_SLL = 4'd4,
        ALU_SRA = 4'd5,
        ALU_SLT = 4'd6,
        ALU_MUL = 4'd7,
        ALU_SRL = 4'd8; // New Operation

    always @(*) begin
        alu_ctrl_o = ALU_ADD;  // safe default

        case (ALUOp_i)
            // Load/Store -> ADD
            2'b00: begin
                alu_ctrl_o = ALU_ADD;
            end

            // Branches
            2'b01: begin
                case (funct3_i)
                    3'b000: alu_ctrl_o = ALU_SUB; // BEQ
                    3'b001: alu_ctrl_o = ALU_SUB; // BNE
                    3'b100: alu_ctrl_o = ALU_SLT; // BLT
                    3'b101: alu_ctrl_o = ALU_SLT; // BGE
                    default: alu_ctrl_o = ALU_ADD;
                endcase
            end

            // R-type
            2'b10: begin
                case ({funct7_i, funct3_i})
                    10'b0000000_000: alu_ctrl_o = ALU_ADD; // ADD
                    10'b0100000_000: alu_ctrl_o = ALU_SUB; // SUB
                    10'b0000000_111: alu_ctrl_o = ALU_AND; // AND
                    10'b0000000_100: alu_ctrl_o = ALU_XOR; // XOR
                    10'b0000001_000: alu_ctrl_o = ALU_MUL; // MUL
                    10'b0000000_001: alu_ctrl_o = ALU_SLL; // SLL
                    10'b0100000_101: alu_ctrl_o = ALU_SRA; // SRA
                    10'b0000000_101: alu_ctrl_o = ALU_SRL; // SRL (Fixed)
                    default: alu_ctrl_o = ALU_ADD;
                endcase
            end

            // I-type
            2'b11: begin
                case (funct3_i)
                    3'b000: alu_ctrl_o = ALU_ADD; // ADDI
                    3'b010: alu_ctrl_o = ALU_SLT; // SLTI
                    3'b001: alu_ctrl_o = ALU_SLL; // SLLI
                    3'b100: alu_ctrl_o = ALU_XOR; // XORI
                    3'b110: alu_ctrl_o = ALU_ADD; // ORI (mapped to ADD if ignored, or add ALU_OR)
                    3'b111: alu_ctrl_o = ALU_AND; // ANDI
                    3'b101: begin
                        // Distinguish SRLI vs SRAI
                        if (funct7_i == 7'b0100000)
                            alu_ctrl_o = ALU_SRA; // SRAI
                        else
                            alu_ctrl_o = ALU_SRL; // SRLI (Fixed)
                    end
                    default: alu_ctrl_o = ALU_ADD;
                endcase
            end
        endcase
    end
endmodule