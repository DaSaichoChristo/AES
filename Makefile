filename = $(SRC_DIR)/top
pcf_file = $(PWD)/common/io.pcf

BUILD_DIR = '$(PWD)/build'
SRC_DIR = '$(PWD)/src'
SIM_DIR = '$(PWD)/sim'

ICELINK_DIR=$(shell df | grep iCELink | awk '{print $$6}')
${warning iCELink path: $(ICELINK_DIR)}

build:
	@if [ ! -d '$(BUILD_DIR)' ]; \
		then \
			mkdir $(BUILD_DIR) \
	fi
	yosys -p "synth_ice40 -json $(BUILD_DIR)/$(filename).json -blif $(BUILD_DIR)/$(filename).blif" $(SRC_DIR)/$(filename).v
	nextpnr-ice40 --up5k --package sg48 --json $(BUILD_DIR)/$(filename).json --pcf $(pcf_file) --asc $(BUILD_DIR)/$(filename).asc --freq 48
	icepack $(BUILD_DIR)/$(filename).asc $(BUILD_DIR)/$(filename).bin

test:
	mkdir -p $(SIM_DIR)
	@for f in test/*.py; do \
		name=$$(basename $$f .py); \
		echo "=== Testing $$name ==="; \
		$(MAKE) -C test TOPLEVEL=$$name COCOTB_TEST_MODULES=$$name || exit 1; \
	done

prog_flash: build
	@if [ -d '$(ICELINK_DIR)' ]; \
        then \
            cp $(BUILD_DIR)/$(filename).bin $(ICELINK_DIR); \
        else \
            echo "iCELink not found"; \
            exit 1; \
    fi

.PHONY: build test prog_flash clean

clean:
	rm -rf build sim comiled
	$(MAKE) -C test clean
	find . -name "__pycache__" -type d -prune -exec rm -rf {} +
	find . -name "results.xml" -delete

