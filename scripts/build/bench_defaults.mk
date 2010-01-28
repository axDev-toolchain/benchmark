############################################################
# Paths to Android prebuilt libraries and headers.
############################################################
ANDROID_ECLAIR_ROOT = $(ROOT)/android_build/eclair

############################################################
# Tools and rules to run the benchmark.
############################################################
PERFLAB_PATH = /data/local/perflab
PERFLAB_INPUT = /sdcard/perflab_input
GET_TIME = echo Android_TIME_STAMP_$$(timestamp)

############################################################
# common Android build paths
############################################################
ANDROID_TOOLS_PATH = out/host/linux-x86/bin

############################################################
# ECLAIR build paths
############################################################
ECLAIR_CONFIG_PATH = build/core
ECLAIR_PRODUCT_PATH = out/target/product/passion
ECLAIR_SHARED_LIBS = $(ECLAIR_PRODUCT_PATH)/obj/lib
