/* X01 sequential integration test: lifecycle + table resolver.
 * Win64 register calling convention, Linux process host for local run.
 * 1 valid leased resolve; retire blocked; stale after retire;
 * republish next generation; old ref rejected; new ref accepted.
 */
.intel_syntax noprefix
.data
.p2align 4
arena_mem: .zero 64
.p2align 3
arena_table:
 .long 1
 .long 0
arena_entry:
 .short 1
 .short 7
 .long 0
 .long 0
 .long 0
 .quad 0
 .quad 0
.text
.globl main
main:
 push rbx
 sub rsp,32
 lea rcx,[rip+arena_entry]
 mov edx,1
 lea r8,[rip+arena_mem]
 mov r9d,64
 call x01_entry_publish
 cmp eax,1
 jne .bad1
 lea rcx,[rip+arena_entry]
 call x01_entry_acquire
 cmp eax,1
 jne .bad2
 mov rcx,0x0007000100000010
 lea rdx,[rip+arena_table]
 mov r8d,8
 mov r9d,8
 call x01_resolve_table
 lea rbx,[rip+arena_mem+16]
 cmp rax,rbx
 jne .bad3
 lea rcx,[rip+arena_entry]
 call x01_entry_retire
 test eax,eax
 jne .bad4
 lea rcx,[rip+arena_entry]
 call x01_entry_release
 cmp eax,1
 jne .bad5
 lea rcx,[rip+arena_entry]
 call x01_entry_retire
 cmp eax,1
 jne .bad6
 mov rcx,0x0007000100000010
 lea rdx,[rip+arena_table]
 mov r8d,8
 mov r9d,8
 call x01_resolve_table
 test rax,rax
 jne .bad7
 lea rcx,[rip+arena_entry]
 mov edx,1
 lea r8,[rip+arena_mem]
 mov r9d,64
 call x01_entry_publish
 cmp eax,1
 jne .bad8
 lea rcx,[rip+arena_entry]
 call x01_entry_acquire
 cmp eax,1
 jne .bad9
 mov rcx,0x0007000100000010
 lea rdx,[rip+arena_table]
 mov r8d,8
 mov r9d,8
 call x01_resolve_table
 test rax,rax
 jne .bad10
 mov rcx,0x0008000100000010
 lea rdx,[rip+arena_table]
 mov r8d,8
 mov r9d,8
 call x01_resolve_table
 cmp rax,rbx
 jne .bad11
 lea rcx,[rip+arena_entry]
 call x01_entry_release
 cmp eax,1
 jne .bad12
 xor eax,eax
 jmp .done
.bad1: mov eax,1
 jmp .done
.bad2: mov eax,2
 jmp .done
.bad3: mov eax,3
 jmp .done
.bad4: mov eax,4
 jmp .done
.bad5: mov eax,5
 jmp .done
.bad6: mov eax,6
 jmp .done
.bad7: mov eax,7
 jmp .done
.bad8: mov eax,8
 jmp .done
.bad9: mov eax,9
 jmp .done
.bad10: mov eax,10
 jmp .done
.bad11: mov eax,11
 jmp .done
.bad12: mov eax,12
.done:
 add rsp,32
 pop rbx
 ret
.section .note.GNU-stack,"",@progbits
