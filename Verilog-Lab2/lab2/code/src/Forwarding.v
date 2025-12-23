module Forwarding
(
	input 			[4:0]	EX_RS1addr_i,
	input 			[4:0]	EX_RS2addr_i,
	input 			[4:0]	MEM_RDaddr_i,
	input 			[4:0]	WB_RDaddr_i,
	input 					MEM_RegWrite_i,
	input 					WB_RegWrite_i,
	output	reg 	[1:0]	Forward_A,
	output	reg 	[1:0]	Forward_B
);


always@(*) begin
	Forward_A = 2'b00;
	Forward_B = 2'b00;

	if (MEM_RegWrite_i && MEM_RDaddr_i != 0) begin
		if (MEM_RDaddr_i == EX_RS1addr_i)
			Forward_A = 2'b10;

		// warning !!!!
		// rs2 may be part of imm in addi, srai, lw
		if (MEM_RDaddr_i == EX_RS2addr_i)
			Forward_B = 2'b10;
	end

	if (WB_RegWrite_i && WB_RDaddr_i != 0) begin
		if (Forward_A != 2'b10 && WB_RDaddr_i == EX_RS1addr_i)
			Forward_A = 2'b01;
		if (Forward_B != 2'b10 && WB_RDaddr_i == EX_RS2addr_i)
			Forward_B = 2'b01;
	end
end
endmodule