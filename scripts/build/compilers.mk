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
else ifneq ($(shell $(TOOLCHAIN_PREFIX)/i686-pc-linux-gnu-g++ -v 2>&1 | grep '9999'),)
  # chromeOS - search for correct driver name.
  COMPILER_TYPE := chromeos-gcc
else
  ifneq ($(shell $(TOOLCHAIN_PREFIX)/bin/arm-eabi-gcc --vsn 2>&1 | grep 'ARM C'),)
    COMPILER_TYPE := rvct
  endif
  ifneq ($(shell $(TOOLCHAIN_PREFIX)/bin/arm-eabi-gcc -v 2>&1 | grep 'gcc'),)
    COMPILER_TYPE := gcc
    LINKER := $(ANDROID_GCC_PATH)/arm-eabi-g++
  endif
  ifneq ($(shell $(TOOLCHAIN_PREFIX)/bin/arm-eabi-gcc -v 2>&1 | grep 'RVCT'),)
    COMPILER_TYPE = rvct
  endif
  ifneq ($(shell which armcc | grep 'armcc'),)
    COMPILER_TYPE = rvct
  endif
  ifneq ($(shell ls $(TOOLCHAIN_PREFIX)/bin 2>&1 | grep 'arm-linux-androideabi'),)
    COMPILER_TYPE := gcc
    CC := $(ANDROID_GCC_PATH)/arm-linux-androideabi-gcc
    CXX := $(ANDROID_GCC_PATH)/arm-linux-androideabi-g++
    AR  := $(ANDROID_GCC_PATH)/arm-linux-androideabi-ar
    LINKER := $(ANDROID_GCC_PATH)/arm-linux-androideabi-g++
  else
    CC := $(ANDROID_GCC_PATH)/arm-eabi-gcc
    CXX := $(ANDROID_GCC_PATH)/arm-eabi-g++
    AR  := $(ANDROID_GCC_PATH)/arm-eabi-ar
  endif
endif

ifeq ($(COMPILER_TYPE),unknown)
$(error "Unsupported compiler. Supported compilers are: gcc and rcvt")
endif

ifeq ($(COMPILER_TYPE),gcc)
    AR_MAKE_ARCHIVE_FLAGS := crs
    COMPILER_SPECIFIC_OPTIONS_PRE :=
    COMPILER_SPECIFIC_OPTIONS_POST :=
    EXTRA_COMPILER_LIBS :=
    ANDROID_LIBGCC :=
    OPTIMIZATION :=
else ifeq ($(COMPILER_TYPE),rvct)
    CC := armcc
    CXX := armcc
    AR := armar
    AR_MAKE_ARCHIVE_FLAGS := -r
    LINKER := armlink --entry=_start --arm_linux --sysv
    COMPILER_SPECIFIC_OPTIONS_PRE :=
    COMPILER_SPECIFIC_OPTIONS_POST :=
    EXTRA_COMPILER_LIBS :=
    ANDROID_LIBGCC := $(ROOT)/android_build/arm_linux/libgcc.a
    OPTIMIZATION := -O3 -Ospace
else ifeq ($(COMPILER_TYPE),rvct-win)
    CC := armcc
    CXX := armcc
    AR := armar
    LINKER := armlink --entry=_start --arm_linux --sysv
    AR_MAKE_ARCHIVE_FLAGS := -r
    COMPILER_SPECIFIC_OPTIONS_PRE :=
    COMPILER_SPECIFIC_OPTIONS_POST :=
    EXTRA_COMPILER_LIBS :=
    ANDROID_LIBGCC := $(ROOT)/android_build/arm_linux/libgcc.a
    OPTIMIZATION := -O3 -Ospace
else ifeq ($(COMPILER_TYPE),chromeos-gcc)
    CC := $(TOOLCHAIN_PREFIX)/i686-pc-linux-gnu-gcc
    CXX := $(TOOLCHAIN_PREFIX)/i686-pc-linux-gnu-g++
    AR := $(TOOLCHAIN_PREFIX)/i686-pc-linux-gnu-ar
    LINKER  := $(TOOLCHAIN_PREFIX)/i686-pc-linux-gnu-g++
    EXTRA_COMPILER_LIBS :=
    COMPILER_SPECIFIC_OPTIONS_PRE := 
    COMPILER_SPECIFIC_OPTIONS_POST :=
    ANDROID_LIBGCC :=
    OPTIMIZATION :=
