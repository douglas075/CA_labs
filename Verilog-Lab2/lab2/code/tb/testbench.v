`define CYCLE_TIME 50            
`define MAXIMUM_CYCLE 100         
module TestBench;

reg                Clk;
reg                Start;
reg                Reset;
integer            i, outfile;
integer            stall, flush, start;
parameter          num_cycles = 64;

always #(`CYCLE_TIME/2) Clk = ~Clk;    

CPU u_CPU(
    .clk_i  (Clk),
    .rst_n  (Reset)
);
  
initial begin
    $dumpfile("waveform.vcd");
    $dumpvars;
    
    stall = 0;
    flush = 0;
    start = 0;
    
    // initialize instruction memory
    for(i=0; i<256; i=i+1) begin
        u_CPU.u_Instruction_Memory.memory[i] = 32'b0;
    end
    
    // initialize data memory
    for(i=0; i<32; i=i+1) begin
        u_CPU.u_Data_Memory.memory[i] = 32'b0;
    end    
        
    // Load instructions into instruction memory
    // Make sure you change back to "instruction.txt" before submission
    $readmemb("instruction.txt", u_CPU.u_Instruction_Memory.memory);
    
    // Open output file
    // Make sure you change back to "output.txt" before submission
    outfile = $fopen("output.txt") | 1;
    
    Clk = 0;
    Reset = 1;

    #(`CYCLE_TIME/8) 
    Reset = 0;

    #(`CYCLE_TIME/8) 
    Reset = 1;
    start = 1;

    // [D-MemoryInitialization] DO NOT REMOVE THIS FLAG !!!
    u_CPU.u_Data_Memory.memory[0] = 5;
    u_CPU.u_Data_Memory.memory[1] = 6;
    u_CPU.u_Data_Memory.memory[2] = 10;
    u_CPU.u_Data_Memory.memory[3] = 18;
    u_CPU.u_Data_Memory.memory[4] = 29;

    u_CPU.u_Registers.register[24] = -24;
    u_CPU.u_Registers.register[25] = -25;
    u_CPU.u_Registers.register[26] = -26;
    u_CPU.u_Registers.register[27] = -27;
    u_CPU.u_Registers.register[28] = 56;
    u_CPU.u_Registers.register[29] = 58;
    u_CPU.u_Registers.register[30] = 60;
    u_CPU.u_Registers.register[31] = 62;

end
  
integer cycle_count;
integer eof_pc;
integer out_stall, out_flush;

