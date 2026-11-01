/* Ten-case X01 UTF-8 primitive test, Win64 register convention. */
.intel_syntax noprefix
.data
ascii: .ascii "import aui.core;"
utf2: .byte 0xc3,0xa9
utf3: .byte 0xe2,0x82,0xac
utf4: .byte 0xf0,0x9f,0x98,0x80
bad_overlong: .byte 0xc0,0x80
bad_surrogate: .byte 0xed,0xa0,0x80
bad_truncated: .byte 0xe2,0x82
bad_bom: .byte 0xef,0xbb,0xbf,0x61
bad_nul: .byte 0x61,0,0x62
bad_max: .byte 0xf4,0x90,0x80,0x80
.text
.globl main
main:
 push rbx
 sub rsp,32
 lea rcx,[rip+ascii]
 mov edx,16
 call x01_utf8_strict
 cmp eax,1
 jne .fail1
 lea rcx,[rip+utf2]
 mov edx,2
 call x01_utf8_strict
 cmp eax,1
 jne .fail2
 lea rcx,[rip+utf3]
 mov edx,3
 call x01_utf8_strict
 cmp eax,1
 jne .fail3
 lea rcx,[rip+utf4]
 mov edx,4
 call x01_utf8_strict
 cmp eax,1
 jne .fail4
 lea rcx,[rip+bad_overlong]
 mov edx,2
 call x01_utf8_strict
 test eax,eax
 jne .fail5
 lea rcx,[rip+bad_surrogate]
 mov edx,3
 call x01_utf8_strict
 test eax,eax
 jne .fail6
 lea rcx,[rip+bad_truncated]
 mov edx,2
 call x01_utf8_strict
 test eax,eax
 jne .fail7
 lea rcx,[rip+bad_bom]
 mov edx,4
 call x01_utf8_strict
 test eax,eax
 jne .fail8
 lea rcx,[rip+bad_nul]
 mov edx,3
 call x01_utf8_strict
 test eax,eax
 jne .fail9
 lea rcx,[rip+bad_max]
 mov edx,4
 call x01_utf8_strict
 test eax,eax
 jne .fail10
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
.done:
 add rsp,32
 pop rbx
 ret
