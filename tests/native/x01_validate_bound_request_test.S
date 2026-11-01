.intel_syntax noprefix
.data
.p2align 4
memory: .zero 64
.p2align 3
table:
.long 1,0
.short 1,7
.long 1
.long 64
.long 9
.quad memory
.quad 1
.quad 1
req:
.quad 0x0007000100000010,table
.long 8,8,9,48
.text
.globl main
main:
 push rbx
 sub rsp,32
 lea rcx,[rip+req]
 call x01_validate_bound_request
 cmp eax,1
 jne .f1
 mov dword ptr [rip+req+28],47
 lea rcx,[rip+req]
 call x01_validate_bound_request
 test eax,eax
 jne .f2
 mov dword ptr [rip+req+28],48
 mov dword ptr [rip+req+24],8
 lea rcx,[rip+req]
 call x01_validate_bound_request
 test eax,eax
 jne .f3
 mov dword ptr [rip+req+24],9
 mov qword ptr [rip+table+40],2
 lea rcx,[rip+req]
 call x01_validate_bound_request
 test eax,eax
 jne .f4
 mov qword ptr [rip+table+40],1
 mov word ptr [rip+table+10],8
 lea rcx,[rip+req]
 call x01_validate_bound_request
 test eax,eax
 jne .f5
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
.done:
 add rsp,32
 pop rbx
 ret
