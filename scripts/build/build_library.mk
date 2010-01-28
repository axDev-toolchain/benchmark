local_src_dir := $(if $(target_prefix),$(DIR)/$(src_dir)/$(target_prefix),$(DIR)/$(src_dir))
local_obj_dir := $(if $(target_prefix),$(DIR)/$(obj_dir)/$(target_prefix),$(DIR)/$(obj_dir))
local_out_dir := $(DIR)/$(out_dir)

include $(BUILD)/compile.mk

ifeq ($(findstring .so,$(TARGET)),.so)
$(local_obj_dir)/$(TARGET): MY_LOCAL_STATIC_LIBS := $(LOCAL_STATIC_LIBS)
$(local_obj_dir)/$(TARGET): MY_LOCAL_SHARED_LIBS := $(LOCAL_SHARED_LIBS)
$(local_obj_dir)/$(TARGET): MY_SONAME := $(TARGET)
$(local_obj_dir)/$(TARGET): $(c_arm_objs) $(c_thumb_objs) $(cpp_arm_objs) $(cpp_thumb_objs) $(asm_all_objs) $(LOCAL_STATIC_LIBS) $(LOCAL_SHARED_LIBS_FILES)
	@echo "LINK SHARED LIBRARY: $@"
	$(echo) mkdir -p $(dir $@)
	$(echo) $(ANDROID_LINKER) -nostdlib -Wl,-soname,$(MY_SONAME) \
		$(LDFLAGS) $(ADD_LDFLAGS) \
		-Wl,-T,$(android_config_path)/armelf.xsc \
		-Wl,--gc-sections -Wl,-shared,-Bsymbolic $^ \
		-Wl,--whole-archive -Wl,--no-whole-archive \
	    	$(MY_LOCAL_STATIC_LIBS) $(MY_LOCAL_SHARED_LIBS) \
	    	-lc -lstdc++ -lm -o $@ \
		-Wl,--no-undefined -Wl,--fix-cortex-a8 \
		$(ANDROID_LIBGCOV) $(ANDROID_LIBGCC)

ifeq ($(SKIP_PRELINKING),)
$(local_out_dir)/SYMBOL/$(TARGET): $(local_obj_dir)/$(TARGET)
	$(echo) mkdir -p $(dir $@)
	@echo "MAP SHARED LIBRARY: $@"
	$(echo) $(apriori) --prelinkmap $(android_config_path)/prelink-linux-arm.map \
	--locals-only --quiet $^ --output $@
else
$(local_out_dir)/SYMBOL/$(TARGET): $(local_obj_dir)/$(TARGET)
	$(echo) mkdir -p $(dir $@)
	@echo "MAP SHARED LIBRARY: $@ -- skipped"
	$(echo) cp $^ $@
endif

$(local_out_dir)/$(TARGET): $(local_out_dir)/SYMBOL/$(TARGET)
	@echo "STRIP $@"
	$(echo) $(soslim) --strip --shady --quiet $^ --outfile $@

else
$(local_out_dir)/$(TARGET): $(c_arm_objs) $(c_thumb_objs) $(cpp_arm_objs) $(cpp_thumb_objs) $(asm_all_objs)
	@echo "LINK STATIC: $@"
	$(echo) mkdir -p $(dir $@)
	$(echo) $(ANDROID_AR) $(AR_MAKE_ARCHIVE_FLAGS) $@ $^

endif

lib_targets += $(TARGET)
