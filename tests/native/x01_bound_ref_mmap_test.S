/* Linux pthread + mmap test, Win64 ABI for X01 callback and borrow. */
.intel_syntax noprefix
.data
.p2align 3
arena_table:
.long 1,0
.short 1,7
.long 1
.long 4096
.long 9
.quad 0
.quad 1
gate: .quad 1
request: .quad 0x0007000100000000,arena_table
.long 8,8
.p2align 3
entered: .quad 0
resume_flag: .quad 0
callback_result: .quad 0
thread_id: .quad 0
allocation: .quad 0
.text
.globl test_cb
test_cb:
 cmp qword ptr [rcx],0x12345678
 jne .cbfail
 mov qword ptr [rip+entered],1
.cbwait:
 cmp qword ptr [rip+resume_flag],1
 je .cbend
 pause
 jmp .cbwait
.cbend:
 cmp qword ptr [rcx],0x12345678
 jne .cbfail
 mov eax,77
 ret
.cbfail: xor eax,eax
 ret
.globl worker
worker:
 push rbx
 sub rsp,32
 lea rcx,[rip+request]
 lea rdx,[rip+test_cb]
 xor r8d,r8d
 call x01_with_bound_ref
 mov qword ptr [rip+callback_result],rax
 xor eax,eax
 add rsp,32
 pop rbx
 ret
.globl main
main:
 push rbx
 sub rsp,32
 /* mmap(NULL,4096,PROT_READ|PROT_WRITE,MAP_PRIVATE|MAP_ANONYMOUS,-1,0) */
 xor edi,edi
 mov esi,4096
 mov edx,3
 mov ecx,34
 mov r8d,-1
 xor r9d,r9d
 call mmap@PLT
 cmp rax,-1
 je .fail1
 mov [rip+allocation],rax
 mov qword ptr [rax],0x12345678
 mov [rip+arena_table+24],rax
 lea rdi,[rip+thread_id]
 xor esi,esi
 lea rdx,[rip+worker]
 xor ecx,ecx
 call pthread_create@PLT
 test eax,eax
 jne .fail2
.wait:
 cmp qword ptr [rip+entered],1
 je .retire
 pause
 jmp .wait
.retire:
 lea rcx,[rip+gate]
 call x01_borrow_begin_retire
 cmp eax,1
 jne .fail3
 lea rcx,[rip+gate]
 call x01_borrow_try_finish_retire
 test eax,eax
 jne .fail4
 lea rcx,[rip+request]
 lea rdx,[rip+test_cb]
 xor r8d,r8d
 call x01_with_bound_ref
 test eax,eax
 jne .fail5
 mov qword ptr [rip+resume_flag],1
 mov rdi,[rip+thread_id]
 xor esi,esi
 call pthread_join@PLT
 test eax,eax
 jne .fail6
 cmp qword ptr [rip+callback_result],77
 jne .fail7
 lea rcx,[rip+gate]
 call x01_borrow_try_finish_retire
 cmp eax,1
 jne .fail8
 mov rdi,[rip+allocation]
 mov esi,4096
 call munmap@PLT
 test eax,eax
 jne .fail9
 mov qword ptr [rip+arena_table+24],0
 lea rcx,[rip+request]
 lea rdx,[rip+test_cb]
 xor r8d,r8d
 call x01_with_bound_ref
 test eax,eax
 jne .fail10
 xor eax,eax
 jmp .done
.fail1:mov eax,1
 jmp .done
.fail2:mov eax,2
 jmp .done
.fail3:mov eax,3
 jmp .done
.fail4:mov eax,4
 jmp .done
.fail5:mov eax,5
 jmp .done
.fail6:mov eax,6
 jmp .done
.fail7:mov eax,7
 jmp .done
.fail8:mov eax,8
 jmp .done
.fail9:mov eax,9
 jmp .done
.fail10:mov eax,10
.done:
 add rsp,32
 pop rbx
 ret
.section .note.GNU-stack,"",@progbits
