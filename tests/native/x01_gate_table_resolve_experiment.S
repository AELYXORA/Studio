/* X01 experimental gate-aware ResolveRef.
 * Win64 RCX=Ref64 RDX=pinned table R8D=size R9D=alignment.
 * Table layout: count@0, reserved@4, ArenaEntry[32]@8.
 * ArenaEntry base+ kind@12; gate pointer is NOT encoded in 32-byte
 * entry. This experiment enforces read gate via separate table-level
 * gate stored at table - 8 (host-owned layout requirement).
 * Unsafe for production: gate count does not authenticate caller.
 */
.intel_syntax noprefix
.text
.globl x01_gate_table_resolve
x01_gate_table_resolve:
 test rdx,rdx
 jz .bad
 /* The gate count may exceed 1; compare low state and nonzero count */
 mov r10,qword ptr [rdx-8]
 cmp r10d,1
 jne .bad
 shr r10,32
 test r10d,r10d
 jz .bad
 /* Tail call underlying resolver, but a different thread may retire
    after gate read. Safe only with caller-held borrow/pin. */
 jmp x01_resolve_table
.bad:
 xor eax,eax
 ret
