# input files & env vars
SRC     = $(SRC_DIR)
GEN_DIR = $(SIM_DIR)/gen
IMMEDIATE_FILE = $(GEN_DIR)/immediates.list
TB      = top/top_tb.sv
# TB      = unit/imm_gen_tb.sv
TB_NAME = $(basename $(notdir $(TB)))
TB_PATH = $(TB_DIR)/$(TB)
VCD     = $(SIM_DIR)/dump.vcd
export TB_FILE = $(TB)

DEFINES = SIMULATION

# List all targets
print-targets:
	@echo "Available targets:" && \
	awk -F':' '/^[a-zA-Z0-9_-]+:([^=]|$$)/ {print $$1}' $(MAKEFILE_LIST) | sort | uniq

# Default target
all: generate build sim

# Build software payloads
generate:
	mkdir -p $(GEN_DIR)
	python3 ../tb/resources/imm_gen.py $(IMMEDIATE_FILE)

# Build
build: compile elab

# Compile
compile:
	@echo "\n ***** Running Vivado xsim with TB: $(TB_PATH) ***** \n"
	SRC_DIR=$(SRC_DIR) \
	TB_FILE=$(TB_PATH) \
	SIM_DIR=$(SIM_DIR) \
    xvlog -sv -d $(DEFINES) -f $(FILELIST_DIR)/filelist.f

# elab
elab:
	xelab -debug typical -top $(TB_NAME) -snapshot $(TB_NAME)_snapshot

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
	rm -rf $(VCD) \
	$(SIM_DIR)/.Xil \
	$(SIM_DIR)/*.log \
	$(SIM_DIR)/*.jou \
	$(SIM_DIR)/*.str \
	$(SIM_DIR)/*.pb \
	$(SIM_DIR)/*.wdb \
	$(SIM_DIR)/xvlog.* \
	$(SIM_DIR)/xelab.* \
	$(SIM_DIR)/xsim.dir \
	$(SIM_DIR)/gen \
	$(SIM_DIR)/imm_gen_test.log \
	$(SIM_DIR)/imm_gen_tb_snapshot.wdb

