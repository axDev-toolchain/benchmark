#!/usr/bin/python

# This script counts the instruction size of gcc generated assembler files.
# Those files should be compiled with option -save-temps.
# All .s files in the specified directory will be processed.
# If the generated code contains thumb2 instructions please add option
# --thumb2 to the command line.

import sys
import os

# list of tuples
# (file, function, bytes)
data = []
filesize = {}
objectsize = {}
thumb2 = False

def constructfilename(dirname, fname):
  prefix_len = len(sys.argv[1])
  if (sys.argv[1] != dirname[:prefix_len]):
    message = "ERROR! %s doesn't contain %s\n" % (dirname, sys.argv[1])
    sys.stderr.write(message)
    return " "
  path = ""
  if len(dirname) > prefix_len:
    path = dirname[prefix_len+1:] + "/"
  return path+fname

def countfile(name, data):
  cmd = "/usr/bin/python " + sys.path[0] + "/gcccount.py "
  cmd = cmd + name + " > count.tmp"
  os.system(cmd)
  tmpfile = open("count.tmp", "r")
  root, ext = os.path.splitext(name)
  for line in tmpfile:
    fields = line.split()
    if len(fields) == 5:
      function = fields[0]
      bytes = int(fields[2])
      data.append((root, function, bytes))
  tmpfile.close()
  return

def countfile2(dirname, name, data):
  fullname = "%s/%s" % (dirname, name)
  cmd = "/usr/bin/python " + sys.path[0] + "/countthumb2.py "
  cmd = cmd + fullname + " > count.tmp"
  os.system(cmd)
  tmpfile = open("count.tmp", "r")
  root, ext = os.path.splitext(name)
  for line in tmpfile:
    fields = line.split()
    if len(fields) == 2:
      function = fields[0]
      bytes = int(fields[1])
      data.append((root, function, bytes))
  tmpfile.close()
  return

def enum_file(data, dirname, names):
  global thumb2
  for name in names:
    if os.path.isfile(dirname+"/"+name):
      root, ext = os.path.splitext(name)
      if ext == ".s" and not thumb2:
        countfile(name, data)
        sys.stderr.write(".")
      if ext == ".o":
        if thumb2:
          countfile2(dirname, name, data)
        objsize = os.path.getsize(dirname+"/"+name)
        filename = constructfilename(dirname, name)
        objectsize[root] = objsize
        sys.stderr.write(".")

def keyfunc(tuple):
  return tuple[1]

def main():
  global thumb2
  arguments = len(sys.argv)
  bad_cmd = False
  help = False
  if arguments < 2:
    bad_cmd = True
  elif sys.argv[1] == "-help":
    help = True
  elif arguments > 3:
    bad_cmd = True
  elif arguments == 3:
    if sys.argv[2] == "-thumb2":
      thumb2 = True
    else:
      bad_cmd = True

  if bad_cmd or help:
    print "counttree.py path [-thumb2]"
    print "counttree.py -help"
    return

  os.path.walk(sys.argv[1], enum_file, data)
  sys.stderr.write("\n")

  for filename, function, size in data:
    fsize = filesize.get(filename, 0)
    fsize = fsize + size
    filesize[filename] = fsize

  filetuple = []
  for filename in filesize:
    filetuple.append((filename, filesize[filename]))
  filetuple.sort(key=keyfunc, reverse=True)

  total_inst = 0
  total_obj = 0
  for filename, fsize in filetuple:
    total_inst = total_inst + fsize
    total_obj = total_obj + objectsize[filename]
    print filename, fsize, objectsize[filename]
  print "TOTAL  ", total_inst, total_obj

if __name__ == "__main__":
    main()
