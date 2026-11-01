/* Candidate trivia extractor, Win64 ABI. RCX=bytes, RDX=length,
 * R8=output (16B records), R9=capacity. EAX=count or -1.
 * Record u32 kind,start,end,reserved. Kind 1 whitespace, 2 // comment.
 * Non-trivia ASCII skipped; quotes/non-ASCII rejected to avoid false trivia.
 * Test-only, not a LexerScan or TokenV1/TriviaV1 output implementation.
 */
.intel_syntax noprefix
.text
.globl x01_trivia_ascii
x01_trivia_ascii:
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
 mov eax,0xffffffff
 cmp r13,rax
 ja .bad
.scan:
 cmp rbx,r13
 jae .good
 movzx eax,byte ptr [r12+rbx]
 cmp al,32
 je .ws
 cmp al,9
 je .ws
 cmp al,10
 je .ws
 cmp al,13
 je .ws
 cmp al,47
 je .slash
 cmp al,34
 je .bad
 test al,al
 jz .bad
 cmp al,0x80
 jae .bad
 inc rbx
 jmp .scan
.slash:
 lea r10,[rbx+1]
 cmp r10,r13
 jae .bad
 cmp byte ptr [r12+r10],47
 jne .bad
 mov r10,rbx
 add rbx,2
.commentloop:
 cmp rbx,r13
 jae .commentend
 movzx eax,byte ptr [r12+rbx]
 cmp al,10
 je .commentend
 cmp al,13
 je .commentend
 test al,al
 jz .bad
 cmp al,0x80
 jae .bad
 inc rbx
 jmp .commentloop
.commentend:
 mov edi,2
 jmp .emit
.ws:
 mov r10,rbx
.wsloop:
 inc rbx
 cmp rbx,r13
 jae .wsend
 movzx eax,byte ptr [r12+rbx]
 cmp al,32
 je .wsloop
 cmp al,9
 je .wsloop
 cmp al,10
 je .wsloop
 cmp al,13
 je .wsloop
.wsend:
 mov edi,1
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
.good:
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
