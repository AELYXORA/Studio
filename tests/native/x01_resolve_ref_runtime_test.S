/* Linux x86-64 test harness written in GAS Assembly.
 * Calls x01_resolve_ref_one with Windows x64 register ABI.
 * Exit code 0 = all six cases passed; 1..6 = failing case.
 */
.intel_syntax noprefix
.section .data
.p2align 4
arena_bytes: .zero 64
.p2align 3
arena_entry:
  .short 2
  .short 1
  .long 1
  .long 64
  .long 0
  .quad arena_bytes
  .quad 1
.section .text
.globl main
main:
  push rbx
  sub rsp,32
  /* Good: generation=1, index=2, offset=16; 8-byte request. */
  mov rcx,0x0001000200000010
  lea rdx,[rip+arena_entry]
  mov r8d,8
  mov r9d,8
  call x01_resolve_ref_one
  lea rbx,[rip+arena_bytes+16]
  cmp rax,rbx
  jne .fail1
  /* Wrong generation */
  mov rcx,0x0002000200000010
  lea rdx,[rip+arena_entry]
  mov r8d,8
  mov r9d,8
  call x01_resolve_ref_one
  test rax,rax
  jne .fail2
  /* Extent beyond committed 64 */
  mov rcx,0x000100020000003c
  lea rdx,[rip+arena_entry]
  mov r8d,8
  mov r9d,4
  call x01_resolve_ref_one
  test rax,rax
  jne .fail3
  /* Misaligned offset 18 */
  mov rcx,0x0001000200000012
  lea rdx,[rip+arena_entry]
  mov r8d,8
  mov r9d,8
  call x01_resolve_ref_one
  test rax,rax
  jne .fail4
  /* Non-power-of-two alignment 3 */
  mov rcx,0x0001000200000010
  lea rdx,[rip+arena_entry]
  mov r8d,8
  mov r9d,3
  call x01_resolve_ref_one
  test rax,rax
  jne .fail5
  /* Revoked lease */
  mov qword ptr [rip+arena_entry+24],0
  mov rcx,0x0001000200000010
  lea rdx,[rip+arena_entry]
  mov r8d,8
  mov r9d,8
  call x01_resolve_ref_one
  test rax,rax
  jne .fail6
  xor eax,eax
  jmp .done
.fail1: mov eax,1
  jmp .done
.fail2: mov eax,2
  jmp .done
.fail3: mov eax,3
  jmp .done
.fail4: mov eax,4
  jmp .done
.fail5: mov eax,5
  jmp .done
.fail6: mov eax,6
.done:
  add rsp,32
  pop rbx
  ret
.section .note.GNU-stack,"",@progbits
