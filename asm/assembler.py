import sys

assembly_blocks = []

with open("assemblercodes.txt") as rawcodes:

    for line in rawcodes:
    
        codeline = line.strip()

        if not codeline:
            continue

        assembly_code_block = codeline.split("//")[0].strip()

        if not assembly_code_block:
            continue

        assembly_blocks.append(assembly_code_block)

    opcode_dictionary = {
        "ADD" : "0000_000",
        "SUB" : "0000_001",
        "SIR" : "0000_010",
        "SIL" : "0000_011",
        "AND" : "0000_100",
        "XOR" : "0000_101",
        "OR" : "0000_110",
        "ASR" : "0000_111",
        "LIM" : "0001",
        "MOV" : "0010",
        "SIN" : "0011",
        "RIN" : "0100",
        "BEQ" : "0101_0000",
        "BNQ" : "0101_0001",
        "BLS" : "0101_0010",
        "BGES" : "0101_0011",
        "BGS" : "0101_0100",
        "BLES" : "0101_0101",
        "BLT" : "0101_0110",
        "BGE" : "0101_0111",
        "BGT" : "0101_1000",
        "BLE" : "0101_1001",
        "BVF" : "0101_1010",
        "BNV" : "0101_1011",
        "POS" : "0101_1100",
        "NEG" : "0101_1101",
        "JMP" : "0101_1110",
        "NOP" : "0101_1111",
        "CLL" : "1000",
        "RET" : "1001"
    }

    instructions = []

    for command in assembly_blocks:

        assembly_code_items = command.replace("," , " ").split()

        opcode = assembly_code_items[0]

        base_of_opcode = opcode_dictionary.get(opcode)

        if not base_of_opcode:
            print(f"Unknown Command! -> {command}")
            sys.exit()

        if opcode in ["ADD", "SUB", "AND", "XOR", "OR"]:
            
            Q_destination = assembly_code_items[1]
            Q_1 = assembly_code_items[2]
            Q_2 = assembly_code_items[3]

            destination_address_int = int(Q_destination.replace("Q" , ""))
            Q1_int = int(Q_1.replace("Q" , ""))
            Q2_int = int(Q_2.replace("Q" , ""))

            if destination_address_int > 7 or Q1_int > 7 or Q2_int > 7:
                print(f"I give up (I guess there are 8 registers?) -> {command}")
                sys.exit()

            if destination_address_int == 7:
                print(f"This register is reserved for CLL and RET commands -> {command}")
                sys.exit()

            destination_address_bin = f"{destination_address_int:03b}"
            Q1_bin = f"{Q1_int:03b}"
            Q2_bin = f"{Q2_int:03b}"

            
            finalized_instr = f"{base_of_opcode}_{destination_address_bin}_{Q1_bin}_{Q2_bin}"
            instructions.append(finalized_instr)

        elif opcode in ["SIR", "SIL", "ASR"]:

            Q_destination = assembly_code_items[1]
            Q_1 = assembly_code_items[2]

            destination_address_int = int(Q_destination.replace("Q" , ""))
            Q1_int = int(Q_1.replace("Q" , ""))

            if destination_address_int > 7 or Q1_int > 7:
                print(f"I give up (I guess there are 8 registers?) -> {command}")
                sys.exit()
            if destination_address_int == 7:
                print(f"This register is reserved for CLL and RET commands -> {command}")
                sys.exit()

            destination_address_bin = f"{destination_address_int:03b}"
            Q1_bin = f"{Q1_int:03b}"

            finalized_instr = f"{base_of_opcode}_{destination_address_bin}_{Q1_bin}_000"
            instructions.append(finalized_instr)

        elif opcode == "LIM":
            
            Q_destination = assembly_code_items[1]
            Q_dest_int = int(Q_destination.replace("Q" , ""))
            im_value = int(assembly_code_items[2])

            if Q_dest_int > 7 or im_value > 255:
                print(f"I give up (I guess it's an 8-bit CPU?)) -> {command}")
                sys.exit()
            if Q_dest_int == 7:
                print(f"This register is reserved for CLL and RET commands -> {command}")
                sys.exit()

            Q_dest_bin = f"{Q_dest_int:03b}"
            im_bin = f"{im_value:08b}"

            finalized_instr = f"{base_of_opcode}_{Q_dest_bin}_0_{im_bin}"
            instructions.append(finalized_instr)

        elif opcode in ["SIN", "RIN"]:

            data_reg = assembly_code_items[1]
            address_reg = assembly_code_items[2]

            data_reg_int = int(data_reg.replace("Q" , ""))
            address_reg_int = int(address_reg.replace("Q" , ""))

            if data_reg_int > 7 or address_reg_int > 7:
                print(f"I give up (I guess there are 8 registers?) -> {command}")
                sys.exit()

            # there is no protection againts overwriting Q7 in RIN command. Q7 is critical since it stores the next instruction in CLL commands!
            # assembler will be updated for this issue

            data_reg_bin = f"{data_reg_int:03b}"
            address_reg_bin = f"{address_reg_int:03b}"

            finalized_instr = f"{base_of_opcode}_{data_reg_bin}_{address_reg_bin}_000000"
            instructions.append(finalized_instr)

        elif opcode in ["BEQ", "BNQ", "BLS", "BGES", "BGS", "BLES", "BLT", "BGE", "BGT", "BLE", "BVF","BNV", "POS", "NEG", "JMP", "NOP"]:

            JMP_dest = int(assembly_code_items[1])

            if JMP_dest > 255:
                print(f"You exceed the address limit! -> {command}")
                sys.exit()
            
            JMP_dest_bin = f"{JMP_dest:08b}"

            finalized_instr = f"{base_of_opcode}_{JMP_dest_bin}"
            instructions.append(finalized_instr)
        
        elif opcode == "CLL":

            JMP_dest = int(assembly_code_items[1])

            if JMP_dest > 255:
                print(f"You exceed the address limit! -> {command}")
                sys.exit()
            
            JMP_dest_bin = f"{JMP_dest:08b}"

            finalized_instr = f"{base_of_opcode}_0000_{JMP_dest_bin}"
            instructions.append(finalized_instr)

        elif opcode == "RET":
            
            finalized_instr = f"{base_of_opcode}_0000_00000000"
            instructions.append(finalized_instr)

with open("assembler_instructions.txt", "w") as READROM:
    for instruction in instructions:
        READROM.write(instruction + "\n")
