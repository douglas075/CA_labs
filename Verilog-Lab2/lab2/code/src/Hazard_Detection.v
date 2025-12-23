module Hazard_Detection
(
	// load use hazard
	input 			[4:0]	ID_RS1addr_i,
	input 			[4:0]	ID_RS2addr_i,
	input 					EX_MemRead_i,
	input 			[4:0]	EX_RDaddr_i,
	
	// branch control hazard
	input 			[31:0]	ID_RS1data_i,
	input 			[31:0]	ID_RS2data_i,
	input 			[31:0]	ID_pc_i,
	input 			[31:0]	IF_next_pc_i,
	input 			[31:0]	ID_Imm_Gen_result_i,
	input 					ID_Branch_i,
	input 			[2:0] 	ID_funct3_i, // for beq or bne
	

	// result
	output	reg 			NoOp_o,
	output	reg 			Stall_o,
	output	reg 			Flush_o,
	output	reg 			PCWrite_o,
	output	reg 	[31:0]	HD_pc_o
);

reg eq_result;
wire [31:0] branched_pc;
assign branched_pc = (ID_Imm_Gen_result_i << 1) + ID_pc_i;
assign Flush_o = ID_Branch_i & eq_result; 

MUX32_2to1 u_MUX_pc(
	.data0_i(IF_next_pc_i),
    .data1_i(branched_pc),
    .mux_ctrl_i(Flush_o),
    .mux_o(HD_pc_o)
);

always @(*) begin
	// default signals 
	NoOp_o  	= 0;
	Stall_o  	= 0;
	PCWrite_o  	= 1;
	eq_result 	= 0;

	// load use hazard
	if (EX_MemRead_i && EX_RDaddr_i != 0 &&
		(EX_RDaddr_i == ID_RS1addr_i || EX_RDaddr_i == ID_RS2addr_i)) begin
			NoOp_o = 1;
			Stall_o = 1;
			PCWrite_o = 0;
		end

	// control hazard
	// only compare funct3, as other instrs don't trigger branch signal
	if (ID_funct3_i == 3'b000) begin // beq
		if (ID_RS1data_i == ID_RS2data_i)
			eq_result = 1;
	end
	else begin // bneq
		if (ID_RS1data_i != ID_RS2data_i)
			eq_result = 1;
	end
	
end

endmodule
