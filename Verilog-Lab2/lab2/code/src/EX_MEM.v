module EX_MEM
(
	input 					clk_i,
	input 					rst_n,

	input                   EX_RegWrite_i,
    input                   EX_MemtoReg_i,
    input                   EX_MemRead_i,
    input                   EX_MemWrite_i,
	output  reg             MEM_RegWrite_o,
    output  reg             MEM_MemtoReg_o,
    output  reg             MEM_MemRead_o,
    output  reg             MEM_MemWrite_o,

	input 			[31:0]	EX_alu_result_i,
    output	reg 	[31:0]	MEM_alu_result_o,

	input 			[31:0]	EX_write_mem_data_i,
	output	reg 	[31:0]	MEM_write_mem_data_o,

	input 			[4:0]	EX_RDaddr_i,
	output	reg 	[4:0]	MEM_RDaddr_o
);


always@(posedge clk_i or negedge rst_n) begin
	if(~rst_n) begin
		MEM_RegWrite_o  		<=	0;
		MEM_MemtoReg_o  		<=	0;
		MEM_MemRead_o  			<=	0;
		MEM_MemWrite_o  		<=	0;
		MEM_alu_result_o  		<=	0;
		MEM_write_mem_data_o  	<=	0;
		MEM_RDaddr_o  			<=	0;
	end
	else begin
		MEM_RegWrite_o  		<=	EX_RegWrite_i;
		MEM_MemtoReg_o  		<=	EX_MemtoReg_i;
		MEM_MemRead_o  			<=	EX_MemRead_i;
		MEM_MemWrite_o  		<=	EX_MemWrite_i;
		MEM_alu_result_o  		<=	EX_alu_result_i;
		MEM_write_mem_data_o  	<=	EX_write_mem_data_i;
		MEM_RDaddr_o  			<=	EX_RDaddr_i;
	end
end
endmodule
