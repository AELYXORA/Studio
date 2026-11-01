.intel_syntax noprefix
.data
source1: .ascii "import aui.core;"
source2: .ascii "on settled"
.p2align 4
output: .zero 128
.text
.globl main
main:
 push rbx
 sub rsp,32
 lea rcx,[rip+source1]
 mov edx,16
 lea r8,[rip+output]
 mov r9d,8
 call x01_lexer_ascii_slice
 cmp eax,6
 jne .fail1
 lea rbx,[rip+output]
 cmp dword ptr [rbx],64
 jne .fail2
 cmp dword ptr [rbx+8],6
 jne .fail3
 cmp dword ptr [rbx+16],1
 jne .fail4
 cmp dword ptr [rbx+16+4],7
 jne .fail5
 cmp dword ptr [rbx+16+8],10
 jne .fail6
 cmp dword ptr [rbx+32],22
 jne .fail7
 cmp dword ptr [rbx+48],1
 jne .fail8
 cmp dword ptr [rbx+64],25
 jne .fail9
 cmp dword ptr [rbx+80],4
 jne .fail10
 lea rcx,[rip+source2]
 mov edx,10
 lea r8,[rip+output]
 mov r9d,8
 call x01_lexer_ascii_slice
 cmp eax,3
 jne .fail11
 cmp dword ptr [rbx],70
 jne .fail12
 cmp dword ptr [rbx+16],80
 jne .fail13
 cmp dword ptr [rbx+32],4
 jne .fail14
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
 jmp .done
.fail7: mov eax,7
 jmp .done
.fail8: mov eax,8
 jmp .done
.fail9: mov eax,9
 jmp .done
.fail10: mov eax,10
 jmp .done
.fail11: mov eax,11
 jmp .done
.fail12: mov eax,12
 jmp .done
.fail13: mov eax,13
 jmp .done
.fail14: mov eax,14
.done:
 add rsp,32
 pop rbx
 ret
