.486

STACK_SEG SEGMENT STACK use16
    DW  1000 DUP (?)
STACK_SEG ENDS 

white_color     equ     0Fh
default_color   equ     25h
default_color1  equ     23h
out_color       equ     1h
line_color      equ     14h

DATA_SEG SEGMENT use16
    max_crt_x   dw     320                                    
    max_crt_y   dw     200   

    min_x       dq   (-12.0)   
    max_x       dq   (12.0)	   
    crt_x       dw	 (?)	
    scale_x	    dq	 (?)	   
    
    x_step      dq   (0.001)        
    max_x_steps dw   (?)        
    crt_flt_x   dq   (?)             

    min_y       dq	 (-12.0)        
    max_y       dq	 (12.0)           
    crt_y 		dw	 (?)      
    scale_y 	dq 	 (?)           

    print_color dw   (?)

    const1      dq    (0.7)
    const2      dq    (5.7)

DATA_SEG ENDS


CODE_SEG SEGMENT use16
ASSUME CS:CODE_SEG, DS:DATA_SEG    

output_pixel proc near
    push bp      
    mov bp, sp
    pusha
    push es

        push 0a000h
        pop es
        
        mov cx, [bp + 8] ; x
        mov dx, [bp + 6] ; y

        mov bx, dx
        shl bx, 8   ; *256
        shl dx, 6   ; *64
        add bx, dx
        add bx, cx

        mov ax, [bp + 4] ; color
        mov byte ptr es:[bx], al

    pop es
    popa
    pop bp
    ret 6   
output_pixel endp

scale proc near
    push bp         
    mov bp, sp
    pusha
    push ds   

        push DATA_SEG
        pop ds

        ; scale_x = (max_x - min_x) / max_crt_x
        fld max_x		   
        fsub min_x	
        fild max_crt_x	    
        fdivp st(1), st(0)	
        fstp scale_x        

        ; scale_y = (max_y - min_y) / max_crt_y
        fld max_y		    
        fsub min_y	
        fild max_crt_y	    
        fdivp st(1), st(0)	
        fstp scale_y        

        ; max_x_steps = (max_x - min_x) / x_step
        fld max_x		    
        fsub min_x	
        fld x_step
        fdivp st(1), st(0)
        frndint	            
        fistp max_x_steps 

    pop ds
    popa
    pop bp
    ret 
scale endp


recalc_x proc near
    push bp         
    mov bp, sp
    pusha
    push ds   

        push DATA_SEG
        pop ds

        ; Increment crt_flt_x
        fld crt_flt_x
        fadd x_step
        fst crt_flt_x

        fsub min_x         
        fdiv scale_x        
        frndint	            
        fistp crt_x

        fld crt_flt_x

    pop ds
    popa
    pop bp
    ret 
recalc_x endp


recalc_y proc near
    push bp         
    mov bp, sp
    pusha
    push ds   

        mov si, [bp + 4]

        fcom min_y          
        fstsw ax            
        sahf 				
        jc minus		    

        fcom max_y		    
        fstsw ax            
        sahf                
        ja plus		        

        fsub min_y          
        fdiv scale_y        
        frndint	            

        fistp crt_y         
        mov ax, max_crt_y
        sub ax, crt_y
        mov crt_y, ax		

        mov print_color, si  
        jmp end_calc

        plus:
            fistp crt_y               
            mov crt_y, 0

            mov print_color, out_color 
            
            jmp end_calc
        minus:
            fistp crt_y             
            mov dx, max_crt_y
            dec dx
            mov crt_y, dx

            mov print_color, out_color 

        end_calc:

    pop ds
    popa
    pop bp
    ret 2
recalc_y endp


