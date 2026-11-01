/* X01 checked table request preflight; Win64 RCX=request*, EAX=1 valid.
 * Request: Ref64@0, tablePtr@8, bytes@16, align@20, expectedKind@24, tableBytes@28.
 * Trusted host pins immutable table and backing arena for the entire operation.
 * This preflight is NOT a lock or a safe borrowing capability.
 */
.intel_syntax noprefix
.text
.globl x01_validate_bound_request
x01_validate_bound_request:
 test rcx,rcx
 jz .bad
 mov rdx,[rcx+8]
 test rdx,rdx
 jz .bad
 mov r8d,[rcx+28]
 cmp r8d,48
 jb .bad
 sub r8d,8
 mov eax,r8d
 xor edx,edx
 mov r9d,40
 div r9d
 mov r10,[rcx+8]
 mov r11d,[r10]
 test r11d,r11d
 jz .bad
 cmp r11d,eax
 ja .bad
 mov rax,[rcx]
 mov r8,rax
 shr r8,32
 movzx edx,r8w
 test edx,edx
 jz .bad
 cmp edx,r11d
 ja .bad
 dec edx
 imul rdx,rdx,40
 lea rdx,[r10+rdx+8]
 cmp r8w,word ptr [rdx]
 jne .bad
 shr r8,16
 test r8w,r8w
 jz .bad
 cmp r8w,word ptr [rdx+2]
 jne .bad
 cmp dword ptr [rdx+4],1
 jne .bad
 mov r9d,[rcx+24]
 test r9d,r9d
 jz .bad
 cmp r9d,[rdx+12]
 jne .bad
 mov r9d,[rcx+16]
 test r9d,r9d
 jz .bad
 mov r10d,[rcx+20]
 test r10d,r10d
 jz .bad
 cmp r10d,4096
 ja .bad
 lea r11d,[r10-1]
 test r11d,r10d
 jne .bad
 mov r8d,dword ptr [rcx]
 mov eax,[rdx+8]
 cmp r8d,eax
 ja .bad
 sub eax,r8d
 cmp r9d,eax
 ja .bad
 test r8d,r11d
 jne .bad
 mov rax,[rdx+16]
 test rax,rax
 jz .bad
 test rax,r11
 jne .bad
 mov r10,[rdx+24]
 test r10,r10
 jz .bad
 mov rax,[rdx+32]
 cmp eax,1
 jne .bad
 mov eax,1
 ret
.bad:
 xor eax,eax
 ret
