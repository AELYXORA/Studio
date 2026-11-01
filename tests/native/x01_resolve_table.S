/* Win64 register ABI: RCX ref, RDX table pointer, R8D requested bytes, R9D alignment.
   Table: count u32@0, reserved u32@4, entries begin @8; 32B entry indexed by arenaIndex-1.
   Entry: index u16, generation u16, state u32 (1 sealed), committed u32,
   kind u32, base u64, leaseCount u64. Host must pin whole table and backing arenas.
*/
.intel_syntax noprefix
.text
.globl x01_resolve_table
x01_resolve_table:
 test rcx,rcx
 jz .bad
 test rdx,rdx
 jz .bad
 test r8d,r8d
 jz .bad
 test r9d,r9d
 jz .bad
 cmp r9d,4096
 ja .bad
 lea r10d,[r9d-1]
 test r10d,r9d
 jnz .bad
 mov r10,rcx
 shr r10,32
 movzx r11d,r10w
 test r11d,r11d
 jz .bad
 cmp r11d,dword ptr [rdx]
 ja .bad
 mov rax,rdx
 mov r10d,r11d
 dec r10d
 shl r10,5
 lea rax,[rax+r10+8]
 cmp r11w,word ptr [rax]
 jne .bad
 mov r10,rcx
 shr r10,48
 test r10w,r10w
 jz .bad
 cmp r10w,word ptr [rax+2]
 jne .bad
 cmp dword ptr [rax+4],1
 jne .bad
 cmp qword ptr [rax+24],0
 je .bad
 mov r10d,ecx
 mov r11d,dword ptr [rax+8]
 cmp r10d,r11d
 ja .bad
 sub r11d,r10d
 cmp r8d,r11d
 ja .bad
 mov r11d,r9d
 dec r11d
 test r10d,r11d
 jnz .bad
 mov rax,qword ptr [rax+16]
 test rax,rax
 jz .bad
 test rax,r11
 jnz .bad
 add rax,r10
 jc .bad
 ret
.bad:
 xor eax,eax
 ret
