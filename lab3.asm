
.386

Node struc
   namex db 5 dup (?)
   field1 dw 5 dup (?)
Node ENDS


Data1 segment use16 
  I_struc db ?
  I_namex db ?
  A1 Node 6 dup (<>)
address dd Code2_begin

Data1 ends


Data2 segment use16 
  Db 'node1','node2','node3','node4','node5','node6'
Data2 ends


Code1 segment use16 
assume  cs:Code1, ds:Data1
Code1_begin:

    mov ax, Data1
    mov ds, ax

    mov cx, 0

    L1_start:
        mov I_struc, cl

        
        lea bp, A1  
        mov bx ,bp  
        mov ax, size Node 
        imul ax, cx
        add bp, ax 

        
        push cx
        mov cx, 0

        L2_start:

         mov I_namex, cl

            push bx
            mov si, bp

            mov ax, size Node
            mov dx, 2
            imul ax, cx  
            imul dx, cx  
            add bx, ax   
            add si, dx   

            cmp cl , I_struc
            jl short L22
            mov ax ,size Node
            add bx , ax

            L22:
            mov word ptr [si + Node.field1], bx

            pop bx

            inc cx
            cmp cx, 5
            jl L2_start

        pop cx
        inc cx
        cmp cx, 6
        jl L1_start

    jmp dword ptr address
 mov ax,4c00h
    int 21h
              
 code1        ENDS	

Code2 segment use16 
    assume cs:Code2 , es:Data1, ds:Data2

    Code2_begin:

     mov ax, Data2
        mov ds, ax 
        mov ax, Data1
        mov es, ax  

       mov si, 0 

        lea bp, A1.namex 
        mov cx, 0
        mov ax, SIZE Node

        L3_start:
            
            push cx
            mov di, bp 
            
            mov cx, 5
            rep movsb
            
            add bp, ax 
            pop cx
            inc cx
            cmp cx, 6

            jl L3_start
       
              nop         
              nop
              mov      ax,4c00h       
              int      21h	
              
 code2        ENDS		
              end      Code1_begin	