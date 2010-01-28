#!/usr/bin/python2.4
# count the code size of each function from readelf's output

import os
import sys
import tempfile

def keyfunc(tuple):
  return tuple[1]

def main():
  if (len(sys.argv) != 2):
    print "countthumb2.py foo.o"
    return

  if not os.path.exists(sys.argv[1]):
    print "Can't find file", sys.argv[1]
    return

  tmpfile = os.path.join(tempfile.gettempdir(), "android_benchmark")
  cmd = "readelf -s " + sys.argv[1] + " > " + tmpfile
  os.system(cmd)

  functions = []
  fd = open(tmpfile, "r")
  for line in fd:
    fields = line.split()
    if len(fields) >= 8 and fields[3] == "FUNC":
      functions.append((fields[7], int(fields[2])))
  fd.close()

  functions.sort(key=keyfunc, reverse=True)
  for (f, size) in functions:
    print f, size


if __name__ == "__main__":
  main()
