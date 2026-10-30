/* Native Linux x86-64 JSON lexical preflight.
 * This deliberately checks delimiter balance and string boundaries only.
 * Not a JSON parser, schema validator, or Project Graph validator.
 * clang -nostdlib -no-pie -Wl,-e,_start -o json_preflight json_preflight.S
 */
.intel_syntax noprefix
.global _start
.section .bss
.balign 16
buffer: .skip 65536
stack_buffer: .skip 4096
.section .rodata
ok_msg: .ascii "PASS JSON preflight\n"
err_msg: .ascii "FAIL JSON preflight\n"
usage_msg: .ascii "usage: json_preflight <json-file>\n"
.section .text
_start:
    mov rax, [rsp]
    cmp rax, 2
    jne usage
    mov rax, 2
    mov rdi, [rsp + 16]
    xor rsi, rsi
    xor rdx, rdx
    syscall
    test rax, rax
    js fail
    mov r12, rax
    xor r13, r13
    xor r14d, r14d
    xor r15d, r15d
    xor ebx, ebx
read_more:
    xor rax, rax
    mov rdi, r12
    lea rsi, [rip + buffer]
    mov rdx, 65536
    syscall
    test rax, rax
    js fail_close
    jz eof
    lea rsi, [rip + buffer]
    lea r8, [rsi + rax]
scan:
    cmp rsi, r8
    jae read_more
    movzx eax, byte ptr [rsi]
    inc rsi
    test r14d, r14d
    jz outside
    test r15d, r15d
    jz string_normal
    xor r15d, r15d
    cmp al, 0x20
    jb fail_close
    jmp scan
string_normal:
    cmp al, 0x5c
    je escaped
    cmp al, 0x22
    je end_string
    cmp al, 0x20
    jb fail_close
    jmp scan
escaped:
    mov r15d, 1
    jmp scan
end_string:
    xor r14d, r14d
    jmp scan
outside:
    cmp al, ' '
    je scan
    cmp al, 10
    je scan
    cmp al, 13
    je scan
    cmp al, 9
    je scan
    mov ebx, 1
    cmp al, '"'
    je start_string
    cmp al, '{'
    je push_object
    cmp al, '['
    je push_array
    cmp al, '}'
    je pop_object
    cmp al, ']'
    je pop_array
    jmp scan
start_string:
    mov r14d, 1
    jmp scan
push_object:
    cmp r13, 4096
    jae fail_close
    lea r9, [rip + stack_buffer]
    mov byte ptr [r9 + r13], 1
    inc r13
    jmp scan
push_array:
    cmp r13, 4096
    jae fail_close
    lea r9, [rip + stack_buffer]
    mov byte ptr [r9 + r13], 2
    inc r13
    jmp scan
pop_object:
    test r13, r13
    jz fail_close
    dec r13
    lea r9, [rip + stack_buffer]
    cmp byte ptr [r9 + r13], 1
    jne fail_close
    jmp scan
pop_array:
    test r13, r13
    jz fail_close
    dec r13
    lea r9, [rip + stack_buffer]
    cmp byte ptr [r9 + r13], 2
    jne fail_close
    jmp scan
eof:
    test r14d, r14d
    jnz fail_close
    test r15d, r15d
    jnz fail_close
    test r13, r13
    jnz fail_close
    test ebx, ebx
    jz fail_close
    mov rax, 3
    mov rdi, r12
    syscall
    mov rax, 1
    mov rdi, 1
    lea rsi, [rip + ok_msg]
    mov rdx, 20
    syscall
    xor rdi, rdi
    jmp exit
fail_close:
    mov rax, 3
    mov rdi, r12
    syscall
fail:
    mov rax, 1
    mov rdi, 2
    lea rsi, [rip + err_msg]
    mov rdx, 20
    syscall
    mov rdi, 1
    jmp exit
usage:
    mov rax, 1
    mov rdi, 2
    lea rsi, [rip + usage_msg]
    mov rdx, 33
    syscall
    mov rdi, 2
exit:
    mov rax, 60
    syscall
