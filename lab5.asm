.386

DSEG SEGMENT use16
    string db "The solution to this problem was found by French-born American scientist Jan LeCun, inspired by the work of Nobel laureates in the field of medicine Torsten Nils Wiesel and David H. Hubel."
    len_str dw 188
DSEG ENDS


CSEG SEGMENT use16
ASSUME CS:CSEG, DS:DSEG

prmaus proc far
    push ds
    push es
    pushf

        ; Load data segment
        push DSEG  
        pop ds   

        ; Store graphic adress
        push 0b800h
        pop es     
        
        ; Hide cursor
        mov ax, 2
        int 33h
          
        ; cx - x
        ; dy - y
        ; From pixels to cursos position
        shr dx, 03h 
        shr cx, 03h
                               
        ; Caclulate memory offset
        ; Offset = (y * 80 + x + 1) * 2 = 160*y + x + x + 2 
        imul dx, 160   
        add dx, cx
        add dx, cx
        add dx, 2

        mov si, dx

        cmp si, 32
        jg prmaus_end

        mov ax, ES:[si]
        shr ax, 4
        or ax, 0Fh

        mov bx, 160
        call draw_text

    prmaus_end:
        ; Show cursor
        mov ax, 1
        int 33h

    popf
    pop es
    pop ds
    ret
prmaus endp

; ah - text color
; bx - position
draw_text proc
    push ds
    push es
    pushf

        ; Load data segment
        push DSEG  
        pop ds   

        ; Store graphic adress
        push 0b800h
        pop es     

        ; Print text
        mov di, bx
        ; Repeat loop counter
        mov cx, 6
        ; Repeat basic drawing repeat_count times 
        lp:
            mov bx, 0

            ; Initial draw loop
            write:
                mov si, bx
                mov al, string[si]

                ; Store AX at address ES:(E)DI.
                stosw

                inc bx
                cmp bx, len_str
            jl write
        loop lp

    popf
    pop es
    pop ds
    ret
draw_text endp

begin:

    ; Load data segment
    push DSEG
    pop ds  

    ; Store graphic adress
    push 0b800h
	pop es     

    ; Init mouse
	mov ax, 0
	int 33h   


    ; Init video mode
	mov ax, 3 
    int 10h

    ; Disable blink mode
    mov ah, 10h
    mov al, 3
    mov bl, 0
    int 10h

    ; Print palette
    mov bx, 0
    mov al, 0
    palette:
        mov ah, bl
        shl ah, 4

        ; Store AX at address ES:(E)DI.
        stosw

        inc bx
        cmp bx, 16
    jl palette

    mov ah, 00Fh
    mov bx, 160
    call draw_text

	; Init handler
	mov ax, 0ch	
	mov	cx, 100b ; Left release
	push es		
	push cs
	pop	es		
	lea	dx, prmaus
	int	33h		
    pop	es

    ; Show cursor
	mov ax, 1
	int 33h

    ; Wait for input
	mov ah,10h
	int 16h

    ; Remove mouse handler
	lea	dx, prmaus
	xor cx, cx		
	mov	ax, 0ch		
	int	33h

    ; Clear screen
	mov ax,3        
	int 10h

    ; Close program
	mov ax, 4c00h
	int 21h 

CSEG ENDS
END begin