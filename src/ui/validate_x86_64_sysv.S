/* GNU / Clang integrated assembler, x86-64 System V ABI (Linux).
 * int32_t ax_ui_validate(const ax_ui_node* rdi, uint32_t esi)
 * Struct size 16, fields offsets kind=0, parent=4, key=8, flags=12.
 * No syscalls. Leaf nodes cannot have children.
 */
.text
.globl ax_ui_validate
.type ax_ui_validate,@function
ax_ui_validate:
    testq %rdi,%rdi
    jz .Largument
    testl %esi,%esi
    jz .Largument
    cmpl $4096,%esi
    ja .Largument
    cmpl $-1,4(%rdi)
    jne .Lroot
    xorl %ecx,%ecx
.Lloop:
    cmpl %esi,%ecx
    jae .Lok
    movl %ecx,%r8d
    shlq $4,%r8
    leaq (%rdi,%r8),%r9
    movl (%r9),%r10d
    cmpl $1,%r10d
    jb .Lkind
    cmpl $4,%r10d
    ja .Lkind
    cmpl $0,12(%r9)
    jne .Largument
    cmpl $0,8(%r9)
    je .Lkey
    testl %ecx,%ecx
    jz .Lnext
    movl 4(%r9),%r11d
    testl %r11d,%r11d
    js .Lparent
    cmpl %ecx,%r11d
    jae .Lparent
    movl %r11d,%r8d
    shlq $4,%r8
    leaq (%rdi,%r8),%r8
    cmpl $2,(%r8)
    jbe .Lunique
    jmp .Lparent
.Lunique:
    xorl %r11d,%r11d
.Lcheck:
    cmpl %ecx,%r11d
    jae .Lnext
    movl %r11d,%r8d
    shlq $4,%r8
    movl 8(%rdi,%r8),%r8d
    cmpl %r8d,8(%r9)
    je .Lkey
    incl %r11d
    jmp .Lcheck
.Lnext:
    incl %ecx
    jmp .Lloop
.Lok:
    xorl %eax,%eax
    ret
.Largument:
    movl $1,%eax
    ret
.Lroot:
    movl $2,%eax
    ret
.Lparent:
    movl $3,%eax
    ret
.Lkind:
    movl $4,%eax
    ret
.Lkey:
    movl $5,%eax
    ret
.size ax_ui_validate,.-ax_ui_validate
