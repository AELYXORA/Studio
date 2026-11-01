.intel_syntax noprefix
.data
s1: .ascii "import aui.core;"
s2: .ascii "on settled"
s3: .ascii "//hello\r\nText"
s4: .ascii "a b\t\r\nc"
s5: .ascii "a / b"
s6: .ascii "\"a//b\""
.p2align 4
out: .zero 128
.text
.globl main
main:
 push rbx
 sub rsp,32
 lea rbx,[rip+out]
 lea rcx,[rip+s1]
 mov edx,16
 mov r8,rbx
 mov r9d,8
 call x01_trivia_ascii
 cmp eax,1
 jne .f1
 cmp dword ptr [rbx],1
 jne .f2
 cmp dword ptr [rbx+4],6
 jne .f3
 cmp dword ptr [rbx+8],7
 jne .f4
 lea rcx,[rip+s2]
 mov edx,10
 mov r8,rbx
 mov r9d,8
 call x01_trivia_ascii
 cmp eax,1
 jne .f5
 cmp dword ptr [rbx+4],2
 jne .f6
 cmp dword ptr [rbx+8],3
 jne .f7
 lea rcx,[rip+s3]
 mov edx,13
 mov r8,rbx
 mov r9d,8
 call x01_trivia_ascii
 cmp eax,2
 jne .f8
 cmp dword ptr [rbx],2
 jne .f9
 cmp dword ptr [rbx+8],7
 jne .f10
 cmp dword ptr [rbx+16],1
 jne .f11
 cmp dword ptr [rbx+20],7
 jne .f12
 cmp dword ptr [rbx+24],9
 jne .f13
 lea rcx,[rip+s4]
 mov edx,7
 mov r8,rbx
 mov r9d,8
 call x01_trivia_ascii
 cmp eax,2
 jne .f14
 cmp dword ptr [rbx+4],1
 jne .f15
 cmp dword ptr [rbx+24],6
 jne .f16
 lea rcx,[rip+s5]
 mov edx,5
 mov r8,rbx
 mov r9d,8
 call x01_trivia_ascii
 cmp eax,-1
 jne .f17
 lea rcx,[rip+s6]
 mov edx,6
 mov r8,rbx
 mov r9d,8
 call x01_trivia_ascii
 cmp eax,-1
 jne .f18
 xor eax,eax
 jmp .done
.f1:mov eax,1
 jmp .done
.f2:mov eax,2
 jmp .done
.f3:mov eax,3
 jmp .done
.f4:mov eax,4
 jmp .done
.f5:mov eax,5
 jmp .done
.f6:mov eax,6
 jmp .done
.f7:mov eax,7
 jmp .done
.f8:mov eax,8
 jmp .done
.f9:mov eax,9
 jmp .done
.f10:mov eax,10
 jmp .done
.f11:mov eax,11
 jmp .done
.f12:mov eax,12
 jmp .done
.f13:mov eax,13
 jmp .done
.f14:mov eax,14
 jmp .done
.f15:mov eax,15
 jmp .done
.f16:mov eax,16
 jmp .done
.f17:mov eax,17
 jmp .done
.f18:mov eax,18
.done:
 add rsp,32
 pop rbx
 ret
