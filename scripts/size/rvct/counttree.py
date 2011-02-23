#!/usr/bin/python

# This script counts the instruction size of armcc generated generated
# annotated assembler files. Those files should be compiled with options
# --asm --interleave. All .txt files under the specified path will be
# processed.
# This script is tested only in windows and mac system.
# You may need to convert it with dos2unix or unix2dos before using it.

import sys, os

# list of tuples
# (file, function, bytes, objectsize)
data = []
filesize = {}
objectsize = {}

def constructfilename(dirname, fname):
  pos = dirname.find(sys.argv[1])
  prefix_len = len(sys.argv[1])
  if (sys.argv[1] != dirname[:prefix_len]):
    message = "ERROR! " + dirname + " doesn't contain " + sys.argv[1] + "\n"
    sys.stderr.write(message)
    return " "
  path = ""
  if len(dirname) > prefix_len:
    path = dirname[prefix_len+1:] + os.sep
  return path+fname

def countfile(dirname, name, data, objsize):
  filename = constructfilename(dirname, name)
  cmd = "c:\\rvctcount.py "
  if sys.platform != "win32":
    cmd = "rvctcount.py "
  cmd = cmd + dirname + os.sep + name + " > count.tmp"
  os.system(cmd)
  tmpfile = open("count.tmp", "r")
  for line in tmpfile:
    fields = line.split()
    if len(fields) == 5:
      function = fields[0]
      bytes = int(fields[2])
      data.append((filename, function, bytes, objsize))
  tmpfile.close()
  return

def   enum_file(data,   dirname,   names):  
  for   name   in   names:
    if os.path.isfile(dirname+os.sep+name):
      root, ext = os.path.splitext(name)
      if ext == ".txt":
        objfile = root + ".o"
        objsize = os.path.getsize(dirname+os.sep+objfile)
        countfile(dirname, name, data, objsize)
        sys.stderr.write(".")

def keyfunc(tuple):
  return tuple[1]

def main():
  if (len(sys.argv) != 2):
    print "counttree.py path"
    return

  os.path.walk(sys.argv[1],   enum_file,   data)   
  sys.stderr.write("\n")

  for filename, function, size, objsize in data:
    fsize = filesize.get(filename, 0)
    fsize = fsize + size
    filesize[filename] = fsize
    objectsize[filename] = objsize

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

if __name__ == '__main__':
    main()

