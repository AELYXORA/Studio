/* Linux pthread integration harness, Win64 ABI for all X01 functions.
 * Main waits for callback entry, begins retire, verifies pin blocks finish,
 * refuses a new callback, releases original callback, joins, then retires.
 */
.intel_syntax noprefix
.data
.p2align 4
backing: .quad 0x12345678,0,0,0,0,0,0,0
.p2align 3
arena_table:
.long 1,0
.short 1,7
.long 1
.long 64
.long 9
.quad backing
.quad 1
gate: .quad 1
req: .quad 0x0007000100000000,arena_table
.long 8,8
.p2align 3
entered: .quad 0
resume: .quad 0
cb_result: .quad 0
thread_id: .quad 0
.text
.globl x01_test_callback
x01_test_callback:
 cmp qword ptr [rcx],0x12345678
 jne .cb_bad
 mov qword ptr [rip+entered],1
.cb_spin:
 cmp qword ptr [rip+resume],1
 je .cb_end
 pause
 jmp .cb_spin
.cb_end:
 cmp qword ptr [rcx],0x12345678
 jne .cb_bad
 mov eax,91
 ret
.cb_bad:
 xor eax,eax
 ret
.globl x01_worker
x01_worker:
 push rbx
 sub rsp,32
 lea rcx,[rip+req]
 lea rdx,[rip+x01_test_callback]
 xor r8d,r8d
 call x01_with_bound_ref
 mov qword ptr [rip+cb_result],rax
 xor eax,eax
 add rsp,32
 pop rbx
 ret
.globl main
main:
 push rbx
 sub rsp,32
 lea rdi,[rip+thread_id]
 xor esi,esi
 lea rdx,[rip+x01_worker]
 xor ecx,ecx
 call pthread_create@PLT
 test eax,eax
 jne .err1
.wait_enter:
 cmp qword ptr [rip+entered],1
 je .retire
 pause
 jmp .wait_enter
.retire:
 lea rcx,[rip+gate]
 call x01_borrow_begin_retire
 cmp eax,1
 jne .err2
 lea rcx,[rip+gate]
 call x01_borrow_try_finish_retire
 test eax,eax
 jne .err3
 lea rcx,[rip+req]
 lea rdx,[rip+x01_test_callback]
 xor r8d,r8d
 call x01_with_bound_ref
 test eax,eax
 jne .err4
 mov qword ptr [rip+resume],1
 mov rdi,qword ptr [rip+thread_id]
 xor esi,esi
 call pthread_join@PLT
 test eax,eax
 jne .err5
 cmp qword ptr [rip+cb_result],91
 jne .err6
 lea rcx,[rip+gate]
 call x01_borrow_try_finish_retire
 cmp eax,1
 jne .err7
 cmp qword ptr [rip+gate],0
 jne .err8
 xor eax,eax
 jmp .done
.err1:mov eax,1
 jmp .done
.err2:mov eax,2
 jmp .done
.err3:mov eax,3
 jmp .done
.err4:mov eax,4
 jmp .done
.err5:mov eax,5
 jmp .done
.err6:mov eax,6
 jmp .done
.err7:mov eax,7
 jmp .done
.err8:mov eax,8
.done:
 add rsp,32
 pop rbx
 ret
.section .note.GNU-stack,"",@progbits
