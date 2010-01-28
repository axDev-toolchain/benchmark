#!/usr/bin/python2.4
#
# Copyright 2009 Google Inc. All Rights Reserved.

"""Run Android benchmarks

Compiles the specified targets and gets info on running them
"""

__author__ = 'ushakov@google.com (Maxim Ushakov)'

import os
import sys
import getopt
import subprocess

options = [
    ["action=", ["build","build-fdo","clean","export","runcmd","getsize"]],
    ["mode=", ["arm","thumb"]],
    ["toolchain=", [], "toolchain path"],
    ["add_cflags=", [], "additional flags for compilation"],
    ["add_ldflags=", [], "additional flags for linking"],
    ["disable_cflags=", [], "default cflags to remove"],
    ["android_branch=", ["eclair","mainline","cupcake"]],
    ["build_target=", ["lib","bench"]],
    ["mute=", ["on","off"]],
    ["asm=", ["on","off"]],
    ["makeopts=", [], "override make options (default -j4 --warn-undefined_variables)"],
    ["serial=", [], "\"emulator\" or device serial number"],
    ["help", []],
    ]
def ShowUsage():
  """Print out the usage info.
  """
  print "Options:"
  for x in options:
    opt = x[0]
    if opt[-1:] == '=':
      opt = opt[:-1]
    s = "   [ --%s" % x[0]
    if len(x[1]) != 0:
      s += "%s" % "|".join(x[1])
    if len(x) > 2:
      s += " (%s)" % x[2]
    print s, "]"

set_opts = {}

def ParseOptions(argv):
  """Parse the command-line options and check validity."
  """
  try:
    opts, args = getopt.gnu_getopt(argv, "", [x[0] for x in options])
  except getopt.GetoptError, err:
    print "Error:", str(err)
    ShowUsage()
    return False

  if len(args) != 0:
    ShowUsage()
    return False

  for p in opts:
    opt = p[0][2:]
    set_opts[opt] = p[1]

  if "help" in set_opts:
    ShowUsage()
    return False

  ok = True
  for x in options:
    opt = x[0]
    if opt[-1:] == '=':
      opt = opt[:-1]
    if opt not in set_opts:
      continue
    if len(x[1]) == 0:
      continue
    if set_opts[opt] not in x[1]:
      print "Error: option --%s takes args in [%s]" % (opt, ", ".join(x[1]))
      ok = False

  if "action" not in set_opts:
    print "No --action specified -- no work done"
    return False

  return ok

def RunCmd(cmdline):
  print cmdline
  ret = subprocess.call(cmdline, shell=True)
  if ret == 0:
    return ret
  if ret < 0:
    print "Command %s killbed by signal %s" % (cmdline, -ret)
  else:
    print "Command %s exited with status %s" % (cmdline, ret)
  return ret

def CreateDummyBench():
  """Create dummy *_bench file if benchmark does not generate executable.
  This function is mainly for perflab integration. Since perflab requires
  that each benchmark must have a $(bench_name)_bench executable, we need
  to create a dummy one (0 size) if the benchmark does not generate this
  executable automatically (eg. gcstone).
  """
  # Get the current benchmark name.
  cur_path = os.getcwd()
  bench_name = os.path.basename(cur_path)

  # Create one if $(out)/$(bench_name)_bench does not exist.
  bench_exe = os.path.join(cur_path, "out", "%s_bench" % bench_name)
  if not os.path.exists(bench_exe):
    if not os.path.exists(os.path.join(cur_path, 'out')):
      print "Error: output path does not exist. Build must be wrong."
      return False
    dummy_file = open(bench_exe, "w")
    dummy_file.close()
    os.chmod(bench_exe, 0750)
  return True

def FindTopPath():
  """Find top directory of the benchmark suite."""
  cur_path = os.getcwd()
  if os.path.exists(os.path.join(cur_path, "../scripts/build/main.mk")):
    return ".."
  elif os.path.exists(os.path.join(cur_path, "../../scripts/build/main.mk")):
    return "../.."
  else:
    return ""

_MAKE_CMD_TEMPLATE = "make %(opts)s -f %(mainmk)s %(vars)s %(target)s"

