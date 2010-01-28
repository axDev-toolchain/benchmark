### Description for skia benchmark ###
DIR := $(call my-dir)

# Which file we measure the size
get_which_size=skia_bench

# Running commands
run_cmd=${PERFLAB_PATH}/skia_bench -repeat 15

all_local_includes := src/include/config \
	src/include/core \
	src/include/effects \
	src/include/images \
	src/include/utils \
	src/src/core

all_local_includes := $(all_local_includes) \
  $(android_root)/external/freetype/include \
  $(android_root)/external/zlib \
  $(android_root)/external/libpng \
  $(android_root)/external/jpeg

all_cflags := -D__ARM_HAVE_NEON -DSK_RELEASE -DSK_SCALAR_IS_FLOAT \
	 -DSK_CAN_USE_FLOAT -DSK_BUILD_FOR_UNIX

##### target = skia.a ######
include $(BUILD)/clear.mk
TARGET = libskia.a
############################

# start with the core (required)
include src/src/core/core_files.mk
SRC_LIST := $(addprefix src/core/, $(SOURCE))

# add the opts (optimizations)
SRC_LIST += src/opts/SkBlitRow_opts_arm.cpp \
	    src/opts/SkBitmapProcState_opts_arm.cpp

# we usually need ports
#include src/src/ports/ports_files.mk
SOURCE := SkDebug_stdio.cpp \
	SkGlobals_global.cpp \
	SkOSFile_stdio.cpp \
	SkTime_Unix.cpp 
#	SkThread_pthread.cpp
SRC_LIST += $(addprefix src/ports/, $(SOURCE))

# do we want effects?
include src/src/effects/effects_files.mk
SRC_LIST += $(addprefix src/effects/, $(SOURCE))

# core image files
include src/src/images/images_files.mk
SRC_LIST += $(addprefix src/images/, $(SOURCE))

# core util files
include src/src/utils/utils_files.mk
SRC_LIST += $(addprefix src/utils/, $(SOURCE))

# extra files we want to build to prevent bit-rot, but not link
#JUST_COMPILE_LIST := src/ports/SkFontHost_tables.cpp
SRC_LIST += src/ports/SkFontHost_tables.cpp

# freetype support
SRC_LIST += src/ports/SkFontHost_linux.cpp \
	 src/ports/SkFontHost_gamma_none.cpp \
	 src/ports/SkFontHost_FreeType.cpp \
	 src/ports/SkFontHost_FreeType_Subpixel.cpp \
	 src/utils/SkOSFile.cpp
   # these are our registry-based factories
	SRC_LIST += src/images/SkImageDecoder_Factory.cpp
	SRC_LIST += src/images/SkImageEncoder_Factory.cpp
   # support files
	SRC_LIST += src/images/SkScaledBitmapSampler.cpp

target_prefix :=
target_srcs := $(addsuffix .arm,$(SRC_LIST))
target_local_includes := $(all_local_includes)

target_local_cflags := $(all_cflags)

target_local_android_static_libs :=
target_local_android_shared_libs :=

include $(BUILD)/build_library.mk

###### target = skia_bench ####
include $(BUILD)/clear.mk
TARGET := skia_bench
###############################

target_srcs := bench/RectBench.cpp.arm \
	bench/SkBenchmark.cpp.arm \
	bench/benchmain.cpp.arm \
	bench/BitmapBench.cpp.arm \
	bench/RepeatTileBench.cpp.arm \
	bench/DecodeBench.cpp.arm \
	src/images/SkImageDecoder_libpng.cpp.arm

target_prefix :=
target_local_includes := $(all_local_includes)
target_local_cflags := $(all_cflags)
target_local_android_shared_libs := libcutils libutils libz
target_local_android_static_libs := \
   obj/STATIC_LIBRARIES/libpng_intermediates/libpng.a \
   obj/STATIC_LIBRARIES/libft2_intermediates/libft2.a
target_local_static_libs := libskia
target_local_shared_libs :=

include $(BUILD)/build_executable.mk
