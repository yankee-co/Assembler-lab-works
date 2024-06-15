.686 ; можна використовувати .386
.model flat,C ; модель пам'яті та передача параметрів за правилами C

public Big3Sub ; void Big3Sub(byte* M1, byte* M2, byte* M3, byte* Carry, short len)
.code
Big3Sub PROC
    pushad
    mov esi, [esp + 32] ; M1
    mov edi, [esp + 28] ; M2
    mov ebx, [esp + 24] ; M3
    mov ecx, [esp + 20] ; Carry
    mov dx, [esp + 16]  ; len

    movzx ecx, cx ; Знакове розширення до 32-біт
    movzx eax, dx ; Знакове розширення до 32-біт

    mov edx, 0 ; Спочатку обнулимо регістр, що буде тримати "позику"
    clc ; Очистимо флаг переносу

    @loop:
        mov al, [edi] ; M2[i]
        sbb al, [ebx] ; M2[i] - M3[i] - Carry
        mov [esi], al ; M1[i] = M2[i] - M3[i] - Carry

        ; Обробка прапорця переносу
        movzx eax, al ; Знакове розширення до 32-біт
        adc edx, 0 ; Додаємо позику до регістра

        add esi, 1 ; Перехід до наступного байту
        add edi, 1 ; Перехід до наступного байту
        add ebx, 1 ; Перехід до наступного байту

        sub dx, 1 ; Зменшуємо лічильник
        jnz @loop ; Повторюємо цикл, якщо лічильник не дорівнює нулю

    ; Зберігаємо значення позики у флаг переносу
    mov eax, edx
    mov [ecx], al

    popad
    ret
Big3Sub ENDP
END
