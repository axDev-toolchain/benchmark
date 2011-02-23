#### python ####
DIR:=$(call my-dir)

# Which file we measure the size
get_which_size=libpython2.6.so

# Running commands
run_cmd=LD_LIBRARY_PATH=${PERFLAB_PATH} PYTHONHOME=${PERFLAB_PATH} ${PERFLAB_PATH}/python_bench -S ${PERFLAB_INPUT}/pybench/pybench.py -n 2 --with-gc --with-syscheck

python_cflags :=
python_includes := src/

VERSION= 2.6
LIBRARY= libpython$(VERSION).a
LDLIBRARY= libpython$(VERSION).so

POBJS = Parser/acceler.c \
	Parser/grammar1.c \
	Parser/listnode.c \
	Parser/node.c \
	Parser/parser.c \
	Parser/parsetok.c \
	Parser/bitset.c \
	Parser/metagrammar.c \
	Parser/firstsets.c \
	Parser/grammar.c \
	Parser/pgen.c

PARSER_SRCS = $(POBJS) Parser/myreadline.c Parser/tokenizer.c

UNICODE_SRCS = Objects/unicodeobject.c Objects/unicodectype.c

OBJECT_SRCS = Objects/abstract.c \
	      Objects/boolobject.c \
	      Objects/bufferobject.c \
	      Objects/bytes_methods.c \
	      Objects/bytearrayobject.c \
	      Objects/cellobject.c \
	      Objects/classobject.c \
	      Objects/cobject.c \
	      Objects/codeobject.c \
	      Objects/complexobject.c \
	      Objects/descrobject.c \
	      Objects/enumobject.c \
	      Objects/exceptions.c \
	      Objects/genobject.c \
	      Objects/fileobject.c \
	      Objects/floatobject.c \
	      Objects/frameobject.c \
	      Objects/funcobject.c \
	      Objects/intobject.c \
	      Objects/iterobject.c \
	      Objects/listobject.c \
	      Objects/longobject.c \
	      Objects/dictobject.c \
	      Objects/methodobject.c \
	      Objects/moduleobject.c \
	      Objects/object.c \
	      Objects/obmalloc.c \
	      Objects/rangeobject.c \
	      Objects/setobject.c \
	      Objects/sliceobject.c \
	      Objects/stringobject.c \
	      Objects/structseq.c \
	      Objects/tupleobject.c \
	      Objects/typeobject.c \
	      Objects/weakrefobject.c \
	      $(UNICODE_SRCS)

DYNLOADFILE=    dynload_shlib.c

THREADSRC=      Python/thread.c

PYTHON_SRCS = Python/_warnings.c \
	     Python/Python-ast.c \
	     Python/asdl.c \
	     Python/ast.c \
	     Python/bltinmodule.c \
	     Python/ceval.c \
	     Python/compile.c \
	     Python/codecs.c \
	     Python/errors.c \
	     Python/frozen.c \
	     Python/frozenmain.c \
	     Python/future.c \
	     Python/getargs.c \
	     Python/getcompiler.c \
	     Python/getcopyright.c \
	     Python/getmtime.c \
	     Python/getplatform.c \
	     Python/getversion.c \
	     Python/graminit.c \
	     Python/import.c \
	     Python/importdl.c \
	     Python/marshal.c \
	     Python/modsupport.c \
	     Python/mystrtoul.c \
	     Python/mysnprintf.c \
	     Python/peephole.c \
	     Python/pyarena.c \
	     Python/pyfpe.c \
	     Python/pymath.c \
	     Python/pystate.c \
	     Python/pythonrun.c \
	     Python/structmember.c \
	     Python/symtable.c \
	     Python/sysmodule.c \
	     Python/traceback.c \
	     Python/getopt.c \
	     Python/pystrcmp.c \
	     Python/pystrtod.c \
	     Python/formatter_unicode.c \
	     Python/formatter_string.c \
	     Python/$(DYNLOADFILE) \
	     $(THREADSRC)

MODULE_SRCS = Modules/config.c \
	      Modules/getpath.c \
	      Modules/main.c \
	      Modules/gcmodule.c

MODSRCS = Modules/threadmodule.c \
	  Modules/signalmodule.c \
	  Modules/posixmodule.c \
	  Modules/errnomodule.c \
	  Modules/pwdmodule.c \
	  Modules/_sre.c \
	  Modules/_codecsmodule.c \
	  Modules/zipimport.c \
	  Modules/symtablemodule.c \
	  Modules/timemodule.c \
	  Modules/operator.c \
	  Modules/_struct.c \
	  Modules/binascii.c \
	  Modules/_functoolsmodule.c \
	  Modules/xxsubtype.c

ifeq ($(COMPILER_TYPE),rvct-win)
  PY_CFLAGS = -DPy_BUILD_CORE
else
  PY_CFLAGS = -fno-strict-aliasing -fwrapv -Wall -Wstrict-prototypes -DPy_BUILD_CORE
endif

#####################################
include $(BUILD)/clear.mk
TARGET := $(LIBRARY)
#####################################

LIBRARY_SRCS := Modules/getbuildinfo.c \
		$(PARSER_SRCS) \
		$(OBJECT_SRCS) \
		$(PYTHON_SRCS) \
		$(MODULE_SRCS) \
		$(MODSRCS)

target_srcs := $(LIBRARY_SRCS)
target_local_cflags := $(PY_CFLAGS)
target_local_includes := src/ src/Include

#include $(BUILD)/build_library.mk

#####################################
include $(BUILD)/clear.mk
TARGET := $(LDLIBRARY)
#####################################

target_srcs := $(LIBRARY_SRCS)
target_local_android_shared_libs := libdl  libm
target_local_cflags := $(PY_CFLAGS)
target_local_includes := src/ src/Include

include $(BUILD)/build_library.mk

#####################################
include $(BUILD)/clear.mk
TARGET := python_bench
#####################################

target_srcs := Modules/python.c
target_local_shared_libs := libpython$(VERSION)
target_local_android_shared_libs := libdl libm
target_local_cflags := $(PY_CFLAGS)
target_local_includes := src/ src/Include

include $(BUILD)/build_executable.mk
