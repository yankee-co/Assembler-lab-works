.386

;==========================
; Zemlyanskyi Eduard KV-22
;==========================

max_prg     EQU     10  
time_slice  EQU     65535   
ready       EQU     0   
execute   	EQU     1   
hesitation 	EQU     2   
close       EQU     4   
stop        EQU     8   
absent      EQU     16  
esc_key    	EQU     01h      
f_key    	EQU     21h      
fon	        EQU     max_prg	 
increase_time EQU   5

STACK_SEG SEGMENT WORD STACK 'stack' use16
        DW     32000 DUP (?)
    top LABEL  WORD 
        DW     100 DUP (?)  
STACK_SEG ENDS

DATA_SEG SEGMENT WORD PUBLIC 'DATA' use16
    @ms_dos_busy DD     (?)      
    int8set      DB     0        
    int9set      DB     0        
    fonsp        LABEL  WORD     
    sssp         DD     top      
    stp         DW  1000,  2000,  3000,  4000
                DW  5000,  6000,  7000,  8000
                DW  9000,  10000, 11000, 12000
                DW  13000, 14000, 15000, 16000
    nprg        DW      0         
    init        DB    16 dup (0)   
    clock  	    DB    16 dup (1)   
    clockt     	DB    16 dup (0)   
    screen_addr DW    16 dup (0)   
    names       LABEL   WORD
                DB      '0T1T2T3T4T5T6T7T8T9TATBTCTDTETFT'
    clk         DW      0 
DATA_SEG         ENDS

CODE_SEG SEGMENT BYTE PUBLIC 'CODE' use16
ASSUME CS : CODE_SEG, DS : DATA_SEG

setint8 PROC
    int8ptr dw 2 dup (?) 

    mov	al, int8set
    or al, al 
    
    jnz	zero_8
    mov	ah, 35h 
    mov al, 8   
    int 21h     
    mov cs:int8ptr, bx      
    mov cs:int8ptr + 2, es  

    mov dx, offset userint8	
    push ds         
                        
    push cs			     
    pop ds

    mov ah, 25h 
    mov al, 8   
    int 21h     
    mov ax, time_slice  
    out 40h, al         
    jmp $+2        
    nop

    mov al, ah 
    out 40h, al

    pop ds 

    mov int8set, 0ffh 
zero_8:
    ret
setint8 ENDP

retint8 PROC
    push ds
    push dx

    mov al, 0ffh    
    out 40h, al     

    jmp	$+2
    nop

    out 40h, al

    mov dx, cs:int8ptr
    mov ds, cs:int8ptr + 2

    mov ah, 25h   
    mov al, 8     
    int 21h       
                
    mov int8set,0h 

    pop dx
    pop ds
    ret
retint8  ENDP

setint9 PROC
    int9ptr dw 2 dup (?)

    mov	al, int9set
    or al, al
    jnz zero_9
        mov ah, 35h 
    mov al, 9   
    int 21h     

    mov cs:int9ptr, bx      
    mov cs:int9ptr + 2, es  

    mov dx, offset userint9
    push ds
    push cs         
    pop ds			

    mov ah, 25h  
    mov al, 9    
    int 21h       

    pop ds

    mov int9set,0ffh        	
zero_9:
    ret
setint9 ENDP

retint9 PROC
    push ds
    push dx

    mov dx, cs:int9ptr      
    mov ds, cs:int9ptr+2    

    mov ah, 25h     
    mov al, 9       
    int 21h                   	 

    mov int9set, 0h 

    pop dx
    pop ds
    ret
retint9 ENDP

userint9 PROC far
    pusha
    push es

    in al, 60h      
    mov ah, al	    
    and al, 7fh     

    push ax         
    push 2600
    mov bl, 0ah
    mov bh, 0
    push bx
    call show	    
    mov si, ax  

    cmp al, esc_key
    je btn_pressed

    cmp al, f_key
    je btn_pressed

    pop es
    popa
    jmp dword ptr cs:int9ptr 

btn_pressed:
    mov bx, ax
    in al, 61h  
    mov ah, al
    or al, 80h  
    out 61h, al 
    jmp $ + 2	
    mov al, ah  
    out 61h, al 
    mov al, 20h 
    out 20h, al 
    mov ax, bx
    cmp ah, al  

    je usr9_end 

    push es
    les	bx, @ms_dos_busy	

    mov	al, es:[bx]			
    pop	es

    or al, al   

    jnz usr9_end

    mov ax, si
    cmp al, f_key
    je f_key_pressed

    cmp al, esc_key
    je esc_key_pressed

    jmp usr9_end

f_key_pressed:
    push ds
    mov ax, DATA_SEG
    mov ds, ax         
    mov esi, 0

set_loop:
    cmp si, max_prg
    je loop_end

    bt si, 0
    jnc odd
    jmp if_end

odd:
    mov ax, 0
    mov al, clock[si] 
    add ax, increase_time
    cmp ax, 255
    jg if_end

    add clock[si], increase_time
