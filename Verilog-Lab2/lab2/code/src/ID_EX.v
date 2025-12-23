module ID_EX
(
	input 					clk_i,
	input 					rst_n,

	input                   ID_RegWrite_i,
    input                   ID_MemtoReg_i,
    input                   ID_MemRead_i,
    input                   ID_MemWrite_i,
    input           [1:0]   ID_ALUOp_i,
    input                   ID_ALUSrc_i,

	output  reg             EX_RegWrite_o,
    output  reg             EX_MemtoReg_o,
    output  reg             EX_MemRead_o,
    output  reg             EX_MemWrite_o,
    output  reg     [1:0]   EX_ALUOp_o,
    output  reg             EX_ALUSrc_o,

	input 			[31:0] 	ID_RS1data_i,
	input 			[31:0] 	ID_RS2data_i,
	input 			[4:0] 	ID_RS1addr_i,
	input 			[4:0] 	ID_RS2addr_i,
	input 			[4:0] 	ID_RDaddr_i,
	output	reg 	[31:0] 	EX_RS1data_o,
	output	reg 	[31:0] 	EX_RS2data_o,
	output	reg 	[4:0] 	EX_RS1addr_o,
	output	reg 	[4:0] 	EX_RS2addr_o,
	output	reg 	[4:0] 	EX_RDaddr_o,
	

	input 			[31:0] 	ID_imm_gen_i,
	output	reg 	[31:0] 	EX_imm_gen_o,

	input 			[6:0] 	ID_funct7_i,
	input 			[2:0] 	ID_funct3_i,
	output	reg 	[6:0] 	EX_funct7_o,
	output	reg 	[2:0] 	EX_funct3_o

);

always@(posedge clk_i or negedge rst_n) begin
	if(~rst_n) begin
		EX_RegWrite_o  	<= 0;
		EX_MemtoReg_o  	<= 0;
		EX_MemRead_o  	<= 0;
		EX_MemWrite_o  	<= 0;
		EX_ALUOp_o  	<= 0;
		EX_ALUSrc_o  	<= 0;
		EX_RS1data_o  	<= 0;
		EX_RS2data_o  	<= 0;
		EX_RS1addr_o  	<= 0;
		EX_RS2addr_o  	<= 0;
		EX_RDaddr_o  	<= 0;
		EX_imm_gen_o  	<= 0;
		EX_funct7_o  	<= 0;
		EX_funct3_o  	<= 0;
	end
	else begin
		EX_RegWrite_o  	<= 	ID_RegWrite_i;
		EX_MemtoReg_o  	<= 	ID_MemtoReg_i;
		EX_MemRead_o  	<= 	ID_MemRead_i;
		EX_MemWrite_o  	<= 	ID_MemWrite_i;
		EX_ALUOp_o  	<= 	ID_ALUOp_i;
		EX_ALUSrc_o  	<= 	ID_ALUSrc_i;
		EX_RS1data_o  	<= 	ID_RS1data_i;
		EX_RS2data_o  	<= 	ID_RS2data_i;
		EX_RS1addr_o  	<= 	ID_RS1addr_i;
		EX_RS2addr_o  	<= 	ID_RS2addr_i;
		EX_RDaddr_o  	<= 	ID_RDaddr_i;
		EX_imm_gen_o  	<= 	ID_imm_gen_i;
		EX_funct7_o  	<= 	ID_funct7_i;
		EX_funct3_o  	<= 	ID_funct3_i;
	end
end


endmodule