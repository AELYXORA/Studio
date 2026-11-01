/* Win64 x86-64 LLVM integrated assembler; no CRT dependencies.
 * X01 candidate struct bytes + Ref64 bit-shape probe.
 * Cross-assembled COFF, NOT executed on Windows.
 */
.intel_syntax noprefix
.section .rdata,"dr"
.p2align 3
.globl x01_token_fixture
x01_token_fixture:
.quad 1
.quad 1
.quad 0
.quad 1
.short 16
.short 31
.long 0
.quad 0
x01_token_fixture_end:
.if (x01_token_fixture_end - x01_token_fixture) != 48
.error "TokenV1 size mismatch"
.endif

.p2align 3
.globl x01_empty_decoded_string
x01_empty_decoded_string:
.long 32
.short 2
.short 0
.quad 0
.long 0
.long 0
.quad 0
x01_empty_decoded_string_end:
.if (x01_empty_decoded_string_end - x01_empty_decoded_string) != 32
.error "DecodedValueV1 size mismatch"
.endif

.p2align 3
.globl x01_empty_span
x01_empty_span:
.quad 0
.long 0
.short 8
.short 0
x01_empty_span_end:
.if (x01_empty_span_end - x01_empty_span) != 16
.error "Span16 size mismatch"
.endif

.text
.p2align 4
.globl x01_validate_ref_shape
/* uint32 x01_validate_ref_shape(uint64 ref)
 * RCX=ref; EAX=1 if absent(0) or structurally valid, else 0.
 * Does NOT validate leases, bounds, alignment, sealing or generations.
 */
x01_validate_ref_shape:
    test rcx, rcx
    je .Lgood
    mov rax, rcx
    shr rax, 32
    test ax, ax
    je .Lbad
    shr rax, 16
    test ax, ax
    je .Lbad
.Lgood:
    mov eax, 1
    ret
.Lbad:
    xor eax, eax
    ret
