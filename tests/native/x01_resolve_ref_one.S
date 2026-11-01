/* X01 ResolveRef one-entry candidate, Win64 ABI, no OS calls.
 * RCX=Ref64, RDX=trusted host-owned ArenaEntry*,
 * R8D=requested bytes (>0), R9D=power-of-two alignment (1..4096).
 * RAX=resolved pointer or zero.
 * ArenaEntry (32B): index u16@0, generation u16@2,
 * state u32@4 (1=sealed), committed u32@8, kind u32@12,
 * baseAddress u64@16, leaseCount u64@24.
 * Host must pin/snapshot descriptor and prevent concurrent retirement.
 */
.intel_syntax noprefix
.text
.p2align 4
.globl x01_resolve_ref_one
x01_resolve_ref_one:
  test rcx,rcx
  jz .Lbad
  test rdx,rdx
  jz .Lbad
  test r8d,r8d
  jz .Lbad
  test r9d,r9d
  jz .Lbad
  cmp r9d,4096
  ja .Lbad
  lea r10d,[r9d-1]
  test r10d,r9d
  jnz .Lbad
  mov r10,rcx
  shr r10,32
  movzx eax,r10w
  test eax,eax
  jz .Lbad
  cmp ax,word ptr [rdx]
  jne .Lbad
  shr r10,16
  movzx eax,r10w
  test eax,eax
  jz .Lbad
  cmp ax,word ptr [rdx+2]
  jne .Lbad
  cmp dword ptr [rdx+4],1
  jne .Lbad
  cmp qword ptr [rdx+24],0
  je .Lbad
  mov r10d,ecx
  mov eax,dword ptr [rdx+8]
  cmp r10d,eax
  ja .Lbad
  sub eax,r10d
  cmp r8d,eax
  ja .Lbad
  mov eax,r10d
  dec r9d
  test eax,r9d
  jnz .Lbad
  mov rax,qword ptr [rdx+16]
  test rax,rax
  jz .Lbad
  test rax,r9
  jnz .Lbad
  add rax,r10
  jc .Lbad
  ret
.Lbad:
  xor eax,eax
  ret