if_end:

    mov bx, 0
    mov bl, clock[si] 
    mov ax, screen_addr[esi * 2]
    add ax, 62
    mov cl, 00000111b
    mov ch, 0

    push bx 
    push ax
    push cx
    call show	

    inc si  
    jmp set_loop       

loop_end:
    pop ds  
    jmp usr9_end

esc_key_pressed:
    call retint8

    call retint9
    mov ax, 3
    int 10h

    mov ax, 4c00h
    int 21h         

usr9_end:
    pop es 
    popa

    iret 
userint9 ENDP

userint8 PROC far
    pushad      
    push ds
    pushf   

    call cs:dword ptr int8ptr  

    push DATA_SEG
    pop ds       

    inc clk      

    push clk     
    push 2440
    mov bl, 0ah
    mov bh, 0
    push bx
    call show	 

    xor esi, esi
    mov si, nprg
    cmp si, fon  
    je interrupted_fon 

    cmp clockt[si], 1 	    
    jc interrupted_nfon     

    dec clockt[si]  	    

    pop ds
    popad                   
    iret

interrupted_fon:                      

    mov fonsp, sp
    mov nprg, max_prg - 1   
    jmp find_task

interrupted_nfon:                

    mov stp[esi * 2], sp       		
    mov init[si], hesitation    	

find_task:

    mov cx, max_prg         

    mov di, nprg
    add di, 1

    cmp di, max_prg
    jc skip_reset 

    sub di, max_prg

skip_reset:

    xor ebx, ebx
    mov bx, di

    cmp init[bx], ready      
    je start_task            

    cmp init[bx], hesitation 
    je resume_task           
        
    loop find_task

    mov sp, fonsp			
    mov nprg, fon

    pop ds			        
    popad					
    iret                    

resume_task:
    mov nprg, bx
    mov sp, stp[ebx * 2]
    mov al, clock[bx]
    mov clockt[bx], al      

    mov init[bx], execute   

    pop ds
    popad
    iret

start_task:
    mov nprg, bx

    mov sp, stp[ebx * 2]
    mov al, clock[bx]
    mov clockt[bx], al      

    mov init[bx], execute

    push names[ebx*2]		    
    push screen_addr[ebx*2]  	
    push 22                     
    call Vcount                 

    xor esi, esi
    mov si, nprg    

    mov init[si], close
    mov sp, fonsp
    mov nprg, fon

    pop ds
    popad
    iret                 		                 
userint8 ENDP

Vcount PROC near
    push bp  
    mov bp, sp
    sti             

    sub sp, 10      

    push es
    mov ax, 0b800h  
    mov es, ax

    mov ax, [bp + 4]    
    and ax, 31          
    mov [bp - 2], ax    

    mov cx, ax
    mov eax, 001b
    shl eax, cl
    dec eax             

    mov [bp - 6],eax
    mov dword ptr [bp - 10], 0  

    mov di, [bp + 6]            
    mov dx, [bp + 8]
    mov ah, 1011b
    mov al, dh

    cld
    stosw
    mov al, dl
    stosw

    std           
    add di,cx     
    add di,cx
    mov bx,di
    xor edx, edx

l20: 
    mov di,bx
    mov cx, [bp - 2]
    mov ah, 1010b       

draw_loop:
    mov al, '0'
    shr edx, 1
    jnc draw_zero
    mov al, '1'

draw_zero:
    stosw                      
    loop draw_loop

    inc dword ptr [bp - 10]        
    mov edx, dword ptr [bp - 10]
    and edx, [bp - 6]              
    jnz l20

    pop es              
    add sp, 10
    mov ax, [bp + 8]
    and ax, 0fh
    cli
    pop bp
    ret 6               
Vcount ENDP

show PROC near
    push bp         
    mov bp, sp
    pusha
    push es
    mov ax, 0b800h  
    mov es, ax
    std
    mov bx, [bp+8]  
    mov di, [bp+6]  
    mov ah, [bp+4]  
    mov cx, 4       

show_draw_loop:
    mov al, bl          
    and al, 00001111b

    cmp al, 10
    jl skip_trim            

    add al, 00000111b    
skip_trim:
    add al, 30h     
    stosw           
    shr bx, 4       
    loop show_draw_loop    

    pop es      
    popa
    pop bp
    ret 6       
show ENDP

begin:
    push DATA_SEG
    pop ds

    mov ax, 3
    int 10h

    mov ah, 10h                     	
    mov al, 3
    mov bl, 0
    int 10h

    mov cx, max_prg
    xor esi, esi
    mov bx, 4

b10:
    mov screen_addr[esi * 2], bx 
    mov init[si], ready          

    add bx, 80
    inc si
    loop b10

    cli	

    mov	ah, 34h
    int	21h	        
    mov	word ptr @ms_dos_busy, bx
    mov	word ptr @ms_dos_busy + 2, es

    call setint8    
    call setint9    

    lss sp, sssp    
    mov nprg, fon

    push 'FN'
    push 1800
    push 30
    call Vcount     

    call retint8		
    call retint9
    sti

    mov ax, 4c00h
    int 21h
CODE_SEG ENDS
end begin