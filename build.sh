#!/bin/bash
nasm -felf -Fdwarf bf.asm
gcc -c -m32 -Wall parse.c -o parse.o
gcc -m32 parse.o bf.o -o bf
