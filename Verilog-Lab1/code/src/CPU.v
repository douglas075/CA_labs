module CPU
(
    clk_i, 
    rst_i
);

// Ports
input               clk_i;
input               rst_i;

// pc
wire [31:0] pc_i, pc_o; 
wire [31:0] instr; 

// register
wire [4:0] RS1addr, RS2addr, RDaddr;
wire [31:0] RS1data, RS2data, RDdata;

// control
wire [6:0] opcode;
wire RegWrite, ALUSrc;
wire [1:0] ALUOp;
wire [6:0] funct7;
wire [2:0] funct3;
wire [2:0] alu_ctrl;

// sign extend
wire [11:0] imm;
wire [31:0] extended_imm;

// ALU
wire [31:0] op_a, op_b, alu_result;
wire zero;
wire [31:0] mux2alu;



assign RS1addr = instr[19:15];
assign RS2addr = instr[24:20];
assign RDaddr  = instr[11:7];
assign opcode  = instr[6:0];
assign imm     = instr[31:20];  
assign funct7  = instr[31:25];
assign funct3  = instr[14:12];


// You can design the below modules, or define your own modules to complete the CPU design
Control u_Control(
    .opcode_i(opcode),
    .RegWrite_o(RegWrite),
    .ALUSrc_o(ALUSrc),
    .ALUOp_o(ALUOp)
);

Adder u_Add_PC(
    .a(pc_o),
    .b(32'd4),
    .sum(pc_i)
);

MUX32 u_MUX_ALUSrc(
    .data0_i(RS2data),
    .data1_i(extended_imm),
    .mux_ctrl_i(ALUSrc),
    .mux_o(mux2alu)
);

Sign_Extend u_Sign_Extend(
    .imm_i(imm),
    .extended_imm_o(extended_imm)
);
  
ALU u_ALU(
    .op_a_i(RS1data),
    .op_b_i(mux2alu),
    .alu_ctrl_i(alu_ctrl),
    .alu_result_o(alu_result),
    .zero_o(zero)
);

ALU_Control u_ALU_Control(
    .funct7_i(funct7),
    .funct3_i(funct3),
    .ALUOp_i(ALUOp),
    .alu_ctrl_o(alu_ctrl)
);

// provided by TA, you just need to connect the ports
PC u_PC(
    .clk_i(clk_i),
    .rst_i(rst_i),
    .pc_i(pc_i),
    .pc_o(pc_o)
);

Instruction_Memory u_Instruction_Memory(
    .addr_i(pc_o),
    .instr_o(instr)
);

Registers u_Registers(
    .rst_i(rst_i),
    .clk_i(clk_i),
    .RS1addr_i(RS1addr),
    .RS2addr_i(RS2addr),
    .RDaddr_i(RDaddr),
    .RDdata_i(alu_result),
    .RegWrite_i(RegWrite),
    .RS1data_o(RS1data),
    .RS2data_o(RS2data)
);


endmodule


module Adder 
(
    input   [31:0]  a,
    input   [31:0]  b,
    output  [31:0]  sum
);

assign sum = a + b;

endmodule

module Sign_Extend
(
    input   [11:0] imm_i,
    output  [31:0] extended_imm_o
);

assign extended_imm_o = {{20{imm_i[11]}}, imm_i};

endmodule


module Control
(
    input           [6:0]   opcode_i,
    output  reg             RegWrite_o,
    output  reg             ALUSrc_o,
    output  reg     [1:0]   ALUOp_o
);


always @ (*) begin
    ALUOp_o     = 2'b00;
    ALUSrc_o    = 0;
    RegWrite_o  = 0;

    case (opcode_i)
        7'b0110011: begin // R-type
            ALUOp_o     = 2'b10;
            ALUSrc_o    = 0;
            RegWrite_o  = 1;  
        end 

        7'b0010011: begin // I-type
            ALUOp_o     = 2'b11;
            ALUSrc_o    = 1;
            RegWrite_o  = 1;  
        end
    endcase
end

endmodule

module ALU_Control
(
    input       [6:0]   funct7_i,
    input       [2:0]   funct3_i,
    input       [1:0]   ALUOp_i,
    output  reg [2:0]   alu_ctrl_o
);

localparam [2:0]
    ALU_ADD = 3'd0, ALU_SUB = 3'd1, ALU_AND = 3'd2, ALU_XOR = 3'd3,
    ALU_SLL = 3'd4, ALU_SRA = 3'd5, ALU_MUL = 3'd6, ALU_EOF = 3'd7;


always @ (*) begin
    alu_ctrl_o = ALU_EOF;
    case (ALUOp_i)
        2'b10: begin // R-type
            case ({funct7_i, funct3_i})
                10'b0000000_000: alu_ctrl_o = ALU_ADD; 
                10'b0000000_001: alu_ctrl_o = ALU_SLL; 
                10'b0000000_100: alu_ctrl_o = ALU_XOR; 
                10'b0000000_111: alu_ctrl_o = ALU_AND; 
                10'b0100000_000: alu_ctrl_o = ALU_SUB; 
                10'b0000001_000: alu_ctrl_o = ALU_MUL; 
            endcase
        end 

        2'b11: begin // I-type
            case (funct3_i)
                3'b000: alu_ctrl_o = ALU_ADD;
                3'b101: begin
                    case (funct7_i)
                        7'b0100000: alu_ctrl_o = ALU_SRA; 
                    endcase
                end 
            endcase
        end
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
    input      [2:0]   alu_ctrl_i,
    output reg [31:0]  alu_result_o,
    output reg         zero_o
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
    zero_o = (alu_result_o == 32'b0);
end

endmodule