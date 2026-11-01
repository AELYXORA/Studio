/* Linux pthread harness, Win64 register ABI for x01_borrow_* calls. */
.intel_syntax noprefix
.data
.p2align 3
gate: .quad 1
successes: .quad 0
rejections: .quad 0
failures: .quad 0
.bss
.p2align 3
threads: .zero 32
.text
.globl x01_thread_worker
x01_thread_worker:
 push rbx
 sub rsp,32
.loop:
 lea rcx,[rip+gate]
 call x01_borrow_try_acquire
 test eax,eax
 jz .reject
 lock inc qword ptr [rip+successes]
 lea rcx,[rip+gate]
 call x01_borrow_release
 test eax,eax
 jnz .loop
 lock inc qword ptr [rip+failures]
 jmp .loop
.reject:
 lock inc qword ptr [rip+rejections]
 xor eax,eax
 add rsp,32
 pop rbx
 ret
.globl main
main:
 push rbx
 push r12
 sub rsp,40
 xor ebx,ebx
.create:
 lea rdi,[rip+threads]
 lea rdi,[rdi+rbx*8]
 xor esi,esi
 lea rdx,[rip+x01_thread_worker]
 xor ecx,ecx
 call pthread_create@PLT
 test eax,eax
 jne .error1
 inc ebx
 cmp ebx,4
 jne .create
.spin:
 cmp qword ptr [rip+successes],100
 jae .ready
 pause
 jmp .spin
.ready:
 lea rcx,[rip+gate]
 call x01_borrow_begin_retire
 cmp eax,1
 jne .error2
 xor ebx,ebx
.join:
 lea rax,[rip+threads]
 mov rdi,[rax+rbx*8]
 xor esi,esi
 call pthread_join@PLT
 test eax,eax
 jne .error3
 inc ebx
 cmp ebx,4
 jne .join
 lea rcx,[rip+gate]
 call x01_borrow_try_finish_retire
 cmp eax,1
 jne .error4
 cmp qword ptr [rip+gate],0
 jne .error5
 cmp qword ptr [rip+failures],0
 jne .error6
 cmp qword ptr [rip+successes],0
 je .error7
 cmp qword ptr [rip+rejections],0
 je .error8
 lea rcx,[rip+gate]
 call x01_borrow_try_acquire
 test eax,eax
 jne .error9
 xor eax,eax
 jmp .done
.error1: mov eax,1
 jmp .done
.error2: mov eax,2
 jmp .done
.error3: mov eax,3
 jmp .done
.error4: mov eax,4
 jmp .done
.error5: mov eax,5
 jmp .done
.error6: mov eax,6
 jmp .done
.error7: mov eax,7
 jmp .done
.error8: mov eax,8
 jmp .done
.error9: mov eax,9
.done:
 add rsp,40
 pop r12
 pop rbx
 ret
.section .note.GNU-stack,"",@progbits
