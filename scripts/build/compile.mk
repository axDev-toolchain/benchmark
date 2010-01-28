GLOBAL_ANDROID_INCLUDES := $(patsubst %,-I$(android_root)/%,$($(android_branch_cap)_GCC_INCLUDES))
LOCAL_INCLUDES := $(target_local_includes:%=-I %)

LDFLAGS := $(target_local_ldflags)
CFLAGS := $($(android_branch_cap)_C_COMPILE_BASE_FLAGS)
CFLAGS += $(ADD_CFLAGS)
## using asm
ifeq ($(ASM),on)
ifeq ($(COMPILER_TYPE),gcc)
	CFLAGS += -save-temps
endif
endif
LOCAL_CFLAGS := $(target_local_cflags)

LOCAL_STATIC_LIBS := $(target_local_static_libs:%=$(local_out_dir)/%.a)
LOCAL_STATIC_LIBS += $(target_local_android_static_libs:%=$(android_product_path)/%)
LOCAL_SHARED_LIBS := $(if $(target_local_shared_libs),-L$(local_out_dir) $(target_local_shared_libs:lib%=-l%),)
LOCAL_SHARED_LIBS += $(if $(target_local_android_shared_libs),-L$(android_shared_libs) $(target_local_android_shared_libs:lib%=-l%),)
LOCAL_SHARED_LIBS_FILES := $(target_local_shared_libs:%=$(local_out_dir)/%.so)

ALL_LOCAL_FLAGS_PRE := $(COMPILER_SPECIFIC_OPTIONS_PRE) $(GLOBAL_ANDROID_INCLUDES) $(LOCAL_INCLUDES) $(CFLAGS)
ALL_LOCAL_FLAGS_AFR := $(LOCAL_CFLAGS) $(COMPILER_SPECIFIC_OPTIONS_POST)

## Filter out default flags that we don't want
ALL_LOCAL_FLAGS_PRE := $(filter-out $(DISABLE_CFLAGS),$(ALL_LOCAL_FLAGS_PRE))
ALL_LOCAL_FLAGS_AFR := $(filter-out $(DISABLE_CFLAGS),$(ALL_LOCAL_FLAGS_AFR))
DEFAULT_THUMB_OPT := $(filter-out $(DISABLE_CFLAGS),$(DEFAULT_THUMB_OPT))
DEFAULT_ARM_OPT := $(filter-out $(DISABLE_CFLAGS),$(DEFAULT_ARM_OPT))
CPP_COMPILE_PLUS_FLAGS := $(filter-out $(DISABLE_CFLAGS),$(CPP_COMPILE_PLUS_FLAGS))

####################
## compile asm
####################
asm_all_srcs := $(filter %.S,$(target_srcs))

asm_all_objs := $(patsubst %.S,$(local_obj_dir)/%.o,$(asm_all_srcs))

$(asm_all_objs): MY_FLAGS := $(ALL_LOCAL_FLAGS_PRE) $(DEFAULT_THUMB_OPT) $(ALL_LOCAL_FLAGS_AFR)
$(asm_all_objs): $(local_obj_dir)/%.o: $(local_src_dir)/%.S
	$(echo) mkdir -p $(dir ./$@)
	@echo "ASM $@ <= $^"
	$(echo) $(ANDROID_GCC) $(MY_FLAGS) -c -o $@ $^

####################
## compile c
####################
c_arm_srcs := $(patsubst %.arm,%,$(filter %.c.arm,$(target_srcs)))
c_thumb_srcs := $(patsubst %.thumb,%,$(filter %.c.thumb,$(target_srcs)))
c_normal_srcs := $(filter %.c,$(target_srcs))

ifeq ($(COMPILE_MODE),arm)
c_arm_srcs += $(c_normal_srcs)
else
c_thumb_srcs += $(c_normal_srcs)
endif

c_arm_objs := $(patsubst %.c,$(local_obj_dir)/%.o,$(c_arm_srcs))
c_thumb_objs := $(patsubst %.c,$(local_obj_dir)/%.o,$(c_thumb_srcs))

$(c_thumb_objs): MY_FLAGS := $(ALL_LOCAL_FLAGS_PRE) $(DEFAULT_THUMB_OPT) $(ALL_LOCAL_FLAGS_AFR)
$(c_thumb_objs): $(local_obj_dir)/%.o: $(local_src_dir)/%.c
	$(echo) mkdir -p $(dir ./$@)
	@echo "C THUMB $@ <= $^"
	$(echo) $(ANDROID_GCC) $(MY_FLAGS) -c -o $@ $^

$(c_arm_objs): MY_FLAGS := $(ALL_LOCAL_FLAGS_PRE) $(DEFAULT_ARM_OPT) $(ALL_LOCAL_FLAGS_AFR)
$(c_arm_objs): $(local_obj_dir)/%.o: $(local_src_dir)/%.c
	$(echo) mkdir -p $(dir ./$@)
	@echo "C ARM $@ <= $^"
	$(echo) $(ANDROID_GCC) $(MY_FLAGS) -c -o $@ $^

####################
## compile c++
####################
cpp_arm_srcs := $(patsubst %.arm,%,$(filter %.cpp.arm,$(target_srcs)))
cpp_thumb_srcs := $(patsubst %.thumb,%,$(filter %.cpp.thumb,$(target_srcs)))
cpp_normal_srcs := $(filter %.cpp,$(target_srcs))

ifeq ($(COMPILE_MODE),arm)
cpp_arm_srcs += $(cpp_normal_srcs)
else
cpp_thumb_srcs += $(cpp_normal_srcs)
endif

cpp_arm_objs := $(patsubst %.cpp,$(local_obj_dir)/%.o,$(cpp_arm_srcs))
cpp_thumb_objs := $(patsubst %.cpp,$(local_obj_dir)/%.o,$(cpp_thumb_srcs))

$(cpp_thumb_objs): MY_FLAGS := $(ALL_LOCAL_FLAGS_PRE) $(DEFAULT_THUMB_OPT) $(CPP_COMPILE_PLUS_FLAGS) $(ALL_LOCAL_FLAGS_AFR)
$(cpp_thumb_objs): $(local_obj_dir)/%.o: $(local_src_dir)/%.cpp
	$(echo) mkdir -p $(dir ./$@)
	@echo "CPP THUMB $@ <= $^"
	$(echo) $(ANDROID_GXX) $(MY_FLAGS) -c -o $@ $^

$(cpp_arm_objs): MY_FLAGS := $(ALL_LOCAL_FLAGS_PRE) $(DEFAULT_ARM_OPT) $(CPP_COMPILE_PLUS_FLAGS) $(ALL_LOCAL_FLAGS_AFR)
$(cpp_arm_objs): $(local_obj_dir)/%.o: $(local_src_dir)/%.cpp
	$(echo) mkdir -p $(dir ./$@)
	@echo "CPP ARM $@ <= $^"
	$(echo) $(ANDROID_GXX) $(MY_FLAGS) -c -o $@ $^
