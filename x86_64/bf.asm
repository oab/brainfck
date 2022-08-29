default rel    
; the brainf*ck interpreter
;
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
        
extern _main
global _codebuffer
global _evalbf
	
extern _putchar
extern _getchar

section .data
bfdata: times SLOTS db 0

section .bss
_codebuffer: resb MAX_CODESIZE

section .rodata

jmptable:  
  dq incp                       ; 0 >
  dq decp                       ; 1 <
  dq incv                       ; 2 +
  dq decv                       ; 3 -
  dq outv                       ; 4 .
  dq inv                        ; 5 ,
  dq lpb                        ; 6 [
  dq lpe                        ; 7 ]
  dq end                        ; 8 end

section .text

; the brainf*ck machine
; keep the data pointer      (DP) in  rbx
; keep instruction pointer   (IP) in  rcx

_evalbf:    
  mov rcx,0           ; init. IP
  mov rbx,0           ; init. DP
  jmp fetcheval       ; start interpreter loop
  
fetcheval:
  lea rdx, [_codebuffer]	
  movzx rax,byte [rdx+rcx]
  inc rcx
  lea rdx, [jmptable]
  jmp [rdx+8*rax]
 
incv:
  lea rdx, [bfdata]
  movzx rax,byte [rdx+rbx]
  inc rax
  lea rdx, [bfdata]	
  mov [rdx+rbx],rax
  jmp fetcheval

decv:
  lea rdx, [bfdata]
  movzx rax,byte [rdx+rbx]
  dec rax
  lea rdx, [bfdata]	
  mov [rdx+rbx],rax
  jmp fetcheval

incp:
  inc rbx
  jmp fetcheval

decp:
  dec rbx
  jmp fetcheval

outv:
  lea rdx, [bfdata]	
  movzx rdi,byte [rdx+rbx]
  push rbx
  push rcx
  call _putchar
  pop rcx
  pop rbx
  jmp fetcheval

inv:
  push rbx
  push rcx
  call _getchar
  lea rdx, [bfdata]
  mov [rdx+rbx],rax
  pop rcx
  pop rbx
  jmp fetcheval

lpb:
  lea rdx, [bfdata]
  movzx rax,byte [rdx+rbx]
  cmp rax,0
  jnz .nzero
  lea rdx, [_codebuffer]	
  movzx rax,byte [rdx+rcx]          ; fetch displacement
  sub rcx,1                         ; adjust to [
  add rcx,rax                       ; relative forward jump when DP is zero
  jmp fetcheval
.nzero:
  add rcx,1                         ; skip displacement byte          
  jmp fetcheval

lpe:
  lea rdx, [bfdata]
  movzx rax,byte [rdx+rbx]
  cmp rax,0
  jz .zero
  lea rdx, [_codebuffer]	
  movzx rax,byte [rdx+rcx]          ; fetch displacement
  sub rcx,1                         ; adjust to ]
  sub rcx,rax                       ; relative backward jump when DP is nonzero
  jmp fetcheval
.zero:
  add rcx,1                         ; skip displacement byte          
  jmp fetcheval

end:
  ret

