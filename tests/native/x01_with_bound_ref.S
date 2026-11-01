/* X01 bound gate to arena entry, Win64 ABI.
 RCX=request*, RDX=trusted callback*, R8=context*; RAX=result/0.
 Request: ref u64@0, pinnedTable*@8, bytes:u32@16, align:u32@20.
 Table: count u32@0, reserved@4, records 40 bytes from +8.
 Entry: index:u16@0 gen:u16@2 state:u32@4 committed:u32@8,
 kind:u32@12 base:u64@16 ownerLease:u64@24 gate:u64@32.
 Host must pin table and backing allocations. Not a production trust boundary.
 */
.intel_syntax noprefix
.text
.globl x01_with_bound_ref
x01_with_bound_ref:
 push rbx
 push rsi
 push rdi
 push r12
 push r13
 push r14
 sub rsp,40
 xor r12d,r12d
 test rcx,rcx
 jz .done
 test rdx,rdx
 jz .done
 mov rbx,rcx
 mov rsi,rdx
 mov rdi,r8
 mov rax,[rbx]
 mov r13,rax
 shr rax,32
 movzx r10d,ax
 test r10d,r10d
 jz .done
 mov r14,[rbx+8]
 test r14,r14
 jz .done
 cmp r10d,dword ptr [r14]
 ja .done
 dec r10d
 imul r10,r10,40
 lea r14,[r14+r10+8]
 lea rcx,[r14+32]
 call x01_borrow_try_acquire
 test eax,eax
 jz .done
 mov rax,r13
 shr rax,32
 cmp ax,word ptr [r14]
 jne .release
 shr rax,16
 cmp ax,word ptr [r14+2]
 jne .release
 cmp dword ptr [r14+4],1
 jne .release
 cmp qword ptr [r14+24],0
 je .release
 mov r8d,dword ptr [rbx+16]
 test r8d,r8d
 jz .release
 mov r9d,dword ptr [rbx+20]
 test r9d,r9d
 jz .release
 cmp r9d,4096
 ja .release
 mov r10d,r9d
 dec r10d
 test r10d,r9d
 jne .release
 mov r11d,r13d
 mov eax,dword ptr [r14+8]
 cmp r11d,eax
 ja .release
 sub eax,r11d
 cmp r8d,eax
 ja .release
 test r11d,r10d
 jne .release
 mov rax,[r14+16]
 test rax,rax
 jz .release
 test rax,r10
 jne .release
 add rax,r11
 jc .release
 mov rcx,rax
 mov rdx,rdi
 call rsi
 mov r12,rax
.release:
 lea rcx,[r14+32]
 call x01_borrow_release
 test eax,eax
 jnz .done
 xor r12d,r12d
.done:
 mov rax,r12
 add rsp,40
 pop r14
 pop r13
 pop r12
 pop rdi
 pop rsi
 pop rbx
 ret
