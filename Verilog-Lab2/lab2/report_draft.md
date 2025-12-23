## sys result
just run `p3 parse.py`

## Env
just copy from last report

## Module Explanation

\subsection{PC}

This module takes 4 inputs: reset signal, clock signal, pc write signal, 32-bit next pc. At clock egde, if pc write signal is on, this module pass the next pc value from its input to output, which is connected to instruction memory. Its input, the next pc, is determined by the hazard detection unit and a normal add-4 adder.

\subsection{Adder}

Just a plain 32-bit 2-input adder. It's only used for updating the pc here. Though there is also an adder drawn in hazard detection unit in diagram in spec, I didn't make a instance for it as it's not necessary.

\subsection{Instruction_Memory}

This module takes only 1 input: the pc or said the address of instruction. Then it goes to its memory space and outputs the instruction found.

\subsection{IF_ID}



\subsection{Control}



\subsection{Registers}



\subsection{Imm_Gen}



\subsection{ID_EX}



\subsection{MUX32_4to1}



\subsection{MUX32_4to1}



\subsection{MUX32_2to1}



\subsection{ALU}



\subsection{ALU_Control}



\subsection{EX_MEM}



\subsection{Data_Memory}



\subsection{MEM_WB}



\subsection{MUX32_2to1}



\subsection{Hazard_Detection}



\subsection{Forwarding}


