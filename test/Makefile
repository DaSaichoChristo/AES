SRC_DIR = $(PWD)/../src/
SIM_DIR = $(PWD)/../sim/

SIM_BUILD ?= ../sim/$(TOPLEVEL)

# The simulator we want to run our tests with.
SIM ?= icarus

# The top-level language of the design (verilog or vhdl).
TOPLEVEL_LANG ?= verilog

# List of Verilog source files.
VERILOG_SOURCES = $(wildcard $(SRC_DIR)/*.v)
VERILOG_SOURCES += $(shell which iverilog | xargs dirname)/../share/yosys/ice40/cells_sim.v

# The name of the toplevel module/entity in your design.
TOPLEVEL ?= top

# The Python modules which contain your testcases.
COCOTB_TEST_MODULES := $(basename $(wildcard *.py))

# Enable waveform generation.
WAVES = 1

# Includes cocotb's Makefiles which define the build and simulation flows for each supported simulator.
# This must be included *after* all of the variables above are defined.
include $(shell cocotb-config --makefiles)/Makefile.sim
