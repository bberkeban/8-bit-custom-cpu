# 8 Bit Custom Single Cycle CPU Design
## Built from scratch in Verilog

Since this CPU is custom, ISA format should be made clear:

### Instruction Set Architecture (ISA)

#### 1. Core Instructions [15:12]
| Opcode [15:12] | Instruction | Bit Layout [11:0] | Description |
| :---: | :--- | :--- | :--- |
| `0000` | **ALU** | `ALU_sel[11:9]`, `destQ[8:6]`, `srcQ1[5:3]`, `srcQ2[2:0]` | Performs ALU operation according ALU_sel[11:9]. |
| `0001` | **LIM** | `destQ[11:9]`, `X[8]`, `im[7:0]` | Load Immediate: Loads 8-bit value to pointed register. |
| `0010` | **MOV** | `destQ2[11:9]`, `srcQ1[8:6]`, `XXXXXX[5:0]` | Move: Copies data from source to destination. |
| `0011` | **SIN** | `srcQ[11:9]`, `addressQ[8:6]`, `XXXXXX[5:0]` | Store Indirect: Stores source data to RAM address pointed by destination register. |
| `0100` | **RIN** | `dest[11:9]`, `addressQ[8:6]`, `XXXXXX[5:0]` | Read Indirect: Loads data to destination from RAM address pointed by source register. |
| `0101` | **BJP** | `condition[11:8]`, `address[7:0]` | Branch Jump: Jumps to address based on condition (see table below). |
| `1000` | **CLL** | `XXXX[11:8]`, `addr[7:0]` | Call (Jump + Link): Jumps to pointed address and saves next address in Register 7 (Q7). |
| `1001` | **RET** | `XXXXXXXXXXXX[11:0]` | Return: Returns from CALL using the address from Register 7 (Q7). |

> *Note: `X` represents ignored/don't care bits.*

> *Note: `Q` represents/means register.*


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


#### 3. Branch JMP Conditions (`condition [11:8]`)
| `cond`  | Description |
| :---: | :--- |
| `0000` | JMP if Equal (`==`) |
| `0001` | JMP if Not Equal (`!=`) |
| `0010` | JMP if Lesser Than (`<` signed) |
| `0011` | JMP if Greater or Equal (`>=` signed) |
| `0100` | JMP if Greater Than (`>` signed) |
| `0101` | JMP if Lesser or Equal (`<=` signed) |
| `0110` | JMP if Lesser Than (`<` unsigned) |
| `0111` | JMP if Greater or Equal (`>=` unsigned) |
| `1000` | JMP if Greater Than (`>` unsigned) |
| `1001` | JMP if Lesser or Equal (`<=` unsigned) |
| `1010` | JMP if overflow |
| `1011` | JMP if no overflow |
| `1100` | JMP if positive |
| `1101` | JMP if negative |
| `1110` | Always JMP |
| `1111` | Never JMP (No operation) |

> *Note: There is no independent unconditinonal jump (JMP) command.*

#### Some Design Notes

CPU's ALU provides 8 operation. This set is sufficient for basic computation. Moreover, more advanced algorithms can be constructed with the help of CLL and RET commands/instructions.

A 4 bit of branch select provides 16 conditions. Even though CPU has an 8-bit architecture, it is capable of making decisions through relatively complex scenarios.

ISA shows potential for the development of a more complex CPU architectures. CPU can make decisions, call functions and return, evaluate conditions and branch jump.

Register 7 (Q7) is reserved for CLL and RET instructions. Next instruction address before CALL (PC + 1) is loaded into Register 7.

### Datapath Schematic

For visualization, the datapath of CPU is shown below schematic:

#### Single Cycle 8-Bit CPU
<img width="3240" height="2036" alt="CPUschematicfinalized" src="https://github.com/user-attachments/assets/477ea94c-2b54-4572-a9ab-096c0740da8c" />

### Simulations

Results below are obtained via **Icarus Verilog** and **GTKwave**.
In order to compile and simulate the proccessor in your local device, you can run these terminal commands.

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

Using testbench file tb/ALU_LIM_SIN_RIN.v:
<img width="1260" height="318" alt="ALU_LIM_SIN_RIN_tb" src="https://github.com/user-attachments/assets/20eaf46d-081c-470d-afe8-52c302c504a7" />

#### Verification of Branch Jump Command

Using testbench file tb/BJP.v:
<img width="1138" height="273" alt="BJP_tb" src="https://github.com/user-attachments/assets/3cfa91cc-b1cb-4ef8-a30a-022cb940fee0" />

#### Verification of CALL and RETURN Commands

Using testbench file tb/CLL_RET.v
<img width="1203" height="274" alt="CLL_RET_tb" src="https://github.com/user-attachments/assets/83d380f7-0eb1-40a3-b843-d4b29e0dca5a" />




