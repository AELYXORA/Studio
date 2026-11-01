/* T0 bounded ASCII lexical slice (not LexerScan).
 Win64: RCX bytes, RDX length, R8 output 16-byte records, R9 capacity.
 EAX count including EOF, or -1; no publication on failure (caller discards).
 records: kind u32, start u32, end u32, reserved u32.
 Handles ASCII identifier, import(64), on(70), settled(80), '.'(22), ';'(25).
 ASCII spaces skipped, UTF-8 and all other grammar classes unsupported.
 */
.intel_syntax noprefix
.text
.globl x01_lexer_ascii_slice
x01_lexer_ascii_slice:
 push rbx
 push rsi
 push rdi
 push r12
 push r13
 push r14
 push r15
 mov r12,rcx
 mov r13,rdx
 mov r14,r8
 mov r15,r9
 xor ebx,ebx
 xor esi,esi
 test r12,r12
 jz .bad
 test r14,r14
 jz .bad
 mov rax,0xffffffff
 cmp r13,rax
 ja .bad
.scan:
 cmp rbx,r13
 jae .eof
 movzx eax,byte ptr [r12+rbx]
 cmp al,32
 je .space
 mov edi,22
 cmp al,46
 je .single
 mov edi,25
 cmp al,59
 je .single
 cmp al,65
 jb .lower
 cmp al,90
 jbe .ident
.lower:
 cmp al,97
 jb .bad
 cmp al,122
 ja .bad
.ident:
 mov r10,rbx
.idloop:
 inc rbx
 cmp rbx,r13
 jae .idfinish
 movzx eax,byte ptr [r12+rbx]
 cmp al,65
 jb .idlow
 cmp al,90
 jbe .idloop
.idlow:
 cmp al,97
 jb .iddigit
 cmp al,122
 jbe .idloop
.iddigit:
 cmp al,48
 jb .idfinish
 cmp al,57
 jbe .idloop
.idfinish:
 mov edi,1
 mov r11,rbx
 sub r11,r10
 cmp r11,6
 jne .checkon
 cmp byte ptr [r12+r10],105
 jne .checkon
 cmp byte ptr [r12+r10+1],109
 jne .checkon
 cmp byte ptr [r12+r10+2],112
 jne .checkon
 cmp byte ptr [r12+r10+3],111
 jne .checkon
 cmp byte ptr [r12+r10+4],114
 jne .checkon
 cmp byte ptr [r12+r10+5],116
 jne .checkon
 mov edi,64
.checkon:
 cmp r11,2
 jne .checksettled
 cmp word ptr [r12+r10],0x6e6f
 jne .checksettled
 mov edi,70
.checksettled:
 cmp r11,7
 jne .emit
 cmp dword ptr [r12+r10],0x74746573
 jne .emit
 cmp word ptr [r12+r10+4],0x656c
 jne .emit
 cmp byte ptr [r12+r10+6],100
 jne .emit
 mov edi,80
 jmp .emit
.single:
 mov r10,rbx
 inc rbx
.emit:
 cmp rsi,r15
 jae .bad
 mov rax,rsi
 shl rax,4
 add rax,r14
 mov dword ptr [rax],edi
 mov dword ptr [rax+4],r10d
 mov dword ptr [rax+8],ebx
 mov dword ptr [rax+12],0
 inc rsi
 jmp .scan
.space:
 inc rbx
 jmp .scan
.eof:
 cmp rsi,r15
 jae .bad
 mov rax,rsi
 shl rax,4
 add rax,r14
 mov dword ptr [rax],4
 mov dword ptr [rax+4],ebx
 mov dword ptr [rax+8],ebx
 mov dword ptr [rax+12],0
 inc rsi
 mov eax,esi
 jmp .done
.bad:
 mov eax,-1
.done:
 pop r15
 pop r14
 pop r13
 pop r12
 pop rdi
 pop rsi
 pop rbx
 ret
