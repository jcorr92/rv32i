# input files
SRC     = $(SRC_DIR)
TB      = $(TB_DIR)/unit/alu_tb.v
OUT     = $(SOFTWARE_DIR)/alu_test
VCD     = $(SIM_DIR)/dump.vcd

# Default target
all: compile sim wave

# Compile
compile:
	iverilog -o $(OUT) $(SRC)/*.v $(TB)

# Run simulation
sim:
	vvp $(OUT)

# View waveform
wave:
	gtkwave $(VCD)

# Clean up generated files
clean:
	rm -f $(OUT) $(VCD)