begin:

    push DATA_SEG
    pop DS

    ; Init video mode 
    mov ax, 013h
    int 10h 

    call scale

    mov di, max_crt_x
    
    ; Y AXIS
    ; Розрухунок екраної координати на x = 0
    fld min_y
    fchs         
    fdiv scale_y       
    frndint	         
    fistp crt_y        
    mov ax, max_crt_y  
    sub ax, crt_y
    mov crt_y, ax

    x_axis_loop:
        mov crt_x, di
        dec crt_x  

        push crt_x
        push crt_y
        push line_color
        call OUTPUT_PIXEL

        dec di
        cmp di, 0
    jne x_axis_loop

    mov di, max_crt_y
    
    ; X AXIS
    ; Розрухунок екраної координати на y = 0
    fldz
    fsub min_x       
    fdiv scale_x      
    frndint	        
    fistp crt_x      

    y_axis_loop:
        mov crt_y, di
        dec crt_y      

        push crt_x
        push crt_y
        push line_color
        call OUTPUT_PIXEL
        
        dec di
        cmp di, 0
    jne y_axis_loop

    fld min_x
    fstp crt_flt_x

    mov di, max_x_steps
    draw_loop1: 
        mov crt_x, di

        call recalc_x 

        ;fld     ST(0)
        fld     const2
        fmul    ST(0), ST(1)

        push default_color
        call recalc_y
       
        dec crt_x     

        push crt_x
        push crt_y
        push print_color
        call OUTPUT_PIXEL

        dec di
        cmp di, 0
    jne draw_loop1

    fld min_x
    fstp crt_flt_x

    mov di, max_x_steps
    draw_loop2: 
        mov crt_x, di

        call recalc_x 

        fld     ST(0)            ; st(0) = x, st(1) = x
        fmul    ST(0), ST(1)     ; st(0) = x^2, st(1) = x
        fld     const1           ; st(0) = 0.7, st(1) = x^2, st(2) = x
        fmul    ST(1), ST(0)     ; ST(0) = x^2, ST(1) = 0.7 * x^2, ST(2) = x
        fxch    ST(1)            ; ST(0) = 0.7 * x^2, ST(1) = x^2, ST(2) = x

        push default_color1
        call recalc_y
       
        dec crt_x    

        push crt_x
        push crt_y
        push print_color
        call OUTPUT_PIXEL

        dec di
        cmp di, 0
    jne draw_loop2

    fld min_x
    fstp crt_flt_x

    ; Draw graph
    mov di, max_x_steps
    draw_loop3: 
        mov crt_x, di

        call recalc_x 

        fld     ST(0)            ; st(0) = x, st(1) = x
        fmul    ST(0), ST(1)     ; st(0) = x^2, st(1) = x
        fld     const1           ; st(0) = 0.7, st(1) = x^2, st(2) = x
        fmul    ST(1), ST(0)     ; ST(0) = x^2, ST(1) = 0.7 * x^2, ST(2) = x
        fxch    ST(1)            ; ST(0) = 0.7 * x^2, ST(1) = x^2, ST(2) = x
        fld     const2           ; ST(0) = 5.7, ST(1) = 0.7 * x^2, ST(2) = x^2, ST(3) = x
        fmul    ST(0), ST(3)     ; ST(0) = 5.7 * x, ST(1) = 0.7 * x^2, ST(2) = x^2, ST(3) = x
        faddp   ST(1), ST(0)     ; ST(0) = 0.7 * x^2 + 5.7 * x, ST(1) = x^2, ST(2) = x
        fld1                     ; ST(0) = 1, ST(1) = 0.7 * x^2 + 5.7 * x, ST(2) = x^2, ST(3) = x
        faddp   ST(1), ST(0)     ; ST(0) = 0.7 * x^2 + 5.7 * x + 1, ST(1) = x^2, ST(2) = x

        push out_color
        call recalc_y
       
        dec crt_x     

        push crt_x
        push crt_y
        push white_color
        call OUTPUT_PIXEL

        dec di
        cmp di, 0
    jne draw_loop3

    ; Wait for input
    xor ax,ax 	
    int 16h 	

    ; Return default video mode
    mov ax,3 	
    int 10h 	
    
    ; Exit to DOS
    mov ax,4C00h 	
    int 21h

CODE_SEG ENDS
end begin
