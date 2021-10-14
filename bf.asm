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

SLOTS: equ 128
MAX_CODESIZE: equ 256
MAX_BRACKETS: equ 128
        
global main
global codebuffer
global evalbf
extern putchar
extern getchar

section .data
bfdata: times SLOTS db 0

section .bss
codebuffer: resb MAX_CODESIZE

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
; keep the data pointer      (DP) in  ebx
; keep instruction pointer   (IP) in  ecx

evalbf:
  push ebp
  mov ebp, esp      
  mov ecx,0           ; init. IP
  mov ebx,0           ; init. DP
  jmp fetcheval       ; start interpreter loop
  
fetcheval:
  movzx eax,byte [codebuffer+ecx]
  inc ecx
  jmp [jmptable+(4)*eax]            
  jmp fetcheval
 
incv:
  movzx eax,byte [bfdata+ebx]
  inc eax
  mov [bfdata+ebx],al
  jmp fetcheval

decv:
  movzx eax,byte [bfdata+ebx]
  dec eax
  mov [bfdata+ebx],al
  jmp fetcheval

incp:
  inc ebx
  jmp fetcheval

decp:
  dec ebx
  jmp fetcheval

outv:
  movzx eax,byte [bfdata+ebx]
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
  mov [bfdata+ebx],al
  mov esp,ebp
  pop ebp 
  pop ecx
  pop ebx
  jmp fetcheval

lpb:
  movzx eax,byte [bfdata+ebx]
  cmp eax,0
  jnz .nzero
  movzx eax,byte [codebuffer+ecx]   ; fetch displacement
  sub ecx,1                         ; adjust to [
  add ecx,eax                       ; relative forward jump when DP is zero
  jmp fetcheval
.nzero:
  add ecx,1                         ; skip displacement byte          
  jmp fetcheval

lpe:
  movzx eax,byte [bfdata+ebx]
  cmp eax,0
  jz .zero
  movzx eax,byte [codebuffer+ecx]   ; fetch displacement
  sub ecx,1                         ; adjust to ]
  sub ecx,eax                       ; relative backward jump when DP is nonzero
  jmp fetcheval
.zero:
  add ecx,1                         ; skip displacement byte          
  jmp fetcheval


end:
  pop ebp      
  ret  

