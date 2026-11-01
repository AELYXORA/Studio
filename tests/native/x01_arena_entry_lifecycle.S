/* X01 prototype arena entry lifecycle. Single-threaded pinned host-owned entry.
 * Entry 32 B: index:u16 gen:u16 state:u32 committed:u32 kind:u32
 * base:u64 leaseCount:u64. State 0=vacant,1=sealed,2=retired.
 * All functions use Win64 argument registers. No allocation/locking.
 */
.intel_syntax noprefix
.text
.globl x01_entry_publish
/* RCX=entry*, EDX=expected index, R8=base*, R9D=committed.
 * EAX=1 on publish; entry must be vacant, generation nonzero.
 * Caller owns the base allocation and pins it.
 */
x01_entry_publish:
 test rcx,rcx
 jz .Lpubbad
 test edx,edx
 jz .Lpubbad
 cmp edx,65535
 ja .Lpubbad
 test r8,r8
 jz .Lpubbad
 test r9d,r9d
 jz .Lpubbad
 cmp dword ptr [rcx+4],0
 jne .Lpubbad
 cmp word ptr [rcx],dx
 jne .Lpubbad
 cmp word ptr [rcx+2],0
 je .Lpubbad
 cmp qword ptr [rcx+24],0
 jne .Lpubbad
 mov dword ptr [rcx+8],r9d
 mov qword ptr [rcx+16],r8
 mov dword ptr [rcx+4],1
 mov eax,1
 ret
.Lpubbad:
 xor eax,eax
 ret
.globl x01_entry_acquire
/* RCX=entry*. EAX=1 success; count does not wrap */
x01_entry_acquire:
 test rcx,rcx
 jz .Lacbad
 cmp dword ptr [rcx+4],1
 jne .Lacbad
 cmp qword ptr [rcx+24],-1
 je .Lacbad
 inc qword ptr [rcx+24]
 mov eax,1
 ret
.Lacbad:
 xor eax,eax
 ret
.globl x01_entry_release
/* RCX=entry*. EAX=1 success; cannot underflow. */
x01_entry_release:
 test rcx,rcx
 jz .Lrelbad
 cmp qword ptr [rcx+24],0
 je .Lrelbad
 dec qword ptr [rcx+24]
 mov eax,1
 ret
.Lrelbad:
 xor eax,eax
 ret
.globl x01_entry_retire
/* RCX=entry*. EAX=1 if sealed, no leases and retired.
 * Does not free base: caller must reclaim only after pin quiescence.
 * Generation grows, exhaustion permanently retires index.
 */
x01_entry_retire:
 test rcx,rcx
 jz .Lretbad
 cmp dword ptr [rcx+4],1
 jne .Lretbad
 cmp qword ptr [rcx+24],0
 jne .Lretbad
 mov dword ptr [rcx+4],2
 mov qword ptr [rcx+16],0
 mov dword ptr [rcx+8],0
 mov dword ptr [rcx+12],0
 cmp word ptr [rcx+2],65535
 je .Lretok
 inc word ptr [rcx+2]
 mov dword ptr [rcx+4],0
.Lretok:
 mov eax,1
 ret
.Lretbad:
 xor eax,eax
 ret
