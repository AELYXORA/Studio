/* X01 integrated candidate. Win64: RCX=Request32*, RDX=trusted callback, R8=context.
 * Request ref@0 table@8 size@16 align@20 kind@24 trusted tableBytes@28.
 * Table 8-byte header + 40-byte entries; gate embedded in entry@32.
 * Host must pin immutable table/arena for entire call. TEST ONLY.
 */
.intel_syntax noprefix
.text
.globl x01_with_typed_ref
x01_with_typed_ref:
 push rbx
 push rsi
 push rdi
 push r12
 push r13
 push r14
 push r15
 sub rsp,32
 xor r12d,r12d
 test rcx,rcx
 jz .done
 test rdx,rdx
 jz .done
 mov rbx,rcx
 mov rsi,rdx
 mov rdi,r8
 mov r13,[rbx]
 mov r15,[rbx+8]
 test r15,r15
 jz .done
 mov r10d,[rbx+28]
 cmp r10d,48
 jb .done
 mov rax,r13
 shr rax,32
 movzx r10d,ax
 test r10d,r10d
 jz .done
 cmp r10d,dword ptr [r15]
 ja .done
 cmp dword ptr [r15],65535
 ja .done
 mov r11d,[r15]
 imul r11,r11,40
 add r11,8
 mov eax,[rbx+28]
 cmp r11,rax
 ja .done
 dec r10d
 imul r10,r10,40
 lea r14,[r15+r10+8]
 lea rcx,[r14+32]
 call x01_borrow_try_acquire
 test eax,eax
 jz .done
 mov rax,r13
 shr rax,32
 cmp ax,word ptr [r14]
 jne .release
 shr rax,16
 test ax,ax
 jz .release
 cmp ax,word ptr [r14+2]
 jne .release
 cmp dword ptr [r14+4],1
 jne .release
 mov eax,[rbx+24]
 test eax,eax
 jz .release
 cmp eax,[r14+12]
 jne .release
 cmp qword ptr [r14+24],0
 je .release
 mov r8d,[rbx+16]
 test r8d,r8d
 jz .release
 mov r9d,[rbx+20]
 test r9d,r9d
 jz .release
 cmp r9d,4096
 ja .release
 mov r10d,r9d
 dec r10d
 test r10d,r9d
 jne .release
 mov r11d,r13d
 mov eax,[r14+8]
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
 add rsp,32
 pop r15
 pop r14
 pop r13
 pop r12
 pop rdi
 pop rsi
 pop rbx
 ret
