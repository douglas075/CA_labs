`define CYCLE_TIME 10  
`define MAXIMUM_CYCLE 500         

module TestBench;

reg                Clk;
reg                Reset;
integer            i, outfile;
integer            start;

always #(`CYCLE_TIME/2) Clk = ~Clk;    

CPU u_CPU(
    .clk_i  (Clk),
    .rst_i  (Reset)
);
  
initial begin
    $dumpfile("waveform.vcd");
    $dumpvars;
    
    start = 0;
    // initialize instruction memory
    for(i=0; i<256; i=i+1) begin
        u_CPU.u_Instruction_Memory.memory[i] = 32'b0;
    end
    
    // Load instructions into instruction memory
    $readmemb("instruction.txt", u_CPU.u_Instruction_Memory.memory);
    
    // Open output file
    outfile = $fopen("output.txt") | 1;

    Clk = 0;
    Reset = 0;
    
    #(`CYCLE_TIME/4) 
    Reset = 1;
    start = 1;
    
end
  
initial $display("INFO: loading inst from %s", "instruction.txt");

initial begin

    wait(start);
    
    $fdisplay(outfile, "PC = %6d", 0);
    $fdisplay(outfile, "Registers");
    $fdisplay(outfile, "x0     = %6d, x8(s0)  = %6d, x16(a6) = %6d, x24(s8)  = %6d", 0, 0, 0, 0);
    $fdisplay(outfile, "x1(ra) = %6d, x9(s1)  = %6d, x17(a7) = %6d, x25(s9)  = %6d", 0, 0, 0, 0);
    $fdisplay(outfile, "x2(sp) = %6d, x10(a0) = %6d, x18(s2) = %6d, x26(s10) = %6d", 0, 0, 0, 0);
    $fdisplay(outfile, "x3(gp) = %6d, x11(a1) = %6d, x19(s3) = %6d, x27(s11) = %6d", 0, 0, 0, 0);
    $fdisplay(outfile, "x4(tp) = %6d, x12(a2) = %6d, x20(s4) = %6d, x28(t3)  = %6d", 0, 0, 0, 0);
    $fdisplay(outfile, "x5(t0) = %6d, x13(a3) = %6d, x21(s5) = %6d, x29(t4)  = %6d", 0, 0, 0, 0);
    $fdisplay(outfile, "x6(t1) = %6d, x14(a4) = %6d, x22(s6) = %6d, x30(t5)  = %6d", 0, 0, 0, 0);
    $fdisplay(outfile, "x7(t2) = %6d, x15(a5) = %6d, x23(s7) = %6d, x31(t6)  = %6d", 0, 0, 0, 0);
    $fdisplay(outfile, "\n");
    
    while(u_CPU.u_Instruction_Memory.memory[u_CPU.u_PC.pc_o >> 2] !== 32'b0) begin

        @(negedge Clk);
        // print PC
        $fdisplay(outfile, "PC = %6d", u_CPU.u_PC.pc_o);

        // print Registers
        $fdisplay(outfile, "Registers");
        $fdisplay(outfile,
        "x0     = %6d, x8(s0)  = %6d, x16(a6) = %6d, x24(s8)  = %6d",
        u_CPU.u_Registers.register[0],  u_CPU.u_Registers.register[8],
        u_CPU.u_Registers.register[16], u_CPU.u_Registers.register[24]);

        $fdisplay(outfile,
        "x1(ra) = %6d, x9(s1)  = %6d, x17(a7) = %6d, x25(s9)  = %6d",
        u_CPU.u_Registers.register[1],  u_CPU.u_Registers.register[9],
        u_CPU.u_Registers.register[17], u_CPU.u_Registers.register[25]);

        $fdisplay(outfile,
        "x2(sp) = %6d, x10(a0) = %6d, x18(s2) = %6d, x26(s10) = %6d",
        u_CPU.u_Registers.register[2],  u_CPU.u_Registers.register[10],
        u_CPU.u_Registers.register[18], u_CPU.u_Registers.register[26]);

        $fdisplay(outfile,
        "x3(gp) = %6d, x11(a1) = %6d, x19(s3) = %6d, x27(s11) = %6d",
        u_CPU.u_Registers.register[3],  u_CPU.u_Registers.register[11],
        u_CPU.u_Registers.register[19], u_CPU.u_Registers.register[27]);

        $fdisplay(outfile,
        "x4(tp) = %6d, x12(a2) = %6d, x20(s4) = %6d, x28(t3)  = %6d",
        u_CPU.u_Registers.register[4],  u_CPU.u_Registers.register[12],
        u_CPU.u_Registers.register[20], u_CPU.u_Registers.register[28]);

        $fdisplay(outfile,
        "x5(t0) = %6d, x13(a3) = %6d, x21(s5) = %6d, x29(t4)  = %6d",
        u_CPU.u_Registers.register[5],  u_CPU.u_Registers.register[13],
        u_CPU.u_Registers.register[21], u_CPU.u_Registers.register[29]);

        $fdisplay(outfile,
        "x6(t1) = %6d, x14(a4) = %6d, x22(s6) = %6d, x30(t5)  = %6d",
        u_CPU.u_Registers.register[6],  u_CPU.u_Registers.register[14],
        u_CPU.u_Registers.register[22], u_CPU.u_Registers.register[30]);

        $fdisplay(outfile,
        "x7(t2) = %6d, x15(a5) = %6d, x23(s7) = %6d, x31(t6)  = %6d",
        u_CPU.u_Registers.register[7],  u_CPU.u_Registers.register[15],
        u_CPU.u_Registers.register[23], u_CPU.u_Registers.register[31]);

        $fdisplay(outfile, "\n");
        
    end
    $finish;
end

initial begin
    #(`CYCLE_TIME * `MAXIMUM_CYCLE);
    $display("Time out!");
    $fclose(outfile);
    $finish;
end
endmodule
