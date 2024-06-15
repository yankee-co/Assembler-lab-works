.686 ; можна використовувати .386
.model flat,C ; модель пам'яті та передача параметрів за правилами C

public BigShowN ; void BigShowN(byte* p1, int p2)
.code
BigShowN PROC
    pushad
    mov esi, [esp + 28] ; p1
    mov ecx, [esp + 24] ; p2

    xor edx, edx ; Очистимо edx (регістр для збереження байтів)
    xor ebx, ebx ; Обнулимо ebx (лічильник для обробки байтів)

    @loop:
        mov al, [esi] ; Завантажити байт
        push edx ; Зберегти edx в стек (для виклику show_bt)
        push ebx ; Зберегти ebx в стек (для виклику show_bt)
        call show_bt ; Викликати show_bt
        pop ebx ; Відновити ebx зі стека
        pop edx ; Відновити edx зі стека

        add esi, 1 ; Перехід до наступного байту
        add ebx, 1 ; Збільшити лічильник

        cmp ebx, 4 ; Якщо лічильник досягнув 4, скинути його
        je @reset_counter
        jmp @continue

    @reset_counter:
        xor ebx, ebx ; Обнулити лічильник

    @continue:
        sub ecx, 1 ; Зменшити лічильник
        jnz @loop ; Повторити цикл, якщо лічильник не дорівнює нулю

    popad
    ret
BigShowN ENDP
END