endif

######### common  ###############
ifeq ($(COMPILER_TYPE),rvct-win)
  DEFAULT_ARM_OPT = --arm --arm_linux --asm --interleave --no_debug
  DEFAULT_THUMB_OPT = --thumb --arm_linux --asm --interleave --no_debug
  CPP_COMPILE_PLUS_FLAGS = --cpp --no_rtti
else ifeq ($(COMPILER_TYPE),rvct)
  DEFAULT_ARM_OPT = --arm --arm_linux --asm --interleave --no_debug
  DEFAULT_THUMB_OPT = --thumb --arm_linux --asm --interleave --no_debug
  CPP_COMPILE_PLUS_FLAGS = --cpp --no_rtti
else ifeq ($(COMPILER_TYPE),chromeos-gcc)
  DEFAULT_ARM_OPT = 
  DEFAULT_THUMB_OPT = 
  CPP_COMPILE_PLUS_FLAGS =
else
  DEFAULT_ARM_OPT = -O2 -fomit-frame-pointer -fstrict-aliasing \
		    -funswitch-loops -finline-limit=300
  DEFAULT_THUMB_OPT = -mthumb -Os -fomit-frame-pointer -fno-strict-aliasing \
		      -finline-limit=64
  CPP_COMPILE_PLUS_FLAGS = -fvisibility-inlines-hidden -fno-rtti
endif

######### find libgcc.a for gcc ###########
ifeq ($(COMPILER_TYPE),chromeos-gcc)
  ECLAIR_GCC_GLOBAL_CFLAGS :=
else
  ECLAIR_GCC_GLOBAL_CFLAGS := -fno-exceptions -Wno-multichar \
                            -fpic -ffunction-sections \
                            -funwind-tables -fstack-protector \
                            -fno-short-enums \
                            -march=armv7-a -mfloat-abi=softfp -mfpu=neon \
                            -include $(android_root)/system/core/include/arch/linux-arm/AndroidConfig.h \
                            -I $(android_root)/system/core/include/arch/linux-arm/ \
                            -mthumb-interwork
endif
ANDROID_LIBGCOV :=
ifeq ($(ANDROID_LIBGCC),)
  ANDROID_LIBGCC = $(shell $(CC) $(ECLAIR_GCC_GLOBAL_CFLAGS) -print-libgcc-file-name)
  ifeq ($(FDO_BUILD),1)
    ANDROID_LIBGCOV = $(shell $(CC) $(ECLAIR_GCC_GLOBAL_CFLAGS) --print-file-name=libgcov.a)
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
	      -DNDEBUG -UDEBUG \
--preinclude=$(android_root)/system/core/include/arch/linux-arm/AndroidConfig.h
else ifeq ($(COMPILER_TYPE),rvct)
  ECLAIR_GCC_INCLUDES := ../arm_linux $(ECLAIR_GCC_INCLUDES)
  ECLAIR_C_COMPILE_BASE_FLAGS := --split_sections -O3 -Ospace --apcs=/fpic \
	      --cpu=Cortex-A8 -D__ARM_ARCH_7A__ -D_STANDALONE -DANDROID -W \
	      -DNDEBUG -UDEBUG \
--preinclude=$(android_root)/system/core/include/arch/linux-arm/AndroidConfig.h
else ifeq ($(COMPILER_TYPE),chromeos-gcc)
  ANDROID_ECLAIR_ROOT :=
  ECLAIR_C_COMPILE_BASE_FLAGS :=
else
  ECLAIR_C_COMPILE_BASE_FLAGS := $(ECLAIR_GCC_GLOBAL_CFLAGS) \
				 -DANDROID -fmessage-length=0 -W -Wall \
				 -Wno-unused -Winit-self -Wpointer-arith \
				 -Werror=return-type -Werror=non-virtual-dtor \
				 -Werror=address -Werror=sequence-point \
				 -DSK_RELEASE \
				 -g -Wstrict-aliasing=2 \
				 -finline-functions \
				 -fno-inline-functions-called-once \
				 -fgcse-after-reload -frerun-cse-after-loop \
				 -frename-registers \
				 -DNDEBUG -UDEBUG \
  				 $(OPTIMIZATION) -MD
endif
