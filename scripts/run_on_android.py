#!/usr/bin/python2.4
#
# Copyright 2009 Google Inc. All Rights Reserved.

"""Run current benchmark on Android emulator or device

Run this script from benchmark directory:

../run_on_android --emulator

This command will launch the emulator and run on the emulator.
Make sure there is no devices connected to the desktop.

or

../run_on_android --s <serial number>

This command will run benchmark on this devices (or emulator).

For fdo profile run, give --fdo-run to the command line.
The benchmark has to be be already built.
"""

__author__ = 'ushakov@google.com (Maxim Ushakov)' \
             'jingyu@google.com (Jing Yu)'

import sys
import subprocess
import os
import signal
import time
import traceback

EMULATOR_AVD = "cupcake"
EMULATOR_COMMAND = "emulator"

emulator = False
serial = ""
fdo = False

class RuntimeException(Exception):
  def __init__(self, message):
    print "RunError: %s" % message

def StartEmulator():
  cmdline = "%s @%s -no-window" % (EMULATOR_COMMAND, EMULATOR_AVD)
  args = cmdline.split()
  p = subprocess.Popen(args)
  time.sleep(3)
  if p.poll() != None:
    print "Emulator exited with code %s" % (p.returncode)
    raise RuntimeException("Emulator not launched")
  return p

def KillEmulator(p):
  os.kill(p.pid, signal.SIGTERM)
  time.sleep(1)
  return p.poll()

def GetOutput(cmdline):
  print cmdline
  p = subprocess.Popen(cmdline, stdout=subprocess.PIPE, shell=True)
  out = p.communicate()[0]
  if p.returncode != 0:
    print "Error: %s returned %s" % (cmdline, p.returncode)
    raise RuntimeException("Command failed")
  return out.strip()

def GetObjDirsTopDown(name = "obj"):
  top = os.path.join(os.getcwd(), name)
  subdirs = [root for root, dummy1, dummy2 in os.walk(top)]
  return subdirs

KEY_BENCHMARK_NAME = "benchmark_name"
KEY_RUN_COMMAND = "run_command"
KEY_EXPORT_FILES = "export_files"
KEY_OBJ_DIRS = "obj_dirs"

def GetBenchmarkInfo(scripts_path):
  bench_script = "%s/bench.py" % scripts_path
  info = {}
  info[KEY_BENCHMARK_NAME] = os.path.basename(os.getcwd())
  info[KEY_RUN_COMMAND] = GetOutput("%s --action=runcmd" % bench_script)
  print info[KEY_RUN_COMMAND]
  info[KEY_EXPORT_FILES] = GetOutput("%s --action=export" % bench_script)
  print info[KEY_EXPORT_FILES]
  info[KEY_OBJ_DIRS] = GetObjDirsTopDown()
  return info

def MakeDir(dir):
  cmd = "adb shell mkdir %s" % dir
  ret = GetOutput(cmd)
  print ret
  if ret.startswith("mkdir failed") and not ret.endswith("File exists"):
    raise RuntimeException("mkdir failed")


def MakeFDODirs(info):
  dirs = info[KEY_OBJ_DIRS]
  p = dirs[0]
  print GetOutput("adb shell rm -r %s" % p)
  components = [p]
  while p != "" and p != "/":
    head, tail = os.path.split(p)
    components = [head] + components
    p = head
  for c in components:
    MakeDir(c)
  for p in dirs[1:]:
    MakeDir(p)

def GetFDOFiles(info):
  #root = info[KEY_OBJ_DIRS][0]
  cmd = "adb %s pull /data/local/profile/obj fdo" % serial
  print GetOutput(cmd)

def PushExportFiles(info):
  files = info[KEY_EXPORT_FILES].split()
  print files
  for f in files:
    cmd = "adb %s push %s /data/local/perflab" % (serial, f)
    print GetOutput(cmd)

TEMPLATES_PRE = [
    "adb wait-for-device",
    "adb %s shell rm -r /data/local/perflab",
    "adb %s shell rm -r /sdcard/perflab_input",
    "adb %s shell mkdir /data/local/perflab",
    "adb %s shell mkdir /sdcard",
    "adb %s push data /sdcard/perflab_input"
    ]

TEMPLATES_CLEAN = [
    "adb %s shell rm -r /data/local/perflab",
    "adb %s shell mkdir /data/local/perflab"
    ]

TEMPLATES_FDO_CLEAN = [
    "adb %s shell rm -r /data/local/profile",
    "adb %s shell mkdir /data/local/profile"
    ]

#TEMPLATES_DO_WORK = [
#    "time adb %s shell 'cd /data/local/perflab; %(" + KEY_RUN_COMMAND + ")s'",
#    ]
TEMPLATES_DO_WORK = [
    "time adb %s shell 'cd /data/local/perflab; %s'",
    ]


def DoCommandsInfo(info, template_list):
  for tpl in template_list:
    cmd = tpl % (serial, info)
    print GetOutput(cmd)

def DoCommands(template_list):
  for tpl in template_list:
    cmd = tpl % serial
    print GetOutput(cmd)

def GetArgument(argv):
  global fdo, emulator, serial
  skip = False
  for i in range(1,len(argv)):
    if skip:
      skip = False
      continue

    v = argv[i]
    if v == "--emulator":
      emulator = True
      continue
    if v == "--s":
      if i == len(argv):
        print "Error: <serial number> is missing after --s"
        return 1
      else:
        skip = True
        serial = " -s %s" % argv[i+1]
        continue
    if v == "--fdo-run":
      fdo = True
      continue
    print "Error: Unrecognized argument %s" % v
    return 1
  return 0

def main(argv):
  global fdo, emulator, serial
  if len(argv) > 1:
    ret = GetArgument(argv)
    if ret != 0:
      return 1

  # Figure out where it is located.
  my_path = os.path.dirname(argv[0])
 
  try:
    if emulator:
      emu = StartEmulator()

    info = GetBenchmarkInfo(my_path)
  except Exception, e:
    print traceback.format_exc()
    if emulator:
      KillEmulator(emu)
    return 1

    # For newly launched emulator, we need to push input data to
    # its /sdcard/perflab_input.
    # Otherwise, we assume the input data is already there.
  try:
    if emulator:
      DoCommands(TEMPLATES_PRE)
    else:
      DoCommands(TEMPLATES_CLEAN)
    if fdo:
      DoCommands(TEMPLATES_FDO_CLEAN)
  except Exception, e:
    print "Warning: some directories do not exist. let's continue."

  try:
    PushExportFiles(info)

    DoCommandsInfo(info[KEY_RUN_COMMAND], TEMPLATES_DO_WORK)

    if fdo:
      GetFDOFiles(info)

    if emulator:
      ret = KillEmulator(emu)
      if ret != 0:
        print "emulator died with exit code %s" % (ret)
  except Exception, e:
    print traceback.format_exc()
    if emulator:
      KillEmulator(emu)
    return 1

if __name__ == '__main__':
  sys.exit(main(sys.argv))
