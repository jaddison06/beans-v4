import os
import os.path as path
from shutil import rmtree

from sys import argv

def fs_util(*args: str):
    match args[0]:
        case 'rm_file':
            if path.exists(args[1]):
                os.remove(args[1])
        case 'rm_dir':
            if path.exists(args[1]):
                rmtree(args[1])
        case 'mkdir':
            if not path.exists(args[1]):
                os.makedirs(args[1])
        case _: pass

def main():
    fs_util(*argv[1:])

if __name__ == '__main__': main()