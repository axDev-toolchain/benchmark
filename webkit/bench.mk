DIR:=$(call my-dir)

#### webkit ####

# Which file we measure the size
get_which_size = libwebcore.so

# Running commands
run_cmd = LD_LIBRARY_PATH=${PERFLAB_PATH} ${PERFLAB_PATH}/webkit_bench -d800x2400 -r40 file://${PERFLAB_INPUT}/cnn.html

#####################################
include $(BUILD)/clear.mk
TARGET := libwebcore.a
#####################################

target_srcs :=
webkit_srcs :=

# Use jsc as JS engine
# Include source files for WebCore
d := WebCore
LOCAL_PATH := $d
ENABLE_SVG := false
include src/WebCore/Android.mk
JAVASCRIPTCORE_PATH := JavaScriptCore
base_intermediates := intermediates
intermediates := $(base_intermediates)/WebCore
include src/WebCore/Android.jscbindings.mk
webkit_srcs += $(addprefix $d/,$(LOCAL_SRC_FILES))
target_local_includes := $(addprefix src/,$(BINDING_C_INCLUDES))

# Include the derived source files for WebCore. Uses the same path as
# WebCore.
# Derived codes are recorded in LOCAL_GENERATED_SOURCES.
include src/WebCore/bench.derived.mk 
include src/WebCore/bench.derived.jscbindings.mk

# Include source files for android WebKit port
d := WebKit
LOCAL_PATH := $d
intermediates := $(base_intermediates)/WebKit
include src/WebKit/Android.mk
webkit_srcs += $(addprefix $d/,$(LOCAL_SRC_FILES))

# Define our compiler flags
ifeq ($(COMPILER_TYPE),rvct-win)
target_local_cflags := --preinclude="WebCorePrefix.h" -Darm
else
target_local_cflags := -Wno-endif-labels -Wno-import -Wno-format \
	-fno-strict-aliasing -include "WebCorePrefix.h" \
	-fvisibility=hidden -Wno-psabi -Darm
endif

# Build our list of include paths. We include WebKit/android/icu first so that
# any files that include <unicode/ucnv.h> will include our ucnv.h first. We
# also add external/ as an include directory so that we can specify the real
# icu header directory as a more exact reference to avoid including our ucnv.h.
#
# Note that JavasCriptCore/ must be included after WebCore/, so that we pick up
# the right config.h.
target_local_includes := $(target_local_includes) \
	$(android_root)/dalvik/libnativehelper/include/nativehelper \
	src/WebKit/android/icu \
	$(android_root)/external/ \
        $(android_root)/external/icu4c/common \
        $(android_root)/external/icu4c/i18n \
        $(android_root)/external/libxml2/include \
        $(android_root)/external/skia/emoji \
        $(android_root)/external/skia/include/core \
        $(android_root)/external/skia/include/effects \
        $(android_root)/external/skia/include/images \
        $(android_root)/external/skia/include/ports \
        $(android_root)/external/skia/include/utils \
        $(android_root)/external/skia/src/ports \
        $(android_root)/external/sqlite/dist \
        $(android_root)/frameworks/base/core/jni/android/graphics


LOCAL_PATH := src
target_local_includes := $(target_local_includes) \
        $(LOCAL_PATH)/WebCore \
        $(LOCAL_PATH)/WebCore/accessibility \
        $(LOCAL_PATH)/WebCore/css \
        $(LOCAL_PATH)/WebCore/dom \
        $(LOCAL_PATH)/WebCore/editing \
        $(LOCAL_PATH)/WebCore/history \
        $(LOCAL_PATH)/WebCore/history/android \
        $(LOCAL_PATH)/WebCore/html \
        $(LOCAL_PATH)/WebCore/html/canvas \
        $(LOCAL_PATH)/WebCore/inspector \
        $(LOCAL_PATH)/WebCore/loader \
        $(LOCAL_PATH)/WebCore/loader/appcache \
        $(LOCAL_PATH)/WebCore/loader/icon \
        $(LOCAL_PATH)/WebCore/notifications \
        $(LOCAL_PATH)/WebCore/page \
        $(LOCAL_PATH)/WebCore/page/android \
        $(LOCAL_PATH)/WebCore/page/animation \
        $(LOCAL_PATH)/WebCore/platform \
        $(LOCAL_PATH)/WebCore/platform/android \
        $(LOCAL_PATH)/WebCore/platform/animation \
        $(LOCAL_PATH)/WebCore/platform/graphics \
        $(LOCAL_PATH)/WebCore/platform/graphics/android \
        $(LOCAL_PATH)/WebCore/platform/graphics/network \
        $(LOCAL_PATH)/WebCore/platform/graphics/skia \
        $(LOCAL_PATH)/WebCore/platform/graphics/transforms \
        $(LOCAL_PATH)/WebCore/platform/image-decoders \
        $(LOCAL_PATH)/WebCore/platform/mock \
        $(LOCAL_PATH)/WebCore/platform/network \
        $(LOCAL_PATH)/WebCore/platform/network/android \
        $(LOCAL_PATH)/WebCore/platform/sql \
        $(LOCAL_PATH)/WebCore/platform/text \
        $(LOCAL_PATH)/WebCore/plugins \
        $(LOCAL_PATH)/WebCore/plugins/android \
        $(LOCAL_PATH)/WebCore/rendering \
        $(LOCAL_PATH)/WebCore/rendering/style \
        $(LOCAL_PATH)/WebCore/storage \
        $(LOCAL_PATH)/WebCore/workers \
        $(LOCAL_PATH)/WebCore/xml

