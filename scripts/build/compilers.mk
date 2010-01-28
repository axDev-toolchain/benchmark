#
# This file defines paths and compilation options for compilers
# This file is to be included from main.mk
# input vars:
#    TOOLCHAIN -- toolchain to be used
#

############################################################
# Set up toolchain paths, compiler options.
############################################################

ifneq ($(TOOLCHAIN),)
  TOOLCHAIN_PREFIX := $(TOOLCHAIN)
else
  TOOLCHAIN_PREFIX := $(android_root)/prebuilt/linux-x86/toolchain/arm-eabi-4.4.0
endif

ANDROID_GCC_PATH := $(TOOLCHAIN_PREFIX)/bin

COMPILER_TYPE := unknown
ifneq ($(shell uname | grep 'CYGWIN'),)
  COMPILER_TYPE := rvct-win
else
  ifneq ($(shell $(TOOLCHAIN_PREFIX)/bin/arm-eabi-gcc --vsn 2>&1 | grep 'ARM C'),)
    COMPILER_TYPE := rvct
  endif
  ifneq ($(shell $(TOOLCHAIN_PREFIX)/bin/arm-eabi-gcc -v 2>&1 | grep 'gcc'),)
    COMPILER_TYPE := gcc
  endif
  ifneq ($(shell $(TOOLCHAIN_PREFIX)/bin/arm-eabi-gcc -v 2>&1 | grep 'RVCT'),)
    COMPILER_TYPE = rvct
  endif
endif

ifeq ($(COMPILER_TYPE),unknown)
$(error "Unsupported compiler. Supported compilers are: gcc and rcvt")
endif

ANDROID_GCC := $(ANDROID_GCC_PATH)/arm-eabi-gcc
ANDROID_GXX := $(ANDROID_GCC_PATH)/arm-eabi-g++
ANDROID_AR  := $(ANDROID_GCC_PATH)/arm-eabi-ar

ifeq ($(COMPILER_TYPE),gcc)
    AR_MAKE_ARCHIVE_FLAGS := crs
    ANDROID_LINKER := $(ANDROID_GCC_PATH)/arm-eabi-g++
    COMPILER_SPECIFIC_OPTIONS_PRE :=
    COMPILER_SPECIFIC_OPTIONS_POST :=
    EXTRA_COMPILER_LIBS :=
    ANDROID_LIBGCC :=
    OPTIMIZATION :=
else ifeq ($(COMPILER_TYPE),rvct)
    AR_MAKE_ARCHIVE_FLAGS := --create -rs
    ANDROID_LINKER := $(ANDROID_GCC_PATH)/arm-eabi-ld
    ARMCC_INCLUDES := $(TOOLCHAIN_PREFIX)/include
    COMPILER_SPECIFIC_OPTIONS_PRE := --arm_linux --arm_linux_config_file=$(TOOLCHAIN_PREFIX)/rvct.cfg --translate_gcc
    COMPILER_SPECIFIC_OPTIONS_POST := -I$(ARMCC_INCLUDES)
    EXTRA_COMPILER_LIBS := $(TOOLCHAIN_PREFIX)/lib/libcxxabi-hack.a
    ANDROID_LIBGCC :=
    OPTIMIZATION := -O3 -Ospace
else ifeq ($(COMPILER_TYPE),rvct-win)
    ANDROID_GCC := armcc
    ANDROID_GXX := armcc
    ANDROID_AR := armar
    ANDROID_LINKER := armlink --entry=_start --arm_linux --sysv
    AR_MAKE_ARCHIVE_FLAGS := -r
    COMPILER_SPECIFIC_OPTIONS_PRE :=
    COMPILER_SPECIFIC_OPTIONS_POST :=
    EXTRA_COMPILER_LIBS :=
    ANDROID_LIBGCC := $(ROOT)/android_build/arm_linux/libgcc.a
    OPTIMIZATION := -O3 -Ospace
endif

######### common  ###############
ifeq ($(COMPILER_TYPE),rvct-win)
  DEFAULT_ARM_OPT = --arm --arm_linux --asm --interleave --no_debug
  DEFAULT_THUMB_OPT = --thumb --arm_linux --asm --interleave --no_debug
  CPP_COMPILE_PLUS_FLAGS = --cpp --no_rtti
else
  DEFAULT_ARM_OPT = -O2 -fomit-frame-pointer -fstrict-aliasing \
		    -funswitch-loops -finline-limit=300
  DEFAULT_THUMB_OPT = -mthumb -Os -fomit-frame-pointer -fno-strict-aliasing \
		      -finline-limit=64
  CPP_COMPILE_PLUS_FLAGS = -fvisibility-inlines-hidden -fno-rtti
endif

######### find libgcc.a for gcc ###########
ECLAIR_GCC_GLOBAL_CFLAGS := -fno-exceptions -Wno-multichar \
                            -msoft-float -fpic -ffunction-sections \
                            -funwind-tables -fstack-protector \
                            -fno-short-enums \
                            -march=armv7-a -mfloat-abi=softfp -mfpu=neon \
                            -include $(android_root)/system/core/include/arch/linux-arm/AndroidConfig.h \
                            -I $(android_root)/system/core/include/arch/linux-arm/ \
                            -mthumb-interwork
ANDROID_LIBGCOV :=
ifeq ($(ANDROID_LIBGCC),)
  ANDROID_LIBGCC = $(shell $(ANDROID_GCC) $(ECLAIR_GCC_GLOBAL_CFLAGS) -print-libgcc-file-name)
  ifeq ($(FDO_BUILD),1)
    ANDROID_LIBGCOV = $(shell $(ANDROID_GCC) $(ECLAIR_GCC_GLOBAL_CFLAGS) --print-file-name=libgcov.a)
  endif
endif

######### eclair  ###############
ECLAIR_GCC_INCLUDES = \
system/core/include\
hardware/libhardware/include \
hardware/libhardware_legacy/include \
hardware/ril/include \
dalvik/libnativehelper/include \
frameworks/base/include \
frameworks/base/opengl/include \
external/skia/include \
out/target/product/passion/obj/include \
bionic/libc/arch-arm/include \
bionic/libc/include \
bionic/libstdc++/include \
bionic/libc/kernel/common \
bionic/libc/kernel/arch-arm \
bionic/libm/include \
bionic/libm/include/arch/arm \
bionic/libthread_db/include

ifeq ($(COMPILER_TYPE),rvct-win)
  ECLAIR_GCC_INCLUDES := ../arm_linux $(ECLAIR_GCC_INCLUDES)
  ECLAIR_C_COMPILE_BASE_FLAGS := --split_sections -O3 -Ospace --apcs=/fpic \
	      --cpu=Cortex-A8 -D__ARM_ARCH_7A__ -D_STANDALONE -DANDROID -W \
--preinclude=$(android_root)/system/core/include/arch/linux-arm/AndroidConfig.h
else
  ECLAIR_C_COMPILE_BASE_FLAGS := $(ECLAIR_GCC_GLOBAL_CFLAGS) \
				 -DANDROID -fmessage-length=0 -W -Wall \
				 -Wno-unused -Winit-self -Wpointer-arith \
				 -Werror=return-type -Werror=non-virtual-dtor \
				 -Werror=address -Werror=sequence-point \
				 -DSK_RELEASE -DNDEBUG \
				 -g -Wstrict-aliasing=2 \
				 -finline-functions \
				 -fno-inline-functions-called-once \
				 -fgcse-after-reload -frerun-cse-after-loop \
				 -frename-registers \
				 -DNDEBUG -UDEBUG \
  				 $(OPTIMIZATION) -MD
endif
