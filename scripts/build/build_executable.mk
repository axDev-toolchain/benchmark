local_src_dir := $(if $(target_prefix),$(DIR)/$(src_dir)/$(target_prefix),$(DIR)/$(src_dir))
local_obj_dir := $(if $(target_prefix),$(DIR)/$(obj_dir)/$(target_prefix),$(DIR)/$(obj_dir))
local_out_dir := $(DIR)/$(out_dir)

include $(BUILD)/compile.mk

ifeq ($(COMPILER_TYPE),rvct-win)
$(local_out_dir)/SYMBOL/$(TARGET): MY_LOCAL_SHARED_LIBS := $(LOCAL_SHARED_LIBS)
$(local_out_dir)/SYMBOL/$(TARGET): MY_LOCAL_STATIC_LIBS := $(LOCAL_STATIC_LIBS)
$(local_out_dir)/SYMBOL/$(TARGET): $(c_arm_objs) $(c_thumb_objs) $(cpp_arm_objs) $(cpp_thumb_objs) $(asm_all_objs) $(LOCAL_STATIC_LIBS) $(LOCAL_SHARED_LIBS_FILES)
	@echo "LINK $@"
	$(echo) mkdir -p $(dir $@)
	$(echo) $(ANDROID_LINKER) --search_dynamic_libraries --dynamiclinker=/system/bin/linker \
		$(LDFLAGS) $(ADD_LDFLAGS) \
		--remove -o $@ $(MY_LOCAL_SHARED_LIBS) --userlibpath=$(android_shared_libs) \
		--library=c --library=stdc++ --library=m  $(android_product_path)/obj/lib/crtbegin_dynamic.o \
		$^ $(MY_LOCAL_STATIC_LIBS) $(ANDROID_LIBGCC) \
		$(android_product_path)/obj/lib/crtend_android.o $(EXTRA_COMPILER_LIBS)
else
$(local_out_dir)/SYMBOL/$(TARGET): MY_LOCAL_SHARED_LIBS := $(LOCAL_SHARED_LIBS)
$(local_out_dir)/SYMBOL/$(TARGET): MY_LOCAL_STATIC_LIBS := $(LOCAL_STATIC_LIBS)
$(local_out_dir)/SYMBOL/$(TARGET): $(c_arm_objs) $(c_thumb_objs) $(cpp_arm_objs) $(cpp_thumb_objs) $(asm_all_objs) $(LOCAL_STATIC_LIBS) $(LOCAL_SHARED_LIBS_FILES)
	@echo "LINK $@"
	$(echo) mkdir -p $(dir $@)
	$(echo) $(ANDROID_LINKER) -nostdlib -Bdynamic -Wl,-T,$(android_config_path)/armelf.x \
		$(LDFLAGS) $(ADD_LDFLAGS) \
		-Wl,-dynamic-linker,/system/bin/linker -Wl,--gc-sections \
		-Wl,-z,nocopyreloc -o $@ \
		$(MY_LOCAL_SHARED_LIBS) -L$(android_shared_libs) \
		-Wl,-rpath-link=$(android_shared_libs) -lc -lstdc++ -lm \
		$(android_product_path)/obj/lib/crtbegin_dynamic.o \
		$^ $(MY_LOCAL_STATIC_LIBS) -Wl,--no-undefined \
		-Wl,--fix-cortex-a8 \
		$(ANDROID_LIBGCOV) $(ANDROID_LIBGCC) \
		$(android_product_path)/obj/lib/crtend_android.o \
		$(EXTRA_COMPILER_LIBS)

endif

$(local_out_dir)/$(TARGET): $(local_out_dir)/SYMBOL/$(TARGET)
	@echo "STRIP $@"
	$(echo) $(soslim) --strip --shady --quiet $^ --outfile $@

bench_targets += $(TARGET)
