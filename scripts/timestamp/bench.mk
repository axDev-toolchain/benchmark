### Description for timestamp ###
DIR:=$(call my-dir)

# Which file we measure the size
get_which_size =

# Running commands
run_cmd := timestamp


#######################################
include $(BUILD)/clear.mk
TARGET = timestamp
#######################################
target_srcs = timestamp.c

target_prefix =
target_local_includes =

# android including path only work for cupcake
target_local_android_includes = 
target_local_cflags =

target_local_android_static_libs = 
target_local_android_shared_libs = 

target_local_static_libs = 
target_local_shared_libs = 

include $(BUILD)/build_executable.mk
