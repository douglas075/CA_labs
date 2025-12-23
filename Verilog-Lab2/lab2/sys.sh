#  # 模擬
# iverilog -g2012 -o sim.out tb_and2.sv and2.sv && vvp sim.out
 # 合成
  
yosys -p "
 read_verilog code/src/CPU.v;
 hierarchy -top CPU;
 proc; opt; fsm; opt; memory; opt;
 techmap; opt;
 #make sure nangate libraray path is correct
 dfflibmap -liberty ~/nangate45/NanGate45/lib/NangateOpenCellLibrary_typical.lib
 abc       -liberty ~/nangate45/NanGate45/lib/NangateOpenCellLibrary_typical.lib
 stat      -liberty ~/nangate45/NanGate45/lib/NangateOpenCellLibrary_typical.lib
 write_verilog -noattr mapped.v 
"
