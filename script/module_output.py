#! /usr/bin/env python3 

'''
HOWTO USE THIS SCRIPT

$ ./module_output.py FILE_NAME \
  > | awk '/Loaded/,/-/' \
  > | sed 's/-*//g' \
  > | sed 's/: .*//g;s/\..*//g;s/^_.*//g;s/Loaded modules//' \
  > | sed '/^$/d' \
  > | sort \
  > | uniq \
  > | xargs -L1 -I{} bash -c 'pip3 freeze | grep {}' > requirements.txt

'''

from modulefinder import ModuleFinder
import sys
import os

file = sys.argv[1]
finder = ModuleFinder()
finder.run_script(file)

print('Loaded modules')
for name, mod in finder.modules.items():
    print('%s: '% name, end='')
    print(','.join(list(mod.globalnames.keys())[:3]))

print('-'*50)
print('Modules not imported:')
print('\n'.join(finder.badmodules.keys()))
