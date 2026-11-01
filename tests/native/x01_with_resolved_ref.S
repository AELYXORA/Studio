/* Experimental callback-scoped borrow, Win64 ABI.
 RCX=request*, RDX=trusted callback*, R8=context*; RAX=callback result/0.
 request: Ref64@0, pinned tablePtr@8, pinned gatePtr@16, bytes:u32@24, align:u32@28.
 Callback must not escape pointers, reenter arena manager, throw/unwind or invoke untrusted code.
 The host must pin table and allocation; this is NOT a production capability boundary.
 */
.intel_syntax noprefix
.text
.globl x01_with_resolved_ref
x01_with_resolved_ref:
 push rbx
 push rsi
 push rdi
 push r12
 push r13
 sub rsp,32
 xor r12d,r12d
 test rcx,rcx
 jz .done
 test rdx,rdx
 jz .done
 mov rbx,rcx
 mov rsi,rdx
 mov rdi,r8
 mov r13,qword ptr [rbx+16]
 test r13,r13
 jz .done
 mov rcx,r13
 call x01_borrow_try_acquire
 test eax,eax
 jz .done
 mov rcx,qword ptr [rbx]
 mov rdx,qword ptr [rbx+8]
 mov r8d,dword ptr [rbx+24]
 mov r9d,dword ptr [rbx+28]
 call x01_resolve_table
 test rax,rax
 jz .release
 mov rcx,rax
 mov rdx,rdi
 call rsi
 mov r12,rax
.release:
 mov rcx,r13
 call x01_borrow_release
 test eax,eax
 jnz .done
 xor r12d,r12d
.done:
 mov rax,r12
 add rsp,32
 pop r13
 pop r12
 pop rdi
 pop rsi
 pop rbx
 ret
