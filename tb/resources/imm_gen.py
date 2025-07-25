import random
import sys
out_path = sys.argv[1] if len(sys.argv) > 1 else "immediates.list"

num_tests = 10000

opcodes = [
    "OPCODE_I_TYPE_ALU",
    "OPCODE_I_TYPE_LD",
    "OPCODE_I_TYPE_JALR",
    "OPCODE_S_TYPE",
    "OPCODE_B_TYPE",
    "OPCODE_LUI",
    "OPCODE_AUIPC",
    "OPCODE_J_TYPE"
]

# Opcode to immediate size mapping (bits)
imm_width = {
    "OPCODE_I_TYPE_ALU": 12,
    "OPCODE_I_TYPE_LD": 12,
    "OPCODE_I_TYPE_JALR": 12,
    "OPCODE_S_TYPE": 12,
    "OPCODE_B_TYPE": 13,
    "OPCODE_LUI": 20,
    "OPCODE_AUIPC": 20,
    "OPCODE_J_TYPE": 21
}

def sEXT_64b_hex(val):
    return f"{(val & 0xFFFFFFFFFFFFFFFF):016X}"

def sEXT_64b_hex_branch(val):
    return f"{(val & 0xFFFFFFFFFFFFFFFE):016X}"

def zEXT_64b_hex(val):
    return f"{(val & 0xFFFFFFFF):016X}"

with open (out_path, "w") as log:
    for i in range (num_tests):
        # Select random opcode
        opcode = random.choice(opcodes)
        # Generate random signed immediate value
        bits = imm_width[opcode]
        max_val = (1 << (bits - 1)) - 1
        min_val = -(1 << (bits - 1))
        imm_val = random.randint(min_val, max_val)
        if(opcode in ["OPCODE_LUI", "OPCODE_AUIPC"]):
            imm_val = (imm_val << 12)
            exp_val = zEXT_64b_hex(imm_val)
        elif(opcode in ["OPCODE_B_TYPE", "OPCODE_J_TYPE"]):
            exp_val = sEXT_64b_hex_branch(imm_val)
        else:
            exp_val = sEXT_64b_hex(imm_val)
        # print(f"{opcode} {imm_val} {exp_val}")
        log.write(f"{opcode} {imm_val} {exp_val}\n")
