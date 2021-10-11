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

section .rodata

jmptable:  
  dd incv
  dd decv
  dd incp
  dd decp
  dd outv
  dd inv
  dd lpb
  dd lpe 
  dd end 


section .text

; the brainf*ck machine
; keep the data pointer    in  ebx
; keep instruction pointer in  ecx


evalbf:
  mov ecx,codebuffer ; init. instruction pointer
  mov ebx,bfdata     ; init. data pointer
  jmp fetcheval      ; start interpreter
  
fetcheval:
  movzx eax,byte [ecx]
  inc ecx
  jmp [jmptable+eax]
  jmp fetcheval
 
incv:
  mov al,[ebx]
  inc al
  mov [ebx],al
  jmp fetcheval

decv:
  mov al,[ebx]
  dec al
  mov al,[ebx]
  jmp fetcheval

incp:
  inc ebx
  jmp fetcheval

decp:
  dec ebx
  jmp fetcheval

outv:
  movzx eax,byte [ebx]
  call putchar
  jmp fetcheval

inv:
  call getchar
  mov [ebx],al
  jmp fetcheval

lpb:
  jmp fetcheval

lpe:
  jmp fetcheval

end:
  ret  

