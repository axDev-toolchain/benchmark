#### gcstone ####
DIR:=$(call my-dir)

# Which file we measure the size
get_which_size=libdvm.so

# Running commands
run_cmd=dalvikvm -cp ${PERFLAB_INPUT}/MemBench_dex.jar MemBench

#####################################
include $(BUILD)/clear.mk
TARGET := libdex.a
#####################################

dex_src_files := \
        CmdUtils.c \
        DexCatch.c \
        DexClass.c \
        DexDataMap.c \
        DexFile.c \
        DexInlines.c \
        DexProto.c \
        DexSwapVerify.c \
        InstrUtils.c \
        Leb128.c \
        OptInvocation.c \
        sha1.c \
        SysUtil.c \
        ZipArchive.c

dex_include_files := \
        $(android_root)/dalvik \
        $(android_root)/dalvik/libnativehelper/include/nativehelper \
        $(android_root)/external/zlib \
        $(android_root)/external/safe-iop/include

target_prefix := libdex
target_srcs := $(dex_src_files)
target_local_includes := $(dex_include_files) src/libdex src/

include $(BUILD)/build_library.mk

#####################################
include $(BUILD)/clear.mk
TARGET := libdvm.so
#####################################

target_srcs := \
        AllocTracker.c \
        AtomicCache.c \
        CheckJni.c \
        Ddm.c \
        Debugger.c \
        DvmDex.c \
        Exception.c \
        Hash.c \
        IndirectRefTable.c.arm \
        Init.c \
        InlineNative.c.arm \
        Inlines.c \
        Intern.c \
        Jni.c \
        JarFile.c \
        LinearAlloc.c \
        Misc.c.arm \
        Native.c \
        PointerSet.c \
        Profile.c \
        Properties.c \
        RawDexFile.c \
        ReferenceTable.c \
        SignalCatcher.c \
        StdioConverter.c \
        Sync.c \
        Thread.c \
        UtfString.c \
        alloc/clz.c.arm \
        alloc/Alloc.c \
        alloc/HeapBitmap.c.arm \
        alloc/HeapDebug.c \
        alloc/HeapSource.c \
        alloc/HeapTable.c \
        alloc/HeapWorker.c \
        alloc/Heap.c.arm \
        alloc/MarkSweep.c.arm \
        alloc/DdmHeap.c \
        analysis/CodeVerify.c \
        analysis/DexOptimize.c \
        analysis/DexVerify.c \
        analysis/ReduceConstants.c \
        analysis/RegisterMap.c \
        analysis/VerifySubs.c \
        interp/Interp.c.arm \
        interp/Stack.c \
        jdwp/ExpandBuf.c \
        jdwp/JdwpAdb.c \
        jdwp/JdwpConstants.c \
        jdwp/JdwpEvent.c \
        jdwp/JdwpHandler.c \
        jdwp/JdwpMain.c \
        jdwp/JdwpSocket.c \
        mterp/Mterp.c.arm \
        mterp/out/InterpC-portstd.c.arm \
        mterp/out/InterpC-portdbg.c.arm \
        native/InternalNative.c \
        native/dalvik_system_DexFile.c \
        native/dalvik_system_SamplingProfiler.c \
        native/dalvik_system_VMDebug.c \
        native/dalvik_system_VMRuntime.c \
        native/dalvik_system_VMStack.c \
        native/dalvik_system_Zygote.c \
        native/java_lang_Class.c \
        native/java_lang_Object.c \
        native/java_lang_Runtime.c \
        native/java_lang_String.c \
        native/java_lang_System.c \
        native/java_lang_SystemProperties.c \
        native/java_lang_Throwable.c \
        native/java_lang_VMClassLoader.c \
        native/java_lang_VMThread.c \
        native/java_lang_reflect_AccessibleObject.c \
        native/java_lang_reflect_Array.c \
        native/java_lang_reflect_Constructor.c \
        native/java_lang_reflect_Field.c \
        native/java_lang_reflect_Method.c \
        native/java_lang_reflect_Proxy.c \
        native/java_security_AccessController.c \
        native/java_util_concurrent_atomic_AtomicLong.c \
        native/org_apache_harmony_dalvik_NativeTestTarget.c \
        native/org_apache_harmony_dalvik_ddmc_DdmServer.c \
        native/org_apache_harmony_dalvik_ddmc_DdmVmInternal.c \
        native/sun_misc_Unsafe.c \
        native/SystemThread.c \
        oo/AccessCheck.c \
        oo/Array.c \
        oo/Class.c \
        oo/Object.c \
        oo/Resolve.c \
        oo/TypeCheck.c \
        reflect/Annotation.c \
        reflect/Proxy.c \
        reflect/Reflect.c \
        test/AtomicSpeed.c \
        test/TestHash.c \
        test/TestIndirectRefTable.c \
        hprof/Hprof.c \
        hprof/HprofClass.c \
        hprof/HprofHeap.c \
        hprof/HprofOutput.c \
        hprof/HprofString.c

# Select architecture-specific sources (armv4t, armv5te, armv7-a etc.)
dvm_arch_variant := armv7-a

ifeq ($(COMPILER_TYPE),rvct-win)
  target_srcs += \
        arch/arm/HintsEABI.c \
        mterp/out/InterpC-$(dvm_arch_variant).c.arm
else
  target_srcs += \
        arch/arm/CallOldABI.S \
        arch/arm/CallEABI.S \
        arch/arm/HintsEABI.c \
        mterp/out/InterpC-$(dvm_arch_variant).c.arm \
        mterp/out/InterpAsm-$(dvm_arch_variant).S
endif

target_prefix := vm

ifeq ($(COMPILER_TYPE),rvct-win)
  target_local_cflags := -DWITH_PROFILER -DWITH_DEBUGGER \
	               -DDVM_RESOLVER_CACHE=0 -DDVM_SHOW_EXCEPTION=1 \
		       -DWITH_HPROF=1
else
  target_local_cflags := -fstrict-aliasing -Wstrict-aliasing=2 -fno-align-jumps \
		       -DWITH_PROFILER -DWITH_DEBUGGER \
		       -DDVM_RESOLVER_CACHE=0 -DDVM_SHOW_EXCEPTION=1 \
		       -DWITH_HPROF=1
endif

target_local_includes := src/vm src \
	$(android_root)/dalvik/libnativehelper/include/nativehelper \
	$(android_root)/dalvik \
	$(android_root)/dalvik/vm \
	$(android_root)/external/zlib \
	$(android_root)/bionic/libc/kernel/common \
	$(android_root)/bionic/libc/kernel/arch-arm

target_local_android_static_libs :=
target_local_android_shared_libs := libdl liblog libcutils libnativehelper libz
target_local_static_libs := libdex
target_local_shared_libs :=

include $(BUILD)/build_library.mk
