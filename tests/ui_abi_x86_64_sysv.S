/* Linux x86-64, System V ABI, Assembly-only contract test executable.
 * Link with Clang and libc for puts; validator itself makes no system calls.
 */
.section .rodata
.align 16
valid_nodes:
 .long 1,-1,1,0
 .long 3,0,2,0
 .long 4,0,3,0
bad_key_nodes:
 .long 1,-1,1,0
 .long 3,0,1,0
ok_message: .asciz "AELYXORA ASM UI ABI tests passed"
fail_message: .asciz "AELYXORA ASM UI ABI tests FAILED"
.text
.globl main
.type main,@function
main:
 pushq %rbx
 leaq valid_nodes(%rip),%rdi
 movl $3,%esi
 call ax_ui_validate
 testl %eax,%eax
 jne .Lfail
 leaq bad_key_nodes(%rip),%rdi
 movl $2,%esi
 call ax_ui_validate
 cmpl $5,%eax
 jne .Lfail
 xorl %edi,%edi
 movl $2,%esi
 call ax_ui_validate
 cmpl $1,%eax
 jne .Lfail
 leaq ok_message(%rip),%rdi
 call puts@PLT
 xorl %eax,%eax
 popq %rbx
 ret
.Lfail:
 leaq fail_message(%rip),%rdi
 call puts@PLT
 movl $1,%eax
 popq %rbx
 ret
.size main,.-main
.section .note.GNU-stack,"",@progbits
