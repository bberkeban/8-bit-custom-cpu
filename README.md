# 8 Bit Custom Single Cycle CPU Design

## Architecture
Since this CPU is custom, ISA format should be made clear:

### Instruction Set Architecture (ISA)

#### 1. Core Instructions [15:12]
| Opcode [15:12] | Instruction | Bit Layout [11:0] | Description |
| :---: | :--- | :--- | :--- |
| `0000` | **ALU** | `ALU_sel[11:9]`, `destQ[8:6]`, `src_Q[5:3]`, `src_Q[2:0]` | Performs ALU operation according to ALU_sel[11:9]. |
| `0001` | **LIM** | `dest_Q[11:9]`, `X[8]`, `im_value[7:0]` | Load Immediate: Loads 8-bit value to pointed register. |
| `0010` | **MOV** | `dest_Q[11:9]`, `src_Q[8:6]`, `XXXXXX[5:0]` | Move: Copies data from source to destination. |
| `0011` | **SIN** | `src_Q[11:9]`, `address_Q[8:6]`, `XXXXXX[5:0]` | Store Indirect: Stores source data to RAM address pointed by destination register. |
| `0100` | **RIN** | `dest_Q[11:9]`, `address_Q[8:6]`, `XXXXXX[5:0]` | Read Indirect: Loads data to destination from RAM address pointed by source register. |
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
| `1110` | Always JMP (No condition) |
| `1111` | Never JMP (No operation) |

> *Note: There is no independent unconditinonal jump (JMP) command since there is Always Jump (1110) in BJP Command*

#### Some Design Notes

CPU's ALU provides 8 operation. This set is sufficient for basic computation. Moreover, more advanced algorithms can be constructed with the help of CLL and RET commands/instructions.

A 4 bit of branch select provides 16 conditions. Even though CPU has an 8-bit architecture, it is capable of making decisions through relatively complex scenarios.

ISA shows potential for the development of a more complex CPU architectures. CPU can make decisions, call functions and return, evaluate conditions and branch jump.

Register 7 (Q7) is reserved for CLL and RET instructions. Next instruction address before CALL (PC + 1) is loaded into Register 7.

### Datapath Schematic

For visualization, the datapath of CPU is shown in below schematic:

#### Single Cycle 8-Bit CPU
<img width="3240" height="2036" alt="CPUschematicfinalized" src="https://github.com/user-attachments/assets/477ea94c-2b54-4572-a9ab-096c0740da8c" />

### Simulations

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
# For CLL and RET simuatlion:
iverilog -o CPU_sim_CLLRET.vvp src/*.v tb/CLL_RET.v
vvp CPU_sim_CLLRET.vvp
gtkwave CLL_RET.vcd
```

#### Verification of ALU-LIM-SIN-RIN Commands

Simulating testbench file tb/ALU_LIM_SIN_RIN.v:

<img width="1260" height="318" alt="ALU_LIM_SIN_RIN_tb" src="https://github.com/user-attachments/assets/20eaf46d-081c-470d-afe8-52c302c504a7" />

This simulation verifies ALU, LIM (Load Immediate), SIN-RIN (Store-Read Indirect) operations.

#### Verification of Branch Jump Command

Simulating testbench file tb/BJP.v:

<img width="1138" height="273" alt="BJP_tb" src="https://github.com/user-attachments/assets/3cfa91cc-b1cb-4ef8-a30a-022cb940fee0" />

CPU can perform branch jump. In this simulation CPU evaluated the equality and jumped from PC = 3 to PC = 8.

#### Verification of CALL and RETURN Commands

Simulating testbench file tb/CLL_RET.v

<img width="1203" height="274" alt="CLL_RET_tb" src="https://github.com/user-attachments/assets/83d380f7-0eb1-40a3-b843-d4b29e0dca5a" />

Verification of CALL and RETURN operations.

## Synthesis

### Timing and Critical Path Analysis

#### 1) Topological Gate Depth

Critical path of CPU is computed via yosys using below terminal commands:

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









