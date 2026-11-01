/* T0 preliminary UTF-8 scalar validation; Win64 RCX=bytes RDX=length.
 * EAX=1 valid, 0 invalid. Rejects NUL and initial BOM.
 * Does NOT implement LexerScan, normalization, XID or tokens.
 */
.intel_syntax noprefix
.text
.globl x01_utf8_strict
x01_utf8_strict:
 test rcx,rcx
 jz .bad
 mov r8,rcx
 mov r9,rcx
 add r9,rdx
 jc .bad
 cmp rdx,3
 jb .scan
 cmp byte ptr [r8],0xef
 jne .scan
 cmp byte ptr [r8+1],0xbb
 jne .scan
 cmp byte ptr [r8+2],0xbf
 je .bad
.scan:
 cmp r8,r9
 jae .good
 movzx eax,byte ptr [r8]
 test eax,eax
 jz .bad
 cmp eax,0x80
 jb .one
 cmp eax,0xc2
 jb .bad
 cmp eax,0xdf
 jbe .two
 cmp eax,0xef
 jbe .three
 cmp eax,0xf4
 jbe .four
 jmp .bad
.one:
 inc r8
 jmp .scan
.two:
 lea r10,[r8+2]
 cmp r10,r9
 ja .bad
 movzx edx,byte ptr [r8+1]
 cmp edx,0x80
 jb .bad
 cmp edx,0xbf
 ja .bad
 mov r8,r10
 jmp .scan
.three:
 lea r10,[r8+3]
 cmp r10,r9
 ja .bad
 movzx edx,byte ptr [r8+1]
 cmp edx,0x80
 jb .bad
 cmp edx,0xbf
 ja .bad
 cmp eax,0xe0
 jne .t3_surrogate
 cmp edx,0xa0
 jb .bad
.t3_surrogate:
 cmp eax,0xed
 jne .t3_last
 cmp edx,0x9f
 ja .bad
.t3_last:
 movzx edx,byte ptr [r8+2]
 cmp edx,0x80
 jb .bad
 cmp edx,0xbf
 ja .bad
 mov r8,r10
 jmp .scan
.four:
 lea r10,[r8+4]
 cmp r10,r9
 ja .bad
 movzx edx,byte ptr [r8+1]
 cmp edx,0x80
 jb .bad
 cmp edx,0xbf
 ja .bad
 cmp eax,0xf0
 jne .t4_max
 cmp edx,0x90
 jb .bad
.t4_max:
 cmp eax,0xf4
 jne .t4_rest
 cmp edx,0x8f
 ja .bad
.t4_rest:
 movzx edx,byte ptr [r8+2]
 cmp edx,0x80
 jb .bad
 cmp edx,0xbf
 ja .bad
 movzx edx,byte ptr [r8+3]
 cmp edx,0x80
 jb .bad
 cmp edx,0xbf
 ja .bad
 mov r8,r10
 jmp .scan
.good:
 mov eax,1
 ret
.bad:
 xor eax,eax
 ret
