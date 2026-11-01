.intel_syntax noprefix
.data
.p2align 4
bytes: .quad 42,0,0,0,0,0,0,0
.p2align 3
gate: .quad 1
counter: .quad 0
table: .long 1,0
.short 1,7
.long 1
.long 64
.long 0
.quad bytes
.quad 1
.p2align 3
request: .quad 0x0007000100000000,table,gate
.long 8,8
.text
.globl test_callback
test_callback:
 push rbx
 sub rsp,32
 mov rbx,rcx
 cmp qword ptr [rbx],42
 jne .bad
 inc qword ptr [rip+counter]
 lea rcx,[rip+gate]
 call x01_borrow_begin_retire
 cmp eax,1
 jne .bad
 lea rcx,[rip+gate]
 call x01_borrow_try_finish_retire
 test eax,eax
 jne .bad
 mov eax,19
 jmp .done
.bad: xor eax,eax
.done:
 add rsp,32
 pop rbx
 ret
.globl main
main:
 push rbx
 sub rsp,32
 lea rcx,[rip+request]
 lea rdx,[rip+test_callback]
 xor r8d,r8d
 call x01_with_resolved_ref
 cmp eax,19
 jne .fail1
 cmp qword ptr [rip+counter],1
 jne .fail2
 cmp qword ptr [rip+gate],2
 jne .fail3
 lea rcx,[rip+request]
 lea rdx,[rip+test_callback]
 xor r8d,r8d
 call x01_with_resolved_ref
 test eax,eax
 jne .fail4
 cmp qword ptr [rip+counter],1
 jne .fail5
 lea rcx,[rip+gate]
 call x01_borrow_try_finish_retire
 cmp eax,1
 jne .fail6
 cmp qword ptr [rip+gate],0
 jne .fail7
 xor eax,eax
 jmp .end
.fail1:mov eax,1
 jmp .end
.fail2:mov eax,2
 jmp .end
.fail3:mov eax,3
 jmp .end
.fail4:mov eax,4
 jmp .end
.fail5:mov eax,5
 jmp .end
.fail6:mov eax,6
 jmp .end
.fail7:mov eax,7
.end:
 add rsp,32
 pop rbx
 ret
