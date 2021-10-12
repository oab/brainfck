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
  dd incp                       ; 0 >
  dd decp                       ; 1 <
  dd incv                       ; 2 +
  dd decv                       ; 3 -
  dd outv                       ; 4 .
  dd inv                        ; 5 ,
  dd lpb                        ; 6 [
  dd lpe                        ; 7 ]
  dd end                        ; 8 end


section .text

; the brainf*ck machine
; keep the data pointer    in  eax
; keep instruction pointer in  ecx


evalbf:
  push ebp
  mov ebp, esp      
  mov ecx,codebuffer ; init. instruction pointer
  mov ebx,bfdata     ; init. data pointer
  jmp fetcheval      ; start interpreter
  
fetcheval:
  movzx eax,byte [ecx]
  inc ecx
  jmp [jmptable+(4)*eax]            
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
  push ebx
  push ecx      
  push ebp
  mov ebp, esp
  push eax      
  call putchar
  add esp,4
  mov esp,ebp
  pop ebp
  pop ecx
  pop ebx      

  jmp fetcheval

inv:
  push ebx
  push ecx
        
  push ebp
  mov ebp, esp     
  call getchar        
  mov [ebx],al
  mov esp,ebp
  pop ebp 
  pop ecx
  pop ebx
  jmp fetcheval

lpb:
  jmp fetcheval

lpe:
  jmp fetcheval

end:
  pop ebp      
  ret  

