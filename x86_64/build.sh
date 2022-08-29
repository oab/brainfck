#!/bin/bash

# Q1: Why can't we just do e.g "CONFIG=m1mac" and run this script?
#     Why must we do "export config=m1mac" to run it as intended? 


case $CONFIG in

m1mac)
	nasm -fmacho64 -Fdwarf -g bf.asm
	clang -c --target=x86_64-apple-darwin-macho -Wall parse.c -g -o parse.o
	ld -L /Library/Developer/CommandLineTools/SDKs/MacOSX12.3.sdk/usr/lib -macosx_version_min 12.3.0 -lc -o bf bf.o parse.o
	;;
	
linux32)
	nasm -felf -Fdwarf -g bf.asm
	gcc -c -m32 -Wall parse.c -g -o parse.o
	gcc -m32 parse.o bf.o -o bf
	;;
*)
	printf "unknown configuration\n"
	;;
esac
