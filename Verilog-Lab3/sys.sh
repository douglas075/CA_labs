  
yosys -l log/cpu_syn.log -p "
    read_liberty -lib nangate/NanGate45/lib/NangateOpenCellLibrary_typical.lib;
    read_verilog  code/src/*.v;
    hierarchy -top CPU;
    proc; opt_clean;
    fsm; opt_clean;
    techmap; opt_clean;
    flatten CPU;
    dfflibmap -liberty nangate/NanGate45/lib/NangateOpenCellLibrary_typical.lib;
    abc -liberty nangate/NanGate45/lib/NangateOpenCellLibrary_typical.lib;
    stat -liberty nangate/NanGate45/lib/NangateOpenCellLibrary_typical.lib;
  "
yosys -l log/cache_syn.log -p "
    read_liberty -lib nangate/NanGate45/lib/NangateOpenCellLibrary_typical.lib;
    read_verilog code/src/cache.v;
    hierarchy -top Cache;
    proc; opt_clean;
    fsm; opt_clean;
    techmap; opt_clean;
	flatten Cache;
    dfflibmap -liberty nangate/NanGate45/lib/NangateOpenCellLibrary_typical.lib;
    abc -liberty nangate/NanGate45/lib/NangateOpenCellLibrary_typical.lib;
    stat -liberty nangate/NanGate45/lib/NangateOpenCellLibrary_typical.lib;
  "