def main(argv):
  if not ParseOptions(argv[1:]):
    return 1

  top_path = FindTopPath()
  if not top_path:
    print "Error: This script must be called from benchmark dir!"
    return 1

  os.putenv("RVCT40INC","")
  os.putenv("RVCT40LIB","")
  make_vars = ""

  if "mode" in set_opts:
    make_vars += " COMPILE_MODE=%s" % set_opts["mode"]

  if "toolchain" in set_opts:
    make_vars += " TOOLCHAIN=%s" % set_opts["toolchain"]

  if "add_cflags" in set_opts:
    make_vars += " ADD_CFLAGS=\"%s\"" % set_opts["add_cflags"]

  if "add_ldflags" in set_opts:
    make_vars += " ADD_LDFLAGS=\"%s\"" % set_opts["add_ldflags"]

  if "disable_cflags" in set_opts:
    make_vars += " DISABLE_CFLAGS=\"%s\"" % set_opts["disable_cflags"]

  if "android_branch" in set_opts:
    make_vars += " ANDROID_BRANCH=%s" % set_opts["android_branch"]

  if "build_target" in set_opts:
    make_vars += " BUILD_TARGET=%s" % set_opts["build_target"]

  if "mute" in set_opts:
    make_vars += " MUTE=%s" % set_opts["mute"]

  if "asm" in set_opts:
    make_vars += " ASM=%s" % set_opts["asm"]

  if "makeopts" in set_opts:
    make_opts = set_opts["makeopts"]
  else:
    make_opts = "-j4 --warn-undefined-variables"

  make_dict = {
      "opts" : make_opts,
      "mainmk" : "%s/scripts/build/main.mk" % top_path,
      "vars" : make_vars,
      "target": set_opts["action"]
      }
  if set_opts["action"] == "build-fdo":
    # First, do a clean
    my_dict = make_dict.copy()
    my_dict["target"] = "clean"
    cmd = _MAKE_CMD_TEMPLATE % (my_dict)
    ret = RunCmd(cmd)
    if ret != 0: return ret

    # Compile with profiler support.
    my_dict = make_dict.copy()
    my_dict["vars"] = (make_dict["vars"] + " SKIP_PRELINKING=1" +
                       " FDO_BUILD=1 ADD_CFLAGS=\"%s\" ADD_LDFLAGS=\"%s\"" % \
                       (set_opts.get("add_cflags","") +
                        " -fprofile-generate=/data/local/profile/"
                        " -DANDROID_FDO",
                        set_opts.get("add_ldflags","") +
                        " -fprofile-generate=/data/local/profile/"
                        " -Wl,--stub-group-size=2000000"))
    my_dict["target"] = "build"
    cmd = _MAKE_CMD_TEMPLATE % (my_dict)
    ret = RunCmd(cmd)
    if ret != 0: return ret

    run_fdo_device = ""
    if "serial" in set_opts:
      if set_opts["serial"] == "emulator":
        run_fdo_device = "--emulator"
      else:
        run_fdo_device = "--s %s" % set_opts["serial"]
    ret = RunCmd("../run_on_android.py %s --fdo-run" % run_fdo_device)
    if ret != 0: return ret

    # now we have FDO output in ./fdo/ -- clean up and move it to obj dir
    my_dict = make_dict.copy()
    my_dict["target"] = "clean"
    cmd = _MAKE_CMD_TEMPLATE % (my_dict)
    ret = RunCmd(cmd)
    if ret != 0: return ret

    ret = RunCmd("mv fdo obj")
    if ret != 0: return ret

    # Compile for the second time, now using profiles.
    my_dict = make_dict.copy()
    my_dict["vars"] = (make_dict["vars"] +
                       " FDO_BUILD=1 ADD_CFLAGS=\"%s\" ADD_LDFLAGS=\"%s\"" % \
                       (set_opts.get("add_cflags","") + " -fprofile-use"
                                                        " -DANDROID_FDO",
                        set_opts.get("add_ldflags","") + " -fprofile-use"))
    my_dict["target"] = "build"
    cmd = _MAKE_CMD_TEMPLATE % (my_dict)
    ret = RunCmd(cmd)
    if ret != 0: return ret
    CreateDummyBench()

    return ret
  else:
    cmd = _MAKE_CMD_TEMPLATE % (make_dict)
    ret = RunCmd(cmd)
    if ret != 0: return ret

    if set_opts["action"] == "build":
      CreateDummyBench()

if __name__ == '__main__':
  sys.exit(main(sys.argv))
