.intel_syntax noprefix
.data
.p2align 4
mem: .zero 64
.p2align 3
entry:
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
 lea rcx,[rip+entry]
 mov edx,1
 lea r8,[rip+mem]
 mov r9d,64
 call x01_entry_publish
 cmp eax,1
 jne .fail1
 lea rcx,[rip+entry]
 call x01_entry_acquire
 cmp eax,1
 jne .fail2
 lea rcx,[rip+entry]
 call x01_entry_retire
 test eax,eax
 jne .fail3
 lea rcx,[rip+entry]
 call x01_entry_release
 cmp eax,1
 jne .fail4
 lea rcx,[rip+entry]
 call x01_entry_retire
 cmp eax,1
 jne .fail5
 cmp word ptr [rip+entry+2],8
 jne .fail6
 cmp dword ptr [rip+entry+4],0
 jne .fail7
 lea rcx,[rip+entry]
 call x01_entry_release
 test eax,eax
 jne .fail8
 lea rcx,[rip+entry]
 mov edx,1
 lea r8,[rip+mem]
 mov r9d,64
 call x01_entry_publish
 cmp eax,1
 jne .fail9
 cmp word ptr [rip+entry+2],8
 jne .fail10
 xor eax,eax
 jmp .done
.fail1: mov eax,1
 jmp .done
.fail2: mov eax,2
 jmp .done
.fail3: mov eax,3
 jmp .done
.fail4: mov eax,4
 jmp .done
.fail5: mov eax,5
 jmp .done
.fail6: mov eax,6
 jmp .done
.fail7: mov eax,7
 jmp .done
.fail8: mov eax,8
 jmp .done
.fail9: mov eax,9
 jmp .done
.fail10: mov eax,10
.done:
 add rsp,32
 pop rbx
 ret
.section .note.GNU-stack,"",@progbits
