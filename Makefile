filename = design/top
pcf_file = common/io.pcf

BUILD_DIR='./build'
SRC_DIR='./src'
SIM_DIR='./sim'

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
	@if [ ! -d '$(SIM_DIR)' ]; \
		then \
		  mkdir $(SIM_DIR) \
	fi
	# add compiling steps for tests and wave form generation

prog_flash: build
	@if [ -d '$(ICELINK_DIR)' ]; \
        then \
            cp $(BUILD_DIR)/$(filename).bin $(ICELINK_DIR); \
        else \
            echo "iCELink not found"; \
            exit 1; \
    fi

clean:
	rm -rf comiled

