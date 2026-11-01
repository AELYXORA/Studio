/* Executable Win64-call-ABI harness for x01_with_typed_ref. */
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
gate: .quad 1
request: .quad 0x0007000100000000,table
.long 8,8,9,48
calls: .quad 0
.text
.globl callback
callback:
 cmp qword ptr [rcx],42
 jne .bad
 inc qword ptr [rip+calls]
 mov eax,23
 ret
.bad: xor eax,eax
 ret
.globl main
main:
 push rbx
 sub rsp,32
 lea rcx,[rip+request]
 lea rdx,[rip+callback]
 xor r8d,r8d
 call x01_with_typed_ref
 cmp eax,23
 jne .fail1
 mov dword ptr [rip+request+28],47
 call .check_reject
 test eax,eax
 jne .fail2
 mov dword ptr [rip+request+28],48
 mov dword ptr [rip+request+24],8
 call .check_reject
 test eax,eax
 jne .fail3
 mov dword ptr [rip+request+24],9
 mov word ptr [rip+table+10],8
 call .check_reject
 test eax,eax
 jne .fail4
 mov word ptr [rip+table+10],7
 lea rcx,[rip+gate]
 call x01_borrow_begin_retire
 cmp eax,1
 jne .fail5
 call .check_reject
 test eax,eax
 jne .fail6
 cmp qword ptr [rip+calls],1
 jne .fail7
 cmp qword ptr [rip+gate],2
 jne .fail8
 xor eax,eax
 jmp .done
.check_reject:
 lea rcx,[rip+request]
 lea rdx,[rip+callback]
 xor r8d,r8d
 call x01_with_typed_ref
 ret
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
.done:
 add rsp,32
 pop rbx
 ret