initial begin
    cycle_count = 0;
    eof_pc = 0;
    out_stall = 0; out_flush = 0;
    wait(start);
    $fdisplay(outfile,"cycle = %11d, Stall = %0d, Flush = %0d\nPC = %10d",0, 0, 0, 0);
    $fdisplay(outfile, "Registers");
    $fdisplay(outfile, "x0 = %10d, x8  = %10d, x16 = %10d, x24 = %10d", 0,0,0,-24);
    $fdisplay(outfile, "x1 = %10d, x9  = %10d, x17 = %10d, x25 = %10d", 0,0,0,-25);
    $fdisplay(outfile, "x2 = %10d, x10 = %10d, x18 = %10d, x26 = %10d", 0,0,0,-26);
    $fdisplay(outfile, "x3 = %10d, x11 = %10d, x19 = %10d, x27 = %10d", 0,0,0,-27);
    $fdisplay(outfile, "x4 = %10d, x12 = %10d, x20 = %10d, x28 = %10d", 0,0,0,56);
    $fdisplay(outfile, "x5 = %10d, x13 = %10d, x21 = %10d, x29 = %10d", 0,0,0,58);
    $fdisplay(outfile, "x6 = %10d, x14 = %10d, x22 = %10d, x30 = %10d", 0,0,0,60);
    $fdisplay(outfile, "x7 = %10d, x15 = %10d, x23 = %10d, x31 = %10d", 0,0,0,62);
    $fdisplay(outfile, "Data Memory: 0x00 = %10d", 5);
    $fdisplay(outfile, "Data Memory: 0x04 = %10d", 6);
    $fdisplay(outfile, "Data Memory: 0x08 = %10d", 10);
    $fdisplay(outfile, "Data Memory: 0x0C = %10d", 18);
    $fdisplay(outfile, "Data Memory: 0x10 = %10d", 29);
    $fdisplay(outfile, "Data Memory: 0x14 = %10d", 0);
    $fdisplay(outfile, "Data Memory: 0x18 = %10d", 0);
    $fdisplay(outfile, "Data Memory: 0x1C = %10d", 0);

    $fdisplay(outfile, "\n");
    cycle_count = cycle_count + 1;
    // ebreak 0x00100073
    while(u_CPU.u_Instruction_Memory.memory[u_CPU.u_PC.pc_o >> 2] !== 32'h00100073) begin
        @(negedge Clk);
        // put in your own signal to count stall and flush
        out_stall = stall;
        out_flush = flush;
        if(u_CPU.ID_Stall == 1 && u_CPU.ID_FlushIF == 0)stall = stall + 1;
        if(u_CPU.ID_FlushIF == 1)flush = flush + 1;  


        // print PC
        // DO NOT CHANGE THE OUTPUT FORMAT
        $fdisplay(outfile,"cycle = %11d, Stall = %0d, Flush = %0d\nPC = %10d",cycle_count, out_stall, out_flush, u_CPU.u_PC.pc_o);
        
        // print Registers
        // DO NOT CHANGE THE OUTPUT FORMAT
        $fdisplay(outfile, "Registers");
        $fdisplay(outfile, "x0 = %10d, x8  = %10d, x16 = %10d, x24 = %10d", u_CPU.u_Registers.register[0], u_CPU.u_Registers.register[8] , u_CPU.u_Registers.register[16], u_CPU.u_Registers.register[24]);
        $fdisplay(outfile, "x1 = %10d, x9  = %10d, x17 = %10d, x25 = %10d", u_CPU.u_Registers.register[1], u_CPU.u_Registers.register[9] , u_CPU.u_Registers.register[17], u_CPU.u_Registers.register[25]);
        $fdisplay(outfile, "x2 = %10d, x10 = %10d, x18 = %10d, x26 = %10d", u_CPU.u_Registers.register[2], u_CPU.u_Registers.register[10], u_CPU.u_Registers.register[18], u_CPU.u_Registers.register[26]);
        $fdisplay(outfile, "x3 = %10d, x11 = %10d, x19 = %10d, x27 = %10d", u_CPU.u_Registers.register[3], u_CPU.u_Registers.register[11], u_CPU.u_Registers.register[19], u_CPU.u_Registers.register[27]);
        $fdisplay(outfile, "x4 = %10d, x12 = %10d, x20 = %10d, x28 = %10d", u_CPU.u_Registers.register[4], u_CPU.u_Registers.register[12], u_CPU.u_Registers.register[20], u_CPU.u_Registers.register[28]);
        $fdisplay(outfile, "x5 = %10d, x13 = %10d, x21 = %10d, x29 = %10d", u_CPU.u_Registers.register[5], u_CPU.u_Registers.register[13], u_CPU.u_Registers.register[21], u_CPU.u_Registers.register[29]);
        $fdisplay(outfile, "x6 = %10d, x14 = %10d, x22 = %10d, x30 = %10d", u_CPU.u_Registers.register[6], u_CPU.u_Registers.register[14], u_CPU.u_Registers.register[22], u_CPU.u_Registers.register[30]);
        $fdisplay(outfile, "x7 = %10d, x15 = %10d, x23 = %10d, x31 = %10d", u_CPU.u_Registers.register[7], u_CPU.u_Registers.register[15], u_CPU.u_Registers.register[23], u_CPU.u_Registers.register[31]);

        // print Data Memory
        // DO NOT CHANGE THE OUTPUT FORMAT
        $fdisplay(outfile, "Data Memory: 0x00 = %10d", u_CPU.u_Data_Memory.memory[0]);
        $fdisplay(outfile, "Data Memory: 0x04 = %10d", u_CPU.u_Data_Memory.memory[1]);
        $fdisplay(outfile, "Data Memory: 0x08 = %10d", u_CPU.u_Data_Memory.memory[2]);
        $fdisplay(outfile, "Data Memory: 0x0C = %10d", u_CPU.u_Data_Memory.memory[3]);
        $fdisplay(outfile, "Data Memory: 0x10 = %10d", u_CPU.u_Data_Memory.memory[4]);
        $fdisplay(outfile, "Data Memory: 0x14 = %10d", u_CPU.u_Data_Memory.memory[5]);
        $fdisplay(outfile, "Data Memory: 0x18 = %10d", u_CPU.u_Data_Memory.memory[6]);
        $fdisplay(outfile, "Data Memory: 0x1C = %10d", u_CPU.u_Data_Memory.memory[7]);

        $fdisplay(outfile, "\n");
        cycle_count = cycle_count + 1;
    end
    eof_pc = u_CPU.u_PC.pc_o;
    @(negedge Clk);
    while(u_CPU.u_PC.pc_o !== eof_pc + 20) begin
                // put in your own signal to count stall and flush
        out_stall = stall;
        out_flush = flush;
        if(u_CPU.ID_Stall == 1 && u_CPU.ID_FlushIF == 0)stall = stall + 1;
        if(u_CPU.ID_FlushIF == 1)flush = flush + 1;  


        // print PC
        // DO NOT CHANGE THE OUTPUT FORMAT
        $fdisplay(outfile,"cycle = %11d, Stall = %0d, Flush = %0d\nPC = %10d",cycle_count, out_stall, out_flush, u_CPU.u_PC.pc_o);
        
        // print Registers
        // DO NOT CHANGE THE OUTPUT FORMAT
        $fdisplay(outfile, "Registers");
        $fdisplay(outfile, "x0 = %10d, x8  = %10d, x16 = %10d, x24 = %10d", u_CPU.u_Registers.register[0], u_CPU.u_Registers.register[8] , u_CPU.u_Registers.register[16], u_CPU.u_Registers.register[24]);
        $fdisplay(outfile, "x1 = %10d, x9  = %10d, x17 = %10d, x25 = %10d", u_CPU.u_Registers.register[1], u_CPU.u_Registers.register[9] , u_CPU.u_Registers.register[17], u_CPU.u_Registers.register[25]);
        $fdisplay(outfile, "x2 = %10d, x10 = %10d, x18 = %10d, x26 = %10d", u_CPU.u_Registers.register[2], u_CPU.u_Registers.register[10], u_CPU.u_Registers.register[18], u_CPU.u_Registers.register[26]);
        $fdisplay(outfile, "x3 = %10d, x11 = %10d, x19 = %10d, x27 = %10d", u_CPU.u_Registers.register[3], u_CPU.u_Registers.register[11], u_CPU.u_Registers.register[19], u_CPU.u_Registers.register[27]);
        $fdisplay(outfile, "x4 = %10d, x12 = %10d, x20 = %10d, x28 = %10d", u_CPU.u_Registers.register[4], u_CPU.u_Registers.register[12], u_CPU.u_Registers.register[20], u_CPU.u_Registers.register[28]);
        $fdisplay(outfile, "x5 = %10d, x13 = %10d, x21 = %10d, x29 = %10d", u_CPU.u_Registers.register[5], u_CPU.u_Registers.register[13], u_CPU.u_Registers.register[21], u_CPU.u_Registers.register[29]);
        $fdisplay(outfile, "x6 = %10d, x14 = %10d, x22 = %10d, x30 = %10d", u_CPU.u_Registers.register[6], u_CPU.u_Registers.register[14], u_CPU.u_Registers.register[22], u_CPU.u_Registers.register[30]);
        $fdisplay(outfile, "x7 = %10d, x15 = %10d, x23 = %10d, x31 = %10d", u_CPU.u_Registers.register[7], u_CPU.u_Registers.register[15], u_CPU.u_Registers.register[23], u_CPU.u_Registers.register[31]);

        // print Data Memory
        // DO NOT CHANGE THE OUTPUT FORMAT
        $fdisplay(outfile, "Data Memory: 0x00 = %10d", u_CPU.u_Data_Memory.memory[0]);
        $fdisplay(outfile, "Data Memory: 0x04 = %10d", u_CPU.u_Data_Memory.memory[1]);
        $fdisplay(outfile, "Data Memory: 0x08 = %10d", u_CPU.u_Data_Memory.memory[2]);
        $fdisplay(outfile, "Data Memory: 0x0C = %10d", u_CPU.u_Data_Memory.memory[3]);
        $fdisplay(outfile, "Data Memory: 0x10 = %10d", u_CPU.u_Data_Memory.memory[4]);
        $fdisplay(outfile, "Data Memory: 0x14 = %10d", u_CPU.u_Data_Memory.memory[5]);
        $fdisplay(outfile, "Data Memory: 0x18 = %10d", u_CPU.u_Data_Memory.memory[6]);
        $fdisplay(outfile, "Data Memory: 0x1C = %10d", u_CPU.u_Data_Memory.memory[7]);

        $fdisplay(outfile, "\n");
        cycle_count = cycle_count + 1;
        @(negedge Clk);
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
