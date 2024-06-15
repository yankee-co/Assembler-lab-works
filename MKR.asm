.386
data segment
    v1 dd 13 ; random number
    v2 dd 27
    v3 dd 10
data ends

code segment
    assume cs:code, ds:data
begin:
    mov ax, data
    mov ds, ax

    mov eax, v1    ; Load v1 into eax
    add eax, v2    ; v1 += v2
    mov v1, eax    ; Store updated v1

LN4:
    mov eax, v3    ; Load v3 into eax
    cmp v1, eax    ; Compare v1 and v3
    ja SHORT LN8   ; Jump if v1 > v3

    jmp SHORT LN4  ; Jump back to LN4

LN8:
    mov ax, 4c00h
    int 21h
code ends
end begin
