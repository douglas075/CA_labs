module ALU
(
    input      [31:0]  op_a_i,
    input      [31:0]  op_b_i,
    input      [2:0]   alu_ctrl_i,
    output reg [31:0]  alu_result_o
);

localparam [2:0]
    ALU_ADD = 3'd0, ALU_SUB = 3'd1, ALU_AND = 3'd2, ALU_XOR = 3'd3,
    ALU_SLL = 3'd4, ALU_SRA = 3'd5, ALU_MUL = 3'd6, ALU_EOF = 3'd7;

always @ (*) begin
    alu_result_o = 32'b0;
    case (alu_ctrl_i)
        ALU_ADD: alu_result_o = op_a_i + op_b_i;
        ALU_SUB: alu_result_o = op_a_i - op_b_i;
        ALU_AND: alu_result_o = op_a_i & op_b_i;
        ALU_XOR: alu_result_o = op_a_i ^ op_b_i;
        ALU_SLL: alu_result_o = op_a_i << op_b_i;
        ALU_SRA: alu_result_o = op_a_i >>> op_b_i[4:0];
        ALU_MUL: alu_result_o = op_a_i * op_b_i;
    endcase
end

endmodule