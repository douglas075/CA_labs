module IF_ID
(
	input		 			clk_i,
	input		 			rst_n,
	input			[31:0]	IF_pc_i,
	input		 			ID_stall_i,
	input		 			ID_FlushIF_i,
	input		 	[31:0] 	IF_instr_i,

	output 	reg 	[31:0] 	ID_pc_o,
	output 	reg 	[31:0] 	ID_instr_o
);


always@(posedge clk_i or negedge rst_n) begin
	if(~rst_n) begin
		ID_pc_o <= 32'b0;
		ID_instr_o <= 32'b0;
	end
	else if (ID_stall_i) begin
		ID_pc_o <= ID_pc_o;
		ID_instr_o <= ID_instr_o; // remain
	end
	else if (ID_FlushIF_i) begin
		ID_pc_o <= 32'b0; 
		ID_instr_o <= 32'b10011; // nop	
	end	
	else begin
		ID_pc_o <= IF_pc_i;
		ID_instr_o <= IF_instr_i;
	end
end
endmodule