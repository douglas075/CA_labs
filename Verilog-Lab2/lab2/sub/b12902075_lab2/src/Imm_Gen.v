module Imm_Gen
(
	input		[31:0] 	instr_i,
	output	reg [31:0]	extended_imm_o
);

wire [6:0] opcode;
wire [2:0] funct3;
reg [31:0] imm;
assign opcode = instr_i[6:0];
assign funct3 = instr_i[14:12];

always @(*) begin
	imm = 0;
	extended_imm_o = 0;
	case ({opcode, funct3})
		10'b0010011_000: begin // addi
			imm[11:0] = instr_i[31:20];
			extended_imm_o = {{20{imm[11]}}, imm[11:0]};
		end 
		10'b0010011_101: begin // srai
			imm[4:0] = instr_i[24:20];
			extended_imm_o = {{20{imm[4]}}, imm[4:0]};
		end 
		10'b0000011_010: begin // lw
			imm[11:0] = instr_i[31:20];
			extended_imm_o = {{20{imm[11]}}, imm[11:0]};
		end 
		10'b0100011_010: begin // sw
			imm[11:0] = {instr_i[31:25], instr_i[11:7]};
			extended_imm_o = {{20{imm[11]}}, imm[11:0]};
		end 
		10'b1100011_000: begin // beq and bne
			imm[11:0] = {instr_i[31], instr_i[7], instr_i[30:25], instr_i[11:8]};
			extended_imm_o = {{20{imm[11]}}, imm[11:0]};
		end 
		10'b1100011_001: begin // beq and bne
			imm[11:0] = {instr_i[31], instr_i[7], instr_i[30:25], instr_i[11:8]};
			extended_imm_o = {{20{imm[11]}}, imm[11:0]};
		end 
	endcase
end
endmodule