module MEM_WB
(
	input		 			clk_i,
	input		 			rst_n,

	input                   MEM_RegWrite_i,
    input                   MEM_MemtoReg_i,
	output  reg             WB_RegWrite_o,
    output  reg             WB_MemtoReg_o,

	input 			[31:0]	MEM_read_mem_data_i,
	output	reg 	[31:0]	WB_read_mem_data_o,

	input 			[31:0]	MEM_alu_result_i,
	output	reg 	[31:0]	WB_alu_result_o,

	input 			[4:0]	MEM_RDaddr_i,
	output	reg 	[4:0]	WB_RDaddr_o
);


always@(posedge clk_i or negedge rst_n) begin
	if(~rst_n) begin
		WB_RegWrite_o       	<= 0;
		WB_MemtoReg_o       	<= 0;
		WB_read_mem_data_o     	<= 0;
		WB_alu_result_o       	<= 0;
		WB_RDaddr_o       		<= 0;
	end
	else begin
		WB_RegWrite_o       	<= 		MEM_RegWrite_i;       	
		WB_MemtoReg_o       	<= 		MEM_MemtoReg_i;       	
		WB_read_mem_data_o     	<= 		MEM_read_mem_data_i;     	
		WB_alu_result_o       	<= 		MEM_alu_result_i;       	
		WB_RDaddr_o       		<= 		MEM_RDaddr_i;       		
	end
end
endmodule