# input files & env vars
SRC       = $(SRC_DIR)
GEN_DIR   = $(SIM_DIR)/gen
PROGS     = $(SOFTWARE_DIR)/programs
OBJS      = $(SOFTWARE_DIR)/objects
BINS      = $(SOFTWARE_DIR)/binaries
HEX       = $(SOFTWARE_DIR)/hex_files
TEST_NAME = instr_decode

compile: assembler linker extract

assembler:
	riscv64-unknown-elf-as $(PROGS)/$(TEST_NAME).S -o $(OBJS)/$(TEST_NAME).o

#-Ttext sets mem offset
linker:
	riscv64-unknown-elf-ld $(OBJS)/$(TEST_NAME).o -Ttext=0x00000000 -o $(BINS)/$(TEST_NAME).elf

extract:
	riscv64-unknown-elf-objcopy -O verilog $(BINS)/$(TEST_NAME).elf $(HEX)/$(TEST_NAME).hex

clean:
	rm -rf \
	$(SOFTWARE_DIR)/*/*.o \
	$(SOFTWARE_DIR)/*/*.elf \
	$(SOFTWARE_DIR)/*/*.hex \
	$(SOFTWARE_DIR)/*/*.bin
