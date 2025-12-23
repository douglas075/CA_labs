//----------------------------- DO NOT MODIFY THE I/O INTERFACE!! ------------------------------//
module CPU #(
    parameter BIT_W = 32
)(
    input               i_clk,
    input               i_rst_n,

    // instruction memory
    input  [BIT_W-1:0]  i_IMEM_data,
    output [BIT_W-1:0]  o_IMEM_addr,
    output              o_IMEM_cen,

    // data memory (cache)
    input               i_DMEM_stall,
    input  [BIT_W-1:0]  i_DMEM_rdata,
    output              o_DMEM_cen,
    output              o_DMEM_wen,
    output [BIT_W-1:0]  o_DMEM_addr,
    output [BIT_W-1:0]  o_DMEM_wdata,

    // final output flag
    output              o_finish,

    // cache handshake
    input               i_cache_finish,
    output              o_proc_finish
);
//----------------------------- DO NOT MODIFY THE I/O INTERFACE!! ------------------------------//


//
//========================
// ECALL DETECTION
//========================
//
wire is_ecall = (i_IMEM_data == 32'h00000073);

reg finish_requested;

always @(posedge i_clk or negedge i_rst_n) begin
    if (!i_rst_n)
        finish_requested <= 1'b0;
    else if (is_ecall)
        finish_requested <= 1'b1;             // latch finish request
    else if (i_cache_finish)
        finish_requested <= 1'b0;             // clear after cache finishes
    else
        finish_requested <= finish_requested; // hold
end

assign o_proc_finish = finish_requested;
assign o_finish      = (finish_requested && i_cache_finish);

wire finish_stall = finish_requested && !i_cache_finish;



//
//========================
// PC + IF Stage
//========================
//
wire [BIT_W-1:0] next_PC;
wire [BIT_W-1:0] cur_PC;

assign o_IMEM_addr = cur_PC;
assign o_IMEM_cen  = 1'b1;

PC pc_reg(
    .i_clk(i_clk),
    .i_rst_n(i_rst_n),
    .next_PC_i(next_PC),
    .PC_o(cur_PC)
);


//
//========================
// Decode
//========================
//
wire [BIT_W-1:0] instr = i_IMEM_data;

wire [2:0] funct3 = instr[14:12];
wire [6:0] funct7 = instr[31:25];
wire [6:0] opcode = instr[6:0];


//
//========================
// Control Unit
//========================
//
wire [1:0] ALUOp;
wire ALUSrc1, ALUSrc2;
wire Branch, MemRead, MemWrite, RegWrite, MemtoReg;
wire Jump, JumpR;

Control u_Control(
    .opcode_i(opcode),
    .RegWrite_o(RegWrite),
    .MemtoReg_o(MemtoReg),
    .MemRead_o(MemRead),
    .MemWrite_o(MemWrite),
    .ALUOp_o(ALUOp),
    .ALUSrc1_o(ALUSrc1),
    .ALUSrc2_o(ALUSrc2),
    .Branch_o(Branch),
    .Jump_o(Jump),
    .JumpR_o(JumpR),
    .Finish_o()            // unused
);


//
//========================
// Register File
//========================
//
wire [BIT_W-1:0] rdata1, rdata2;

Reg_file reg0(
    .i_clk(i_clk),
    .i_rst_n(i_rst_n),
    .wen(RegWrite),
    .rs1(instr[19:15]),
    .rs2(instr[24:20]),
    .rd(instr[11:7]),
    .wdata(wdata),
    .rdata1(rdata1),
    .rdata2(rdata2)
);


//
//========================
// Immediate Generator
//========================
//
wire [BIT_W-1:0] imm;
Imm_Gen u_Imm_Gen(.instr_i(instr), .imm_o(imm));


//
//========================
// ALU Inputs
//========================
//
wire [BIT_W-1:0] alu_opr_1, alu_opr_2;

MUX32 mux_alu1(
    .data0_i(rdata1),
    .data1_i(cur_PC),
    .mux_ctrl_i(ALUSrc1),
    .mux_o(alu_opr_1)
);

MUX32 mux_alu2(
    .data0_i(rdata2),
    .data1_i(imm),
    .mux_ctrl_i(ALUSrc2),
    .mux_o(alu_opr_2)
);


//
//========================
// ALU
//========================
//
wire [3:0] alu_ctrl;
ALU_Control u_ALU_Control(
    .funct7_i(funct7),
    .funct3_i(funct3),
    .ALUOp_i(ALUOp),
    .alu_ctrl_o(alu_ctrl)
);

wire [BIT_W-1:0] alu_result;

ALU alu(
    .op_a_i(alu_opr_1),
    .op_b_i(alu_opr_2),
    .alu_ctrl_i(alu_ctrl),
    .alu_result_o(alu_result)
);


//
//========================
// Branch Decision
//========================
//
wire branch_taken;

Branch_Unit u_Branch_Unit(
    .op_a_i(rdata1),
    .op_b_i(rdata2),
    .funct3_i(funct3),
    .branch_taken_o(branch_taken)
);


//
//========================
// Data Memory Interface
//========================
//
assign o_DMEM_cen   = MemRead | MemWrite;
assign o_DMEM_wen   = MemWrite;
assign o_DMEM_addr  = alu_result;
assign o_DMEM_wdata = rdata2;


//
//========================
// Write Back
//========================
//
wire [BIT_W-1:0] wdata =
    (Jump)      ? cur_PC + 4 :
    (MemtoReg)  ? i_DMEM_rdata :
                  alu_result;


//
//========================
// PC Update
//========================
//
PC_Update pc_upd(
    .pc_i(cur_PC),
    .imm_i(imm),
    .rs1_i(rdata1),
    .Jump_i(Jump),
    .JumpR_i(JumpR),
    .Branch_i(Branch),
    .BranchTaken_i(branch_taken),
    .stall_i(i_DMEM_stall || finish_stall),
    .pc_o(next_PC)
);

endmodule



module PC_Update (
    input  [31:0] pc_i,
    input  [31:0] imm_i,
    input  [31:0] rs1_i,
    input         Jump_i,
    input         JumpR_i,
    input         Branch_i,
    input         BranchTaken_i,
    input         stall_i,
    output reg [31:0] pc_o
);

wire [31:0] pc_plus_4   = pc_i + 32'd4;
wire [31:0] pc_branch   = pc_i + imm_i;          // used for BEQ/BNE/BLT/BGE/JAL
wire [31:0] pc_jalr     = (rs1_i + imm_i) & 32'hFFFFFFFE;

always @(*) begin
    if (stall_i) begin
        pc_o = pc_i;
    end
    else if (Jump_i) begin
        if (JumpR_i)
            pc_o = (rs1_i + imm_i) & 32'hFFFFFFFE;  // JALR
        else
            pc_o = pc_i + imm_i;                   // JAL
    end
    else if (Branch_i && BranchTaken_i) begin
        pc_o = pc_i + imm_i;                       // BEQ/BNE/BLT/BGE
    end
    else begin
        pc_o = pc_i + 32'd4;                       // sequential
    end
end

endmodule

module PC 
(
    input                  i_clk,
    input                  i_rst_n,
    input      [31:0] next_PC_i,
    output reg [31:0] PC_o
);
    always @(posedge i_clk or negedge i_rst_n) begin
        if (!i_rst_n) begin
            PC_o <= 32'h00010000; // Do not modify this value!!!
        end
        else begin
            PC_o <= next_PC_i;
        end
    end

endmodule

module Adder 
(
    input   [31:0]  a,
    input   [31:0]  b,
    output  [31:0]  sum
);

assign sum = a + b;

endmodule

module Imm_Gen
(
    input  [31:0] instr_i,
    output reg [31:0] imm_o
);

wire [6:0] opcode = instr_i[6:0];

always @(*) begin
    case (opcode)

        // ======================
        // I-type: ADDI SLTI SLLI SRAI LW JALR
        // ======================
        7'b0010011, // I-type ALU
        7'b0000011, // LW
        7'b1100111: // JALR
            imm_o = {{20{instr_i[31]}}, instr_i[31:20]};

        // ======================
        // S-type: SW
        // ======================
        7'b0100011:
            imm_o = {{20{instr_i[31]}},
                      instr_i[31:25],
                      instr_i[11:7]};

        // ======================
        // B-type: BEQ BNE BLT BGE
        // ======================
        7'b1100011:
            imm_o = {{19{instr_i[31]}},
                      instr_i[31],
                      instr_i[7],
                      instr_i[30:25],
                      instr_i[11:8],
                      1'b0};

        // ======================
        // U-type: AUIPC
        // ======================
        7'b0010111:
            imm_o = {instr_i[31:12], 12'b0};

        // ======================
        // J-type: JAL
        // ======================
        7'b1101111:
            imm_o = {{11{instr_i[31]}},
                      instr_i[31],
                      instr_i[19:12],
                      instr_i[20],
                      instr_i[30:21],
                      1'b0};

        default:
            imm_o = 32'b0;
    endcase
end

endmodule


module MUX32 
(
    input      [31:0]  data0_i,
    input      [31:0]  data1_i,
    input              mux_ctrl_i,
    output reg [31:0]  mux_o
);
    
always @ (*) begin    
    if (mux_ctrl_i == 0)
        mux_o = data0_i;
    else
        mux_o = data1_i;
end

endmodule

module ALU
(
    input      [31:0]  op_a_i,
    input      [31:0]  op_b_i,
    input      [3:0]   alu_ctrl_i, // <--- CHANGE THIS TO [3:0]
    output reg [31:0]  alu_result_o
);
    localparam [3:0] // <--- Change to [3:0]
        ALU_ADD = 4'd0,
        ALU_SUB = 4'd1,
        ALU_AND = 4'd2,
        ALU_XOR = 4'd3,
        ALU_SLL = 4'd4,
        ALU_SRA = 4'd5,
        ALU_SLT = 4'd6,
        ALU_MUL = 4'd7,
        ALU_SRL = 4'd8; // <--- ADD THIS

    always @ (*) begin
        alu_result_o = 32'b0;
        case (alu_ctrl_i)
            ALU_ADD: alu_result_o = op_a_i + op_b_i;
            ALU_SUB: alu_result_o = op_a_i - op_b_i;
            ALU_AND: alu_result_o = op_a_i & op_b_i;
            ALU_XOR: alu_result_o = op_a_i ^ op_b_i;
            ALU_SLL: alu_result_o = op_a_i << op_b_i[4:0];
            ALU_SRA: alu_result_o = $signed(op_a_i) >>> op_b_i[4:0];
            ALU_MUL: alu_result_o = op_a_i * op_b_i;
            ALU_SLT: alu_result_o = ($signed(op_a_i) < $signed(op_b_i)) ? 32'd1 : 32'd0;
            ALU_SRL: alu_result_o = op_a_i >> op_b_i[4:0]; // <--- ADD THIS
            default: alu_result_o = 32'b0;
        endcase
    end
endmodule


module Branch_Unit(
    input   [31:0] op_a_i,
    input   [31:0] op_b_i,
    input   [2:0] funct3_i,
    output  reg  branch_taken_o
);

always @(*) begin
    branch_taken_o = 1'b0;

    case (funct3_i)
        3'b000: branch_taken_o = (op_a_i == op_b_i);                   // BEQ
        3'b001: branch_taken_o = (op_a_i != op_b_i);                   // BNE

        3'b100: branch_taken_o = ($signed(op_a_i) < $signed(op_b_i));   // BLT

        3'b101: branch_taken_o = ($signed(op_a_i) >= $signed(op_b_i));  // BGE
    endcase
end

endmodule