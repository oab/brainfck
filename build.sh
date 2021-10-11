#!/bin/bash
nasm -felf -Fdwarf bf.asm
gcc -c -m32 parse.c -o parse.o
ld bf.o parse.o /lib/{crt1.o,crti.o}  -lc -melf_i386 -o bf
