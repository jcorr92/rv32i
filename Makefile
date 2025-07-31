clean:
	@if [ -z "$(VCD)" ] || [ -z "$(SIM_DIR)" ] || [ -z "$(SOFTWARE_DIR)" ]; then \
		echo "Error: VCD, SIM_DIR, and SOFTWARE_DIR must be set"; \
		exit 1; \
	fi
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
	$(SIM_DIR)/imm_gen_tb_snapshot.wdb \
	$(SOFTWARE_DIR)/*/*.o \
	$(SOFTWARE_DIR)/*/*.elf \
	$(SOFTWARE_DIR)/*/*.hex \
	$(SOFTWARE_DIR)/*/*.bin
