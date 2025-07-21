# input files & env vars
SRC     = $(SRC_DIR)
TB      = top/top_tb.sv
TB_NAME = $(basename $(notdir $(TB)))
TB_PATH = $(TB_DIR)/$(TB)
OUT     = $(SOFTWARE_DIR)/RV32I
VCD     = $(SIM_DIR)/dump.vcd
export TB_FILE = $(TB)

DEFINES = SIMULATION

# Default target
all: build sim wave

# List all targets
print-targets:
	@echo "Available targets:" && \
	awk -F':' '/^[a-zA-Z0-9_-]+:([^=]|$$)/ {print $$1}' $(MAKEFILE_LIST) | sort | uniq

# Compile
compile:
	@echo "\n ***** Running Vivado xsim with TB: $(TB_PATH) ***** \n"
	SRC_DIR=$(SRC_DIR) \
	TB_FILE=$(TB_PATH) \
	SIM_DIR=$(SIM_DIR) \
    xvlog -sv -d $(DEFINES) -f $(FILELIST_DIR)/filelist.f

# Build
elab:
	xelab -debug typical -top $(TB_NAME) -snapshot $(TB_NAME)_snapshot

# Build
build: compile elab

# Run simulation
sim:
	@if [ "$(GUI)" = "1" ]; then \
	    xsim --gui $(TB_NAME)_snapshot; \
	else \
	    xsim $(TB_NAME)_snapshot -R; \
	fi

# View waveform
wave:
	gtkwave $(VCD)

# Clean up generated files
clean:
	rm -rf $(OUT) $(VCD) \
	$(SIM_DIR)/.Xil $(SIM_DIR)/*.log $(SIM_DIR)/*.jou $(SIM_DIR)/xvlog.* $(SIM_DIR)/xsim.dir $(SIM_DIR)/xelab.* $(SIM_DIR)/*.wdb
