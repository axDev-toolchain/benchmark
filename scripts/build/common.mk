obj_dir = obj
src_dir = src
out_dir = out

ADD_CFLAGS :=
ADD_LDFLAGS :=
DISABLE_CFLAGS :=
FDO_BUILD :=

## using android_root/branch
android_branch_cap := $(shell echo $(ANDROID_BRANCH) | tr '[a-z]' '[A-Z]')
android_root := $(ANDROID_$(android_branch_cap)_ROOT)

android_config_path := $(android_root)/$($(android_branch_cap)_CONFIG_PATH)
android_shared_libs := $(android_root)/$($(android_branch_cap)_SHARED_LIBS)
android_product_path := $(android_root)/$($(android_branch_cap)_PRODUCT_PATH)

soslim := $(android_root)/$(ANDROID_TOOLS_PATH)/soslim
apriori := $(android_root)/$(ANDROID_TOOLS_PATH)/apriori

# build target
ifeq ($(BUILD_TARGET),bench)
build_what = $(bench_targets)
else
build_what = $(lib_targets)
endif

# mute
echo =
ifeq ($(MUTE),on)
echo = @
endif

bench_targets :=
lib_targets :=

SKIP_PRELINKING :=
