#!/usr/bin/python2.4
# count the number of instructions in gcc compiler's output assembler files.

import sys

PSEUDO_INSTS = {
    '.file':0,
    '.text':0,
    '.align':0,
    '.loc':0,
    '.save':0,
    '.vsave':0,
    '@':0,
    '.pad':0,
    '.p2align':0,
    '.size':0,
    '.global':0,
    '.hidden':0,
    '.protected':0,
    '.weak':0,
    '.thumb_set':0,
    '.ident':0,
}

def keyfunc(tuple):
  return tuple[1]+tuple[3]  # inst_size + data_size

def main():
  if (len(sys.argv) != 2):
    print 'gcccount.py foo.s'
    return

  fd = None
  try:
    fd = open(sys.argv[1], 'r')
  except IOError:
    print "Can't open file ", sys.argv[1]
    return

  line_no = 0

  armv7 = False
  have_thumb = False
  thumb_mode = False
  inst_count = 0
  inst_size = 0
  data_size = 0
  functions = []
  in_func = False
  func_name = None
  for line in fd:
    line_no = line_no + 1
    words = line.split()
    if len(words) == 0:
      continue
    inst = words[0]
    # label
    if inst[-1] == ':':
      continue
    if inst in PSEUDO_INSTS:
      continue

    if inst == '.arch':
      if len(words) > 1 and words[1] == 'armv7-a':
        armv7 = True
      continue

    # function name
    if inst == '.type':
      if len(words) != 3:
        message = 'ERROR: ' + line
        sys.stderr.write(message)
        continue
      if words[2] != '%function':
        continue

      if in_func:
        functions.append((func_name, inst_size, inst_count, data_size))
        in_func = False

      func_name = words[1][:-1]
      in_func = True
      inst_count = 0
      inst_size = 0
      data_size = 0
      continue

    # function start
    if inst == '.fnstart':
      in_func = True
      inst_count = 0
      inst_size = 0
      data_size = 0
      continue
    # function end
    if inst == '.fnend' and in_func:
      in_func = False
      functions.append((func_name, inst_size, inst_count, data_size))
      continue
    if inst == '.thumb_func':
      if in_func:
        in_func = False
        functions.append((func_name, inst_size, inst_count, data_size))
      thumb_mode = True
      have_thumb = True
      continue

    if inst == '.code':
      if len(words) != 2:
        message = 'ERROR: ' + line
        sys.stderr.write(message)
        continue
      if words[1] == '16':
        thumb_mode = True
        have_thumb = True
      else:
        thumb_mode = False
      continue

    if not in_func:
      continue

    if inst == '.word':
      data_size = data_size + 4
      continue
    if inst == '.byte':
      data_size = data_size + 1
      continue
    if inst == '.2byte':
      data_size = data_size + 2
      continue

    if (inst == '.section') or (inst == '.bss') or (inst == '.data'):
      if in_func:
        in_func = False
        functions.append((func_name, inst_size, inst_count, data_size))
      continue

    if inst[0] == '.':
      message = 'UNRECOGNIZED TOKEN %s:%d: %s' % (sys.argv[1], line_no, line)
      sys.stderr.write(message)
      continue

    inst_count = inst_count + 1

    if thumb_mode == False:
      inst_size = inst_size + 4
      continue

    inst = inst.lower()
    if (inst == 'bl') or (inst == 'blx'):
      reg = words[1].lower()
      if reg[0] == 'r':
        reg = reg[1:]
        if reg.isdigit():
          inst_size = inst_size + 2
          continue
      # 32bit thumb instructions
      inst_size = inst_size + 4
      continue

    inst_size = inst_size + 2

  fd.close()
  if in_func:
    in_func = False
    functions.append((func_name, inst_size, inst_count, data_size))

  if armv7 and have_thumb:
    # This file contains thumb2 codes, it is difficult to count the
    # instruction size. Instead readelf should be used.
    # It has been noticed that sometimes the readelf output is not precise,
    # so it is not used as the default method.
    sys.stderr.write('WARNING: THUMB2 instructions detected, please use\n')
    sys.stderr.write('        countthumb2.py foo.o\n')
    sys.stderr.write('to get the code size.\n\n\n')

  functions.sort(key=keyfunc, reverse=True)
  for (f, inst_size, inst_count, data_size) in functions:
    print ('%s  size  %d    inst_count %d'
           % (f, inst_size + data_size, inst_count))

if __name__ == '__main__':
    main()
