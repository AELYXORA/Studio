/* X01 atomic borrow gate sequential validation, Assembly-only.
 * Win64 argument registers and 32-byte shadow space.
 * Linux x86-64 executable; also cross-assemblable as Win64 COFF.
 */
.intel_syntax noprefix
.data
.p2align 3
gate: .quad 1
.text
.globl main
main:
 push rbx
 sub rsp,32
 lea rcx,[rip+gate]
 call x01_borrow_try_acquire
 cmp eax,1
 jne .f1
 mov rbx,0x100000001
 cmp qword ptr [rip+gate],rbx
 jne .f2
 lea rcx,[rip+gate]
 call x01_borrow_begin_retire
 cmp eax,1
 jne .f3
 lea rcx,[rip+gate]
 call x01_borrow_try_acquire
 test eax,eax
 jne .f4
 lea rcx,[rip+gate]
 call x01_borrow_try_finish_retire
 test eax,eax
 jne .f5
 lea rcx,[rip+gate]
 call x01_borrow_release
 cmp eax,1
 jne .f6
 lea rcx,[rip+gate]
 call x01_borrow_try_finish_retire
 cmp eax,1
 jne .f7
 cmp qword ptr [rip+gate],0
 jne .f8
 xor eax,eax
 jmp .done
.f1: mov eax,1
 jmp .done
.f2: mov eax,2
 jmp .done
.f3: mov eax,3
 jmp .done
.f4: mov eax,4
 jmp .done
.f5: mov eax,5
 jmp .done
.f6: mov eax,6
 jmp .done
.f7: mov eax,7
 jmp .done
.f8: mov eax,8
.done:
 add rsp,32
 pop rbx
 ret
