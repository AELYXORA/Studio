/* X01 Ref64 bounds/generation check. Windows x64 ABI.
 * RCX=Ref64; EDX=expected arena index; R8D=current generation;
 * R9D=committed byte length. EAX=1 if valid, else 0.
 * Tests shape and one synthetic arena descriptor ONLY.
 * Does NOT validate real arena ownership, descriptor or leases.
 */
.intel_syntax noprefix
.text
.p2align 4
.globl x01_ref_check_candidate
x01_ref_check_candidate:
  test rcx, rcx
  jz .Lreject
  mov r10, rcx
  shr r10, 32
  movzx r11d, r10w
  cmp r11d, edx
  jne .Lreject
  test r11d, r11d
  jz .Lreject
  shr r10, 16
  movzx r11d, r10w
  cmp r11d, r8d
  jne .Lreject
  test r11d, r11d
  jz .Lreject
  mov eax, ecx
  cmp eax, r9d
  jae .Lreject
  mov eax, 1
  ret
.Lreject:
  xor eax, eax
  ret
