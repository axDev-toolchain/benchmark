# count the number of instructions in rvct compiler's output
# the rvct's command line should be
# armcc --asm --interleave foo.c
# then the foo.txt can be used as input to this script
# This script has only been tested under windows.

import sys

def remove_space(name):
  func_name = ""
  components = name.split()
  for c in components:
    func_name = func_name + c
  return func_name

def keyfunc(tuple):
  return tuple[1]

def findFuncNameRight(line):
  brackets = 1;
  end = line.rfind(')')
  while brackets > 0:
    end = end - 1
    if line[end] == '(':
      brackets = brackets - 1;
    if line[end] == ')':
      brackets = brackets + 1;
  return end

def main():
  if (len(sys.argv) != 2):
    print "rvctcount.py foo.txt"
    return

  fd = None
  try:
    fd = open(sys.argv[1], 'r')
  except IOError:
    print "Can't open file ", sys.argv[1]
    return

  inst_count = 0
  inst_size = 0
  data_size = 0
  functions = []
  in_func = False
  func_name = None
  for line in fd:
    # comment line
    if line[0] == ';':
      continue
    words = line.split()
    if (len(words) == 0):
      continue
    # function end
    if (len(words) > 1) and (words[0] == "AREA") and in_func:
      in_func = False
      functions.append((func_name, inst_size+data_size, inst_count))
      continue
    # function start
    if (len(words) >= 2) and (words[1] == "PROC"):
      if in_func:
        # finish last function
        functions.append((func_name, inst_size+data_size, inst_count))

      in_func = True
      inst_size = 0
      data_size = 0
      inst_count = 0
      if (len(words) >= 4):
        start = line.find(';')
        end = findFuncNameRight(line)
        func_name = line[start+2 : end]
      else:
        func_name = words[0]
      func_name = remove_space(func_name)
      continue
    if not in_func:
      continue
    # the format is
    # address   hex     instruction   operands
    if words[0] == "DCD":
      data_size = data_size + 4
      continue
    if line[0] != '0':
      continue
    if len(words) < 3:
      continue
    if (words[2] == "DCB") or (words[2] == "DCW"):
      data_size = data_size + len(words[1]) / 2
    elif len(words[1]) == 8:
      inst_size = inst_size + 4
      inst_count = inst_count + 1
    elif len(words[1]) == 4:
      inst_size = inst_size + 2
      inst_count = inst_count + 1
    else:
      message = sys.argv[1] + " ERROR: " + line + "\n"
      sys.stderr.write(message)
      continue
  if in_func:
    functions.append((func_name, inst_size+data_size, inst_count))
  fd.close()

  functions.sort(key=keyfunc, reverse=True)
  for (f, size, count) in functions:
    print f, "    size", size, "    count", count

if __name__ == '__main__':
    main()
