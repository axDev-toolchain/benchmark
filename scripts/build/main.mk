# guard agains using makefile directly
default:
	@echo "No default target here"

# Figure out where we are.
define my-dir
$(patsubst %/,%,$(dir $(lastword $(MAKEFILE_LIST),$(MAKEFILE_LIST))))
endef

# setup paths
BUILD := $(call my-dir)
ROOT := $(BUILD)/../..

# setup build options / environment

# default versions of command line options:
COMPILE_MODE = thumb
ANDROID_BRANCH = eclair
TOOLCHAIN =
BUILD_TARGET = bench
MUTE = on
ASM =

include $(BUILD)/bench_defaults.mk

# parse options
include $(BUILD)/common.mk

# find out which compiler suite to use
include $(BUILD)/compilers.mk

# include benchmark description
include bench.mk

# global targets

info: echo := @echo
info: build

ifeq ($(BUILD_TARGET),bench)
build: $(lib_targets:%=$(local_out_dir)/%) $(bench_targets:%=$(local_out_dir)/%)
else
build: $(bench_targets:%=$(local_out_dir)/%)
endif

clean:
	@echo CLEAN
	$(echo) rm -rf $(out_dir) $(obj_dir)

so_targets = $(filter %.so,$(lib_targets))

export:
	@echo $(so_targets:%=$(local_out_dir)/%) $(bench_targets:%=$(local_out_dir)/%)

runcmd:
	@echo '$(GET_TIME); $(run_cmd); $(GET_TIME)'

getsize:
	@echo $(local_out_dir)/$(get_which_size)
