module CPU
(
    clk_i, 
    rst_n
);

// Ports
input         clk_i;
input         rst_n;

// Do not change the name of these 2 signals
wire ID_Stall;
wire ID_FlushIF;

wire PCWrite;

// IF
wire [31:0] HD_pc;
wire [31:0] IF_pc;
wire [31:0] IF_next_pc;
wire [31:0] IF_instr;

// ID
wire [31:0] ID_pc;
wire [31:0] ID_instr;

wire [1:0]  ID_ALUOp;
wire ID_RegWrite;
wire ID_MemtoReg;
wire ID_MemRead;
wire ID_MemWrite;
wire ID_ALUSrc;
wire ID_Branch;
wire ID_NoOp;

wire [31:0] ID_RS1data;
wire [31:0] ID_RS2data;
wire [31:0] ID_Imm;


// EX
wire EX_RegWrite;
wire EX_MemtoReg;
wire EX_MemRead;
wire EX_MemWrite;
wire [1:0]  EX_ALUOp;
wire EX_ALUSrc;

wire [31:0] EX_RS1data;
wire [31:0] EX_RS2data;
wire [4:0] EX_RS1addr;
wire [4:0] EX_RS2addr;
wire [4:0] EX_RDaddr;
wire [31:0] EX_Imm;
wire [6:0] EX_funct7;
wire [2:0] EX_funct3;

wire [1:0] Forward_A;
wire [1:0] Forward_B;
wire [31:0] EX_alu_oprd1;
wire [31:0] EX_alu_oprd2;
wire [31:0] EX_mux_B_result;

wire [2:0] alu_ctrl;
wire [31:0] EX_alu_result;

// MEM
wire [31:0] MEM_alu_result;
wire MEM_RegWrite;
wire MEM_MemtoReg;
wire MEM_MemRead;
wire MEM_MemWrite;
wire [31:0]	MEM_write_mem_data;
wire [4:0]	MEM_RDaddr;
wire [31:0]	MEM_read_mem_data;

// WB
wire [4:0]  WB_RDaddr;
wire [31:0] WB_RDdata;
wire [31:0] WB_read_mem_data;
wire [31:0] WB_alu_result;
wire WB_MemtoReg;
wire WB_RegWrite;

PC u_PC (
    .rst_n(rst_n),
    .clk_i(clk_i),
    .PCWrite_i(PCWrite),
    .pc_i(HD_pc),
    .pc_o(IF_pc)
);

