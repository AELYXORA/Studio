.intel_syntax noprefix
.data
.p2align 4
bytes: .zero 64
.p2align 3
table:
.long 1
.long 0
.short 1
.short 2
.long 1
.long 64
.long 7
.quad bytes
.quad 1
.text
.globl main
main:
 push rbx
 sub rsp,32
 mov rcx,0x0002000100000010
 lea rdx,[rip+table]
 mov r8d,8
 mov r9d,8
 call x01_resolve_table
 lea rbx,[rip+bytes+16]
 cmp rax,rbx
 jne .f1
 mov rcx,0x0001000100000010
 lea rdx,[rip+table]
 mov r8d,8
 mov r9d,8
 call x01_resolve_table
 test rax,rax
 jne .f2
 mov rcx,0x0002000200000010
 lea rdx,[rip+table]
 mov r8d,8
 mov r9d,8
 call x01_resolve_table
 test rax,rax
 jne .f3
 mov rcx,0x000200010000003c
 lea rdx,[rip+table]
 mov r8d,8
 mov r9d,8
 call x01_resolve_table
 test rax,rax
 jne .f4
 mov qword ptr [rip+table+32],0
 mov rcx,0x0002000100000010
 lea rdx,[rip+table]
 mov r8d,8
 mov r9d,8
 call x01_resolve_table
 test rax,rax
 jne .f5
 xor eax,eax
 jmp .end
.f1: mov eax,1
 jmp .end
.f2: mov eax,2
 jmp .end
.f3: mov eax,3
 jmp .end
.f4: mov eax,4
 jmp .end
.f5: mov eax,5
.end:
 add rsp,32
 pop rbx
 ret
.section .note.GNU-stack,"",@progbits
