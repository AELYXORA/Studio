/* Native x64 assembly test for bound gate; Win64 registers. */
.intel_syntax noprefix
.data
.p2align 4
memory: .quad 42,0,0,0,0,0,0,0
.p2align 3
table:
.long 1,0
.short 1,7
.long 1
.long 64
.long 9
.quad memory
.quad 1
GATE: .quad 1
request:
.quad 0x0007000100000000,table
.long 8,8
calls: .quad 0
.text
.globl callback
callback:
 push rbx
 sub rsp,32
 cmp qword ptr [rcx],42
 jne .bad
 inc qword ptr [rip+calls]
 lea rcx,[rip+GATE]
 call x01_borrow_begin_retire
 cmp eax,1
 jne .bad
 lea rcx,[rip+GATE]
 call x01_borrow_try_finish_retire
 test eax,eax
 jne .bad
 mov eax,21
 jmp .end
.bad: xor eax,eax
.end:
 add rsp,32
 pop rbx
 ret
.globl main
main:
 push rbx
 sub rsp,32
 lea rcx,[rip+request]
 lea rdx,[rip+callback]
 xor r8d,r8d
 call x01_with_bound_ref
 cmp eax,21
 jne .f1
 cmp qword ptr [rip+GATE],2
 jne .f2
 cmp qword ptr [rip+calls],1
 jne .f3
 lea rcx,[rip+request]
 lea rdx,[rip+callback]
 xor r8d,r8d
 call x01_with_bound_ref
 test eax,eax
 jne .f4
 lea rcx,[rip+GATE]
 call x01_borrow_try_finish_retire
 cmp eax,1
 jne .f5
 mov qword ptr [rip+GATE],1
 mov word ptr [rip+table+10],8
 lea rcx,[rip+request]
 lea rdx,[rip+callback]
 xor r8d,r8d
 call x01_with_bound_ref
 test eax,eax
 jne .f6
 cmp qword ptr [rip+calls],1
 jne .f7
 xor eax,eax
 jmp .done
.f1:mov eax,1
 jmp .done
.f2:mov eax,2
 jmp .done
.f3:mov eax,3
 jmp .done
.f4:mov eax,4
 jmp .done
.f5:mov eax,5
 jmp .done
.f6:mov eax,6
 jmp .done
.f7:mov eax,7
.done:
 add rsp,32
 pop rbx
 ret