Adder u_Add_PC (
    .a(IF_pc),
    .b(32'd4),
    .sum(IF_next_pc)
);

Instruction_Memory u_Instruction_Memory (
    .addr_i(IF_pc),
    .instr_o(IF_instr)
);

IF_ID u_IF_ID (
    .clk_i(clk_i),
    .rst_n(rst_n),
    .IF_pc_i(IF_pc),
    .ID_stall_i(ID_Stall),
    .ID_FlushIF_i(ID_FlushIF),
    .IF_instr_i(IF_instr),
    .ID_pc_o(ID_pc),
    .ID_instr_o(ID_instr)
);

Control u_Control (
    .opcode_i(ID_instr[6:0]),
    .NoOp_i(ID_NoOp),
    .RegWrite_o(ID_RegWrite),
    .MemtoReg_o(ID_MemtoReg),
    .MemRead_o(ID_MemRead),
    .MemWrite_o(ID_MemWrite),
    .ALUOp_o(ID_ALUOp),
    .ALUSrc_o(ID_ALUSrc),
    .Branch_o(ID_Branch)
);

Registers u_Registers (
    .clk_i(clk_i),
    .rst_n(rst_n),
    .RS1addr_i(ID_instr[19:15]),
    .RS2addr_i(ID_instr[24:20]),
    .RDaddr_i(WB_RDaddr),
    .RDdata_i(WB_RDdata),
    .RegWrite_i(WB_RegWrite),
    .RS1data_o(ID_RS1data),
    .RS2data_o(ID_RS2data)
);

Imm_Gen u_Imm_Gen (
    .instr_i(ID_instr),
    .extended_imm_o(ID_Imm)
);

ID_EX u_ID_EX (
    .clk_i(clk_i),
    .rst_n(rst_n),
    .ID_RegWrite_i(ID_RegWrite),
    .ID_MemtoReg_i(ID_MemtoReg),
    .ID_MemRead_i(ID_MemRead),
    .ID_MemWrite_i(ID_MemWrite),
    .ID_ALUOp_i(ID_ALUOp),
    .ID_ALUSrc_i(ID_ALUSrc),
    .EX_RegWrite_o(EX_RegWrite),
    .EX_MemtoReg_o(EX_MemtoReg),
    .EX_MemRead_o(EX_MemRead),
    .EX_MemWrite_o(EX_MemWrite),
    .EX_ALUOp_o(EX_ALUOp),
    .EX_ALUSrc_o(EX_ALUSrc),
    .ID_RS1data_i(ID_RS1data),
    .ID_RS2data_i(ID_RS2data),
    .ID_RS1addr_i(ID_instr[19:15]),
    .ID_RS2addr_i(ID_instr[24:20]),
    .ID_RDaddr_i(ID_instr[11:7]),
    .EX_RS1data_o(EX_RS1data),
    .EX_RS2data_o(EX_RS2data),
    .EX_RS1addr_o(EX_RS1addr),
    .EX_RS2addr_o(EX_RS2addr),
    .EX_RDaddr_o(EX_RDaddr),
    .ID_imm_gen_i(ID_Imm),
    .EX_imm_gen_o(EX_Imm),
    .ID_funct7_i(ID_instr[31:25]),
    .ID_funct3_i(ID_instr[14:12]),
    .EX_funct7_o(EX_funct7),
    .EX_funct3_o(EX_funct3)
);

MUX32_4to1 u_MUX32_4to1_A (
    .data0_i(EX_RS1data),
    .data1_i(WB_RDdata),
    .data2_i(MEM_alu_result),
    .data3_i(32'b0),
    .mux_ctrl_i(Forward_A),
    .mux_o(EX_alu_oprd1)
);

MUX32_4to1 u_MUX32_4to1_B (
    .data0_i(EX_RS2data),
    .data1_i(WB_RDdata),
    .data2_i(MEM_alu_result),
    .data3_i(32'b0),
    .mux_ctrl_i(Forward_B),
    .mux_o(EX_mux_B_result)
);

MUX32_2to1 u_MUX32_2to1_alusrc2 (
    .data0_i(EX_mux_B_result),
    .data1_i(EX_Imm),
    .mux_ctrl_i(EX_ALUSrc),
    .mux_o(EX_alu_oprd2)
);

ALU u_ALU (
    .op_a_i(EX_alu_oprd1),
    .op_b_i(EX_alu_oprd2),
    .alu_ctrl_i(alu_ctrl),
    .alu_result_o(EX_alu_result)
);

ALU_Control u_ALU_Control (
    .funct7_i(EX_funct7),
    .funct3_i(EX_funct3),
    .ALUOp_i(EX_ALUOp),
    .alu_ctrl_o(alu_ctrl)
);

EX_MEM u_EX_MEM (
    .clk_i(clk_i),
    .rst_n(rst_n),
    .EX_RegWrite_i(EX_RegWrite),
    .EX_MemtoReg_i(EX_MemtoReg),
    .EX_MemRead_i(EX_MemRead),
    .EX_MemWrite_i(EX_MemWrite),
    .MEM_RegWrite_o(MEM_RegWrite),
    .MEM_MemtoReg_o(MEM_MemtoReg),
    .MEM_MemRead_o(MEM_MemRead),
    .MEM_MemWrite_o(MEM_MemWrite),
    .EX_alu_result_i(EX_alu_result),
    .MEM_alu_result_o(MEM_alu_result),
    .EX_write_mem_data_i(EX_mux_B_result),
    .MEM_write_mem_data_o(MEM_write_mem_data),
    .EX_RDaddr_i(EX_RDaddr),
    .MEM_RDaddr_o(MEM_RDaddr)
);

Data_Memory u_Data_Memory (
    .clk_i(clk_i),
    .addr_i(MEM_alu_result),
    .MemRead_i(MEM_MemRead),
    .MemWrite_i(MEM_MemWrite),
    .data_i(MEM_write_mem_data),
    .data_o(MEM_read_mem_data)
);

MEM_WB u_MEM_WB (
    .clk_i(clk_i),
    .rst_n(rst_n),
    .MEM_RegWrite_i(MEM_RegWrite),
    .MEM_MemtoReg_i(MEM_MemtoReg),
    .WB_RegWrite_o(WB_RegWrite),
    .WB_MemtoReg_o(WB_MemtoReg),
    .MEM_read_mem_data_i(MEM_read_mem_data),
    .WB_read_mem_data_o(WB_read_mem_data),
    .MEM_alu_result_i(MEM_alu_result),
    .WB_alu_result_o(WB_alu_result),
    .MEM_RDaddr_i(MEM_RDaddr),
    .WB_RDaddr_o(WB_RDaddr)
);

MUX32_2to1 u_WB_src_mux (
    .data0_i(WB_alu_result),
    .data1_i(WB_read_mem_data),
    .mux_ctrl_i(WB_MemtoReg),
    .mux_o(WB_RDdata)
);

Hazard_Detection u_Hazard_Detection (
    .ID_RS1addr_i(ID_instr[19:15]),
    .ID_RS2addr_i(ID_instr[24:20]),
    .EX_MemRead_i(EX_MemRead),
    .EX_RDaddr_i(EX_RDaddr),
    .ID_RS1data_i(ID_RS1data),
    .ID_RS2data_i(ID_RS2data),
    .ID_pc_i(ID_pc),
    .IF_next_pc_i(IF_next_pc),
    .ID_Imm_Gen_result_i(ID_Imm),
    .ID_Branch_i(ID_Branch),
    .ID_funct3_i(ID_instr[14:12]),
    .NoOp_o(ID_NoOp),
    .Stall_o(ID_Stall),
    .Flush_o(ID_FlushIF),
    .PCWrite_o(PCWrite),
    .HD_pc_o(HD_pc)
);

Forwarding u_Forwarding (
    .EX_RS1addr_i(EX_RS1addr),
    .EX_RS2addr_i(EX_RS2addr),
    .MEM_RDaddr_i(MEM_RDaddr),
    .WB_RDaddr_i(WB_RDaddr),
    .MEM_RegWrite_i(MEM_RegWrite),
    .WB_RegWrite_i(WB_RegWrite),
    .Forward_A(Forward_A),
    .Forward_B(Forward_B)
);

endmodule