target_local_includes := $(target_local_includes) \
        $(LOCAL_PATH)/WebKit/android \
        $(LOCAL_PATH)/WebKit/android/WebCoreSupport \
        $(LOCAL_PATH)/WebKit/android/jni \
        $(LOCAL_PATH)/WebKit/android/nav \
        $(LOCAL_PATH)/WebKit/android/plugins \
        $(LOCAL_PATH)/WebKit/android/stl

target_local_includes := $(target_local_includes) \
        $(LOCAL_PATH)/JavaScriptCore \
        $(LOCAL_PATH)/JavaScriptCore/wtf \
        $(LOCAL_PATH)/JavaScriptCore/wtf/unicode \
        $(LOCAL_PATH)/JavaScriptCore/wtf/unicode/icu

target_local_includes := $(target_local_includes) \
        src/$(base_intermediates)/WebCore/ \
        src/$(base_intermediates)/WebCore/css \
        src/$(base_intermediates)/WebCore/html \
        src/$(base_intermediates)/WebCore/platform

target_local_includes := $(target_local_includes) \
	src \
	src/$(base_intermediates)

target_local_android_shared_libs := \
        libandroid_runtime \
        libnativehelper \
        libsqlite \
        libskia \
        libutils \
        libui \
        libcutils \
        libicuuc \
        libicudata \
        libicui18n \
        libmedia \
	libdl

target_local_android_static_libs = \
	obj/STATIC_LIBRARIES/libxml2_intermediates/libxml2.a

target_srcs := $(webkit_srcs) $(LOCAL_GENERATED_SOURCES)

# Define this for use in other makefiles.
WEBKIT_C_INCLUDES := $(target_local_includes)
WEBKIT_CFLAGS := $(target_local_cflags)
WEBKIT_GENERATED_SOURCES := $(LOCAL_GENERATED_SOURCES)
WEBKIT_SHARED_LIBRARIES := $(target_local_android_shared_libs)
WEBKIT_STATIC_LIBRARIES := $(target_local_android_static_libs)

include $(BUILD)/build_library.mk


#####################################
include $(BUILD)/clear.mk
TARGET := libjs.a
#####################################

target_local_android_shared_libs := $(WEBKIT_SHARED_LIBRARIES)
target_local_android_static_libs := $(WEBKIT_STATIC_LIBRARIES)
target_local_cflags := $(WEBKIT_CFLAGS)
# Include source files for JavaScriptCore
d := JavaScriptCore
LOCAL_PATH := $d
base_intermediates := intermediates
intermediates := $(base_intermediates)/$d
LOCAL_GENERATED_SOURCES :=
include src/JavaScriptCore/bench.mk
# Redefine LOCAL_SRC_FILES with the correct prefix
target_srcs := $(addprefix $d/,$(LOCAL_SRC_FILES)) $(LOCAL_GENERATED_SOURCES)

# Append jsc intermediate include paths to the WebKit include list.
target_local_includes := $(WEBKIT_C_INCLUDES) \
	src/$(intermediates) \
        src/$(intermediates)/parser \
        src/$(intermediates)/runtime \

include $(BUILD)/build_library.mk


#####################################
include $(BUILD)/clear.mk
TARGET := libwebcore.so
#####################################

target_local_android_shared_libs := $(WEBKIT_SHARED_LIBRARIES)
target_local_android_static_libs := $(WEBKIT_STATIC_LIBRARIES)
target_local_static_libs := libwebcore libjs
target_local_ldflags := -fvisibility=hidden
target_local_cflags := $(WEBKIT_CFLAGS)
target_local_includes := $(WEBKIT_C_INCLUDES)

target_srcs := \
	WebKit/android/jni/WebCoreJniOnLoad.cpp

libwebcore.so: $(filter %.h, $(WEBKIT_GENERATED_SOURCES))

include $(BUILD)/build_library.mk


#####################################
#include $(BUILD)/clear.mk
TARGET := webkit_bench
#####################################

target_srcs := \
	WebKit/android/benchmark/main.cpp

target_local_android_shared_libs := $(WEBKIT_SHARED_LIBRARIES)
target_local_shared_libs := libwebcore

include $(BUILD)/build_executable.mk
