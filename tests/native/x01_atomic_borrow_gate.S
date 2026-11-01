/* X01 atomic borrow state experiment, Win64 argument ABI.
 * Caller pins the 8-byte aligned atomic gate for the entire call.
 * gate u64: low32 state 1=OPEN,2=RETIRING,0=VACANT;
 * high32 active borrow count. No pointer returned.
 * RCX=gate*; EAX=1 success, 0 failure.
 */
.intel_syntax noprefix
.text
.globl x01_borrow_try_acquire
x01_borrow_try_acquire:
 test rcx,rcx
 jz .acfail
 mov rax,qword ptr [rcx]
.acloop:
 cmp eax,1
 jne .acfail
 mov rdx,rax
 shr rdx,32
 cmp edx,-1
 je .acfail
 lea rdx,[rax+0x100000000]
 lock cmpxchg qword ptr [rcx],rdx
 jne .acloop
 mov eax,1
 ret
.acfail:
 xor eax,eax
 ret
.globl x01_borrow_release
x01_borrow_release:
 test rcx,rcx
 jz .relfail
 mov rax,qword ptr [rcx]
.relloop:
 mov rdx,rax
 shr rdx,32
 test edx,edx
 jz .relfail
 mov rdx,rax
 sub rdx,0x100000000
 lock cmpxchg qword ptr [rcx],rdx
 jne .relloop
 mov eax,1
 ret
.relfail:
 xor eax,eax
 ret
.globl x01_borrow_begin_retire
x01_borrow_begin_retire:
 test rcx,rcx
 jz .retfail
 mov rax,qword ptr [rcx]
.retloop:
 cmp eax,1
 jne .retfail
 mov rdx,rax
 and rdx,-4294967296
 or rdx,2
 lock cmpxchg qword ptr [rcx],rdx
 jne .retloop
 mov eax,1
 ret
.retfail:
 xor eax,eax
 ret
.globl x01_borrow_try_finish_retire
x01_borrow_try_finish_retire:
 test rcx,rcx
 jz .finfail
 mov eax,2
 xor edx,edx
 lock cmpxchg qword ptr [rcx],rdx
 jne .finfail
 mov eax,1
 ret
.finfail:
 xor eax,eax
 ret
