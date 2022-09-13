;
;                               S T A R   F L I G H T
;                                    3d version
;                              created in 1997 by Rysie
;

.386
code segment use16
org 100h
assume cs:code

start:
   int 1ah                      ; initialize random seed value
   mov word ptr cs:[seed],dx    ;

   mov ax,13h                   ; ahh... 13h.
   int 10h                      ;

   push 0a000h                  ; VGA segment to ES
   pop es                       ;

   lea si,randoms               ; create all stars by setting their
   mov cx,starsnumber           ; X, Y and Z coordinates
   generate:
       push cx
       mov cx,320
       call random
       sub dx,160
       mov word ptr cs:[si],dx   ; X coord varies from -160 to 160
       mov cx,200
       call random
       sub dx,100
       mov word ptr cs:[si+2],dx ; Y coord varies from -100 to 100
       mov cx,50
       call random
       add dx,10
       mov word ptr cs:[si+4],dx ; Z coord varies from 10 to 60
       add si,6
       pop cx
   loop generate

   main:
       cli                      ; disable interrupts

       mov dx,3dah              ;
       retr1:                   ;
          in al,dx              ; wait for retrace
          test al,8             ;
       je retr1                 ;

       call computecoords         ; compute 2D coordinates and display stars

       in al,60h                ; test keyboard
       cmp al,1                 ; ESC pressed?
   jne main                     ; no, go back

   mov ax,3h                    ; back to 3h mode
   int 10h                      ;

   ret                          ; and exit program

; ------------------
computecoords proc near
   lea si,randoms

   mov cx,starsnumber
   everything:
       mov bx,word ptr cs:[si+4]  ; get Z coordinate into BX

       lodsw                      ; get X coordinate into AX
       movsx dx,ah                ; sign-extend it into DX
       shl ax,5                   ; multiply by 32
       idiv bx                    ; signed division by Z coord
       add ax,160                 ; add 160
       mov real_x,ax              ; and put into real_x variable

       lodsw                      ; get Y coordinate into AX
       movsx dx,ah                ;
       shl ax,5                   ;
       idiv bx                    ;      (as above)
       add ax,100                 ;
       mov real_y,ax              ;

       dec bx                     ; decrement Z coordinate
       jnz notzero                ; has it already been zeroed?
       mov bl,50                  ; yep, assign it a new value of 50
       notzero:
       mov cs:[si],bx             ; new Z coordinate into memory

       lodsw                      ; prepare to lodsw at next iteration
                                  ; we can use inc si/inc si, but lodsw is shorter

       call pixel                 ; display pixel
    loop everything
ret
endp


pixel proc near
   push si

   mov ax,real_y
   mov di,real_x

   cmp ax,200                     ; "cutting edges" -- do NOT display
   jae nopix                      ; if it doesn't fit into 320x200 screen
   cmp di,320                     ;
   jae nopix                      ;

   mov bx,ax                      ;
   xchg ah,al                     ;
   shl bx,6                       ; DI = 320*real_y + real_x
   add ax,bx                      ;
   add di,ax                      ;

   mov dl,cs:[si-2]               ;
   shr dl,2                       ; set pixel color (that will be grey)
   not dl                         ;
   add dl,33                      ;
   mov es:[di],dl                 ; and finally display

   nopix:
   mov bx,cx                      ; erase old stars
   dec bx                         ;
   shl bx,1                       ;
   add bx,offset oldpos           ;
   mov si,cs:[bx]                 ;
   mov cs:[bx],di                 ; remember new values in old stars array
   cmp si,64000                   ; fit to screen
   jae quitproc                   ; jump if above or equal 64000 (=end of screen)
   mov es:[si],word ptr 0         ; kill the pixel! kill it!

   quitproc:
   pop si
ret
endp


random proc near        ; generating pseudo-random value
   mov ax,seed          ;  input: cx as range
   add ax,1234          ; output: dx as value
   xor al,ah
   rol ah,4
   add ax,4321
   xor ah,al
   mov seed,ax
   xor dx,dx
   div cx
ret
endp

; ------------------
starsnumber  equ 512              ; stars to be animated
seed    dw  ?                     ; randseed
randoms dw  starsnumber*3 dup (?) ; stars' positions
oldpos  dw  starsnumber dup (?)   ; old stars' positions
real_x  dw  ?                     ; 2D star X coord
real_y  dw  ?                     ; 2D star Y coord

code ends
end start
