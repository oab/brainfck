; the brainf*ck interpreter

; this language can be described as follows
;
; character   -  meaning
;     >       -  increment data pointer
;     <       -  decrement data pointer
;     +       -  increment byte at data pointer
;     -       -  decrement byte at data pointer
;     .       -  output byte  at data pointer to stdout
;     ,       -  accept one byte of input from stdin,
;                store it in byte at data pointer
;     [       -  IF byte at datapointer is zero
;                THEN jump forward to the instruction after the matching ]
;                ELSE next instruction
;     ]       -  IF the byte at the datapointer is nonzero
;                THEN jump backwards to the instruction after the matching [
;                ELSE next instruction

SIZE: equ 256

OP_INCP: equ 0
OP_DECP: equ 1
OP_INCV: equ 2
OP_DECV: equ 3
OP_OUTV: equ 4
OP_INV: equ 5
OP_LPB: equ 6
OP_LPE: equ 7
OP_END: equ 8

global main
global codebuffer
global evalbf
extern putchar
extern getchar

section .data
bfdata: times SIZE db 0

section .bss

codebuffer: resb SIZE



section .text

; the brainf*ck machine
; keep the data pointer    in  ebx
; keep instruction pointer in  ecx


evalbf:
  mov ecx,codebuffer ; init. instruction pointer
  mov ebx,bfdata
  jmp fetcheval
  
fetcheval:
  mov byte eax,[ecx]
  inc ecx
  jmp [jmptable+eax]
  jmp fetcheval
 
incv:
    
  jmp fetcheval

decv:
  jmp fetcheval

incp:
  jmp fetcheval

decv:
  jmp fetcheval

outv:
  jmp fetcheval

inv:
  jmp fetcheval

lpb:
  jmp fetcheval

lpe:
  jmp fetcheval

end:
  ret  

jumptable:  
  dw incv
  dw decv
  dw incp
  dw decv
  dw outv
  dw inv
  dw lpb
  dw lpe 
  dw end 






