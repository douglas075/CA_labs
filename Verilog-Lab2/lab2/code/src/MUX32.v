module MUX32_2to1 
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

module MUX32_4to1 
(
    input      [31:0]  data0_i,
    input      [31:0]  data1_i,
    input      [31:0]  data2_i,
    input      [31:0]  data3_i,
    input      [1:0]   mux_ctrl_i,
    output reg [31:0]  mux_o
);
    
always @ (*) begin    
    
    case (mux_ctrl_i)
        2'b00: mux_o = data0_i;
        2'b01: mux_o = data1_i;
        2'b10: mux_o = data2_i;
        2'b11: mux_o = data3_i;
        default: mux_o = data0_i; 
    endcase
end

endmodule

