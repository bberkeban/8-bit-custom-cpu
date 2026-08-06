# 8 Bit Custom Single Cycle CPU Design

<div align="center">

![Language](https://img.shields.io/badge/Language-Verilog%20IEEE--1364-blue?style=flat-square)
![Synthesis](https://img.shields.io/badge/Synthesis-Yosys%20RTL-orange?style=flat-square)
![Logic Synthesis](https://img.shields.io/badge/Logic%20Synthesis-UC%20Berkeley%20ABC-darkblue?style=flat-square)
![Simulation](https://img.shields.io/badge/Simulation-Icarus%20Verilog-purple?style=flat-square)
![Visualization](https://img.shields.io/badge/Visualization-GTKWave-teal?style=flat-square)
![License](https://img.shields.io/badge/License-MIT-green?style=flat-square)

</div>


## Abstract

This project presents the design, verification, synthesis and optimization of a custom 8-bit single-cycle CPU -- fully implemented in Verilog. The CPU supports 8-opcode custom ISA (ALU, LIM, MOV, SIN, RIN, BJP, CLL, RET) with 16-condition branch evaluation unit. The processor has an 8-operation ALU and a dedicated link register for subroutine call/return operations. The functional verification was conducted using **Icarus Verilog** and **GTKwave** through various directed and random testbenches. Synthesis was carried out using
generic, library-independent logic synthesis. In an early design, critical path is dictated by CLL operations, primarily due to Program Counter unit having a **local** logic depth of 35. The Program Counter was subsequently optimized, reducing its local logic level to 9 (a %75 reduction). Sequential Equivalence Checking (SEC) was performed for the optimized Program Counter unit using **Yosys** SAT solver. This optimization process reduced the overall CPU's critical path from 59 to 45 logic levels. The current critical path of the CPU is dictated by ALU operations with a **%24** reduction.

## Architecture

### Instruction Set Architecture (ISA)

#### 1. Core Instructions [15:12]
| Opcode [15:12] | Instruction | Bit Layout [11:0] | Description |
| :---: | :--- | :--- | :--- |
| `0000` | **ALU** | `ALU_sel[11:9]`, `destination[8:6]`, `src_1[5:3]`, `src_2[2:0]` | Performs ALU operation according to ALU_sel[11:9]. |
| `0001` | **LIM** | `destination[11:9]`, `X[8]`, `immediate_val[7:0]` | Load Immediate: Loads 8-bit value to pointed register. |
| `0010` | **MOV** | `destination[11:9]`, `src[8:6]`, `XXXXXX[5:0]` | Move: Copies data from source to destination. |
| `0011` | **SIN** | `src_reg[11:9]`, `address_reg[8:6]`, `XXXXXX[5:0]` | Store Indirect: Stores source data to RAM address pointed by destination register. |
| `0100` | **RIN** | `destination[11:9]`, `address_reg[8:6]`, `XXXXXX[5:0]` | Read Indirect: Loads data to destination from RAM address pointed by source register. |
| `0101` | **BJP** | `condition[11:8]`, `address[7:0]` | Branch Jump: Jumps to address based on condition (see table below). |
| `1000` | **CLL** | `XXXX[11:8]`, `address[7:0]` | Call (Jump + Link): Jumps to pointed address and saves next address in Register 7 (Q7). |
| `1001` | **RET** | `XXXXXXXXXXXX[11:0]` | Return: Returns from CALL using the address from Register 7 (Q7). |

> *Note: `X` represents ignored/don't care bits.*

> *Note: `Q` represents register.*


#### 2. ALU Operations (`ALU_sel [11:9]`)
| `ALU_sel` | Operation | Description |
| :---: | :--- | :--- |
| `000` | **ADD** | Addition |
| `001` | **SUB** | Subtraction |
| `010` | **SIR** | Shift Right (Logical) |
| `011` | **SIL** | Shift Left (Logical) |
| `100` | **AND** | Bitwise AND |
| `101` | **XOR** | Bitwise XOR |
| `110` | **OR**  | Bitwise OR |
| `111` | **ASR** | Arithmetic Shift Right |


#### 3. Branch Jump Conditions (`condition [11:8]`)
| `cond`  | Description |
| :---: | :--- |
| `0000` | Jump if Equal (`==`) |
| `0001` | Jump if Not Equal (`!=`) |
| `0010` | Jump if Lesser Than (`<` signed) |
| `0011` | Jump if Greater or Equal (`>=` signed) |
| `0100` | Jump if Greater Than (`>` signed) |
| `0101` | Jump if Lesser or Equal (`<=` signed) |
| `0110` | Jump if Lesser Than (`<` unsigned) |
| `0111` | Jump if Greater or Equal (`>=` unsigned) |
| `1000` | Jump if Greater Than (`>` unsigned) |
| `1001` | Jump if Lesser or Equal (`<=` unsigned) |
| `1010` | Jump if overflow |
| `1011` | Jump if no overflow |
| `1100` | Jump if positive |
| `1101` | Jump if negative |
| `1110` | Always Jump (No condition) |
| `1111` | Never Jump (No operation) |

> *Note: There is no independent unconditinonal jump (JMP) command since there is Always Jump (1110) in BJP Command*

#### Some Design Notes

CPU's ALU provides 8 operation. This set is sufficient for basic computation. Moreover, more advanced algorithms can be constructed with the help of CLL and RET commands/instructions.

A 4 bit of branch select provides 16 conditions. Even though CPU has an 8-bit architecture, it is capable of making decisions through relatively complex scenarios.

ISA shows potential for the development of a more complex CPU architectures. CPU can make decisions, call functions and return, evaluate conditions and branch jump.

Register 7 (Q7) is reserved for CLL and RET instructions. Next instruction address before CALL (PC + 1) is loaded into Register 7.

### Datapath Schematic

For visualization, the datapath of CPU is shown in below schematic:

<div align="center">
  <img width="3240" height="2036" alt="CPUschematicfinalized" src="https://github.com/user-attachments/assets/477ea94c-2b54-4572-a9ab-096c0740da8c" />
  <p><b>Figure 1:</b> 8-Bit Single Cycle CPU RTL Schematic</p>
</div>


## Verification


### Functional Verification

Results below are obtained via **Icarus Verilog** and **GTKwave**.
In order to simulate the CPU in your local device, you can run these terminal commands.

> *Note: Since the CPU fetches instructions from the ROM, update ROM_opcode.txt according to your intended simulation. The machine code blocks for each simulation are ready to execute once the "//" comment indicators are removed.*

```bash
# For branch jump simulation: 
iverilog -o CPU_sim_BJP.vvp src/*.v tb/BJP.v
vvp CPU_sim_BJP.vvp
gtkwave BJP.vcd
```
```bash
# For ALU, LIM, SIN and RIN simulation;
iverilog -o CPU_sim_ALSR.vvp src/*.v tb/ALU_LIM_SIN_RIN.v
vvp CPU_sim_ALSR.vvp
gtkwave ALU_LIM_SIN_RIN.vcd
```
```bash
# For CLL and RET simulation:
iverilog -o CPU_sim_CLLRET.vvp src/*.v tb/CLL_RET.v
vvp CPU_sim_CLLRET.vvp
gtkwave CLL_RET.vcd
```

#### 1) Directed Testing

##### Verification of ALU-LIM-SIN-RIN Commands

<div align="center">
  <h4>ALU-LIM-SIN-RIN Directed Test Flow</h4>
</div>

<div align = "center">
  
| Clock Cycle | Assembly Code | RTL | Comment |
| :---: | :---: | :---: | :---: |
| `#0` | `LIM Q0 15` | `Q0 <- d15` | `Load 15 into Register 0` |
| `#1` | `LIM Q1 1` | `Q1 <- d1` | `Load 1 into Register 1` |
| `#2` | `ADD Q3, Q0 Q1` | `Q3 <- Q0 + Q1` | `Add Q0 and Q1, store result in Q3` |
| `#3` | `LIM Q6 8` | `Q6 <- d8` | `Load 8 into Register 6` |
| `#4` | `SIN Q3, Q6` | `MEM[Q6] <- Q3` | `Store value of Q3 into memory address at Q6` |
| `#5` | `RIN Q2, Q6` | `Q2 <- MEM[Q6]` | `Read value from memory address at Q6 into Q2` |

</div>

Simulating testbench file tb/ALU_LIM_SIN_RIN.v:

<div align="center">
<img width="1201" height="329" alt="ALU_LIM_RIN_SIN_tb_new" src="https://github.com/user-attachments/assets/3836bc1b-aa5f-45a6-a211-3ae8255241d3" />
<p><b>Figure 2:</b> ALU-LIM-SIN-RIN Operations' Directed Testbench Waveforms</p>
</div>

This simulation was conducted in order to verify ALU, LIM, SIN and RIN instructions. As highlighted in Figure 2; CPU loaded immediate value (LIM Q0 15), performed ALU operations (ADD Q3, Q0 Q1), stored/read indirect by using register values as address pointers (SIN Q3, Q6 - RIN Q2, Q6).

##### Verification of Branch Jump Command

<div align="center">
  <h4>BJP Directed Test Flow</h4>
</div>

<div align = "center">
  
| Clock Cycle | Assembly Code | RTL | Comment |
| :---: | :---: | :---: | :---: |
| `#0` | `LIM Q0 24` | `Q0 <- d24` | `Load 24 into Register 0`|
| `#1` | `LIM Q1 24` | `Q1 <- d24` | `Load 24 into Register 1`|
| `#2` | `SUB Q2, Q1 Q0` | `Q2 <- Q1 - Q0` | `Subtract Q0 from Q1 and load into Q2`|
| `#3` | `BEQ 8` | `If Equal PC <- 8` | `Evaluate equality and branch jump to 8th address`  |
| `#4` | `LIM Q0 8` | `Q0 <- 8` | `Trap instruction` |
| `#5` | `LIM Q1 8` | `Q1 <- 8` | `Trap instruction` |
| `#6` | `LIM Q2 8` | `Q2 <- 8` | `Trap instruction` |
| `#7` | `LIM Q3 8` | `Q3 <- 8` | `Trap instruction` |
| `#8` | `ADD Q2, Q0 Q1` | `Q2 <- Q0 + Q1` | `CPU successfully branch jumped and executed 8th instruction`|

</div>

Simulating testbench file tb/BJP.v:

<div align="center">
<img width="1354" height="260" alt="BJP_tb_new" src="https://github.com/user-attachments/assets/7b6506ef-362d-4d3f-909e-9c386215ca5c" />
<p><b>Figure 3:</b> Branch Jump Operation's Directed Testbench Waveforms</p>
</div>

This test flow was focused on Branch Jump operation of the CPU. As highlighted in Figure 3, CPU evaluated the BEQ (Jump if equal) condition at clock cycle = #3 and successfully branched to PC = 8. There are trap instructions between clock cycle #4-#7 which the CPU should not execute. The CPU did not execute trap instructions and successfully carried on instruction #8 (ADD Q2, Q0 Q1). If the CPU failed to properly simulate the test flow, it could be detected by examining Registers 1-3.

##### Verification of CALL and RETURN Commands

<div align="center">
  <h4>CLL-RET Directed Test Flow</h4>
</div>

<div align = "center">
  
| Clock Cycle | Assembly Code | RTL | Comment |
| :---: | :---: | :---: | :---: |
| `#0` | `LIM Q0 8` | `Q0 <- d8` | `Load 8 into Register 0` |
| `#1` | `LIM Q1 2` | `Q1 <- d2` | `Load 2 into Register 1` |
| `#2` | `CLL 4` | `Q7 <- 3, PC <- 4` | `Call subroutine at address 4` |
| `#3` | `LIM Q2 16` | `Q2 <- d16` | `(Skipped by CLL)` |
| `#4` | `ADD Q5, Q0 Q1` | `Q5 <- Q0 + Q1` | `Subroutine execution: Add Q0, Q1 and write Q5` |
| `#5` | `RET` | `PC <- Q7(3)` | `CPU successfully returned from subroutine` |

</div>

Simulating testbench file tb/CLL_RET.v

<div align="center">
<img width="1340" height="284" alt="CLL_RET_tb_new" src="https://github.com/user-attachments/assets/3fbf9ea9-493d-4fe2-ae2d-539f6f60fc57" />
<p><b>Figure 4:</b> Call and Return Operations' Directed Testbench Waveforms</p>
</div>

The ability of executing subroutine without any hardware complication of CPU was verified. As highlighted in Figure 4, the CPU called a subroutine in clock cycle #2 and jumped to 4th instruction address. It is crucial to show that return address (PC + 1) was stored in Register 7 (Q7) since it is dedicated to CLL/RET instructions. The CPU successfully executed the subroutine at 4th instruction address and returned to PC = 3 by reading Register 7 (Q7).

Verification of CALL and RETURN operations.

#### 2) Random Testing

### Structural Verification

The CPU is structurally verified using below **Yosys** commands

```bash
# Reading all source verilog code in /src file
read_verilog *.v

# Declaring the top module
hierarchy -check -top CPU

# Removing hierarchal boundaries between top/sub modules
flatten

# Synthesize physical units from behavioral and memory code blocks
proc
opt -full

memory
memory_map
opt -full

# Synthesize physical units from logical and arithmetic code blocks
techmap

# Optimize and clean unused wires-pins before verification
opt -full
clean

# Verify the CPU by checking unused drivers, pins and wires
check

# Verify the CPU by checking strongly connected components (logic-combinational loops)
scc -expect 0
```

The design is structurally verified as shown in below terminal lines. Yosys detected 0 structural problems and combinational loops. Since the CPU has a single-cycle architecture, a combinational loop would have devastating synthesis consequences. By flattening the design, all units / submodules and datapath are checked, thereby verifying the entire structure.

```bash
18. Executing CHECK pass (checking for obvious problems).
Checking module CPU...
Found and reported 0 problems.

19. Executing SCC pass (detecting logic loops).
Found 0 SCCs in module CPU.
Found and expected 0 SCCs.
```

### Formal Verification

## Synthesis

### Timing and Critical Path Analysis

#### 1) Topological Gate Depth

Critical path of the CPU is computed via yosys using below terminal commands:

```bash
# Read the module that yosys is going to synthesis
read_verilog src/"ModuleFileName".v

# Check and declare the top module
hierarchy -check -top "ModuleName"

# Translate behavioral code blocks and abstract memory arrays into physical flip-flops
proc
memory
opt -full

# Flatten all modules included in top module, removing top/sub module boundaries.
flatten
opt -full

# Map abstract arithmetic/logical codes into physical cells
techmap
opt -full

# Synthesize the module by only using primitive gate cells. Transfer $MUX or $ADD cells into AND, OR, XOR...
abc -g gates
opt -full

# Remove unused pins, wires and cells
clean

# Show implementation statistics
stat

# Compute the Longest Topological Path
ltp
```

Longest Topological Path (Critical Path) of all modules are shown below table:

| Module Name | Longest Topological Path (LTP) |
| :--- | :---: |
| **ALU** (Arith. Logic Unit) | 19 |
| **CU** (Control Unit) | 10 |
| **PC** (Program Counter) | 9 |
| **RF** (Register File) | 7 |
| **SR** (Status Register) | 1 |
| **RAM** (Data Memory) | 15 |
| **ROM** (Instruction Mem.)| 3 |

These LTP values show the gate-level depth (Logic Level) of all modules. With this information, the critical path of CPU can be determined **without using an external library** - solely depends on generic synthesis.

#### 2) Critical Path

The critical path of CPU is decided by ALU instructions with LTP of 45. 

> *Note: Because there is no external library given to Yosys, the ALU is synthesized using an 8-bit RCA (Ripple Carry Adder). An 8-bit RCA alone has 16 logic level. Thus, the ALU has the longest LTP and determines the critical path.*









