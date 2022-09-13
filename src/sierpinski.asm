;
;                      S I E R P I N S K I ' S   G A S K E T
;                            created in 1997 by Rysie
;

.286
code segment
org 100h
assume cs:code,ds:code

; ------------

start:
     mov al,13h                 ;
     int 10h                    ; 320x200x256

     push 0a000h                ; video segment -> stack
     pop es                     ; ES <- video segment

     main:
         push dx                ; point Y -> stack
         push bx                ; point X -> stack
         push cx                ; randseed -> stack
         mov ah,2ch             ; get current time
         int 21h                ; (slows down program like hell!)
         pop cx                 ; randseed <- stack
         add cx,dx              ; randseed := randseed + 1/100 sec

         mov bx,cx              ;
         add bx,ax              ;
         ror bx,3               ; generate "random" number (0, 1 or 2)
         mov cx,bx              ; and put it to dx
         mov ax,3               ;
         mul bx                 ;

         shl dx,2               ;
         lea si,points          ; choose vertex
         add si,dx              ;

         pop bx                 ; point X <- stack
         pop dx                 ; point Y <- stack
         push ax                ; color -> stack (will be "random", too)

         lodsw                  ; get vertex X coordinate
         add ax,bx              ; estimate halfway
         shr ax,1               ;  between vertex and point X
         mov bx,ax              ; point X <- new point X

         lodsw                  ; get vertex Y coordinate
         add ax,dx              ; estimate halfway
         shr ax,1               ;  between vertex and point Y
         mov dx,ax              ; point Y <- new point Y

         push dx                ; point Y -> stack
         mov di,320             ;
         mul di                 ; multiply point Y by 320
         mov di,bx              ; move point X to DI
         add di,ax              ; add point Y to DI
         pop dx                 ; point Y <- stack

         pop ax                 ; color <- stack
         stosb                  ; display it

         in al,60h              ;
         cmp al,1               ; esc pressed?
     jne main                   ;

    mov ax,3                    ; restore text mode
    int 10h                     ;

    ret                         ; finish it

; ------------

points dw 159,0                 ;
       dw 0,199                 ; vertex coordinates
       dw 319,199               ;

code ends
end start
