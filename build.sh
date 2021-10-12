#!/bin/bash
nasm -felf -Fdwarf -g bf.asm
gcc -c -m32 -Wall parse.c -g -o parse.o
gcc -m32 parse.o bf.o -o bf
