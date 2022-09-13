;
;                  4 0 0   C O L O R S   I N   T E X T   M O D E
;                            created in 1997 by Rysie
;

.286
code segment
org 100h
assume cs:code

start:
      mov ah,1                                 ; cursor begone
      mov cx,0ffffh
      int 10h

      lea di,palette                           ; setup color palette
      mov cx,64
      repeat:
        lea dx,thestring                       ; output the string...
        mov ah,9                               ;  ...let's say 64 times, because why not
        int 21h
        mov cs:[di+384*3-3],byte ptr 63        ; end of palette will be
        mov cs:[di+384*3-2],byte ptr 0         ;  magenta
        mov cs:[di+384*3-1],byte ptr 63        ;
        add di,3
      loop repeat

      lea di,palette                           ; creating palette contents
      mov cl,64                                ;
      colors:                                  ; this is the longest part of the code
               push cx                         ;
               dec cl
               mov al,cl
               not al
               mov cs:[di],byte ptr 63         ; magenta -> red
               mov cs:[di+1],byte ptr 0
               mov cs:[di+2],cl

               mov cs:[di+64*3],byte ptr 63    ; red -> yellow
               mov cs:[di+64*3+1],al
               mov cs:[di+64*3+2],byte ptr 0

               mov cs:[di+128*3],cl            ; yellow -> green
               mov cs:[di+128*3+1],byte ptr 63
               mov cs:[di+128*3+2],byte ptr 0

               mov cs:[di+192*3],byte ptr 0    ; green -> cyan
               mov cs:[di+192*3+1],byte ptr 63
               mov cs:[di+192*3+2],al

               mov cs:[di+256*3],byte ptr 0    ; cyan -> blue
               mov cs:[di+256*3+1],cl
               mov cs:[di+256*3+2],byte ptr 63

               mov cs:[di+320*3],al            ; blue -> magenta
               mov cs:[di+320*3+1],byte ptr 0
               mov cs:[di+320*3+2],byte ptr 63

               add di,3
               pop cx
      loop colors

; ------------------------------- main loop ------------------------------

   again:
     cli                        ; interrupts begone

     mov dx,3dah                ;
     retrace:                   ;
         in al,dx               ; wait for horizontal sync
         test al,8              ;
     jz retrace                 ;


     lea si,palette       ; rotate the palette - gives the effect of 'colors flow'

     mov ax,cs:[si]       ; remember the first color
     mov bl,cs:[si+2]     ;

     lea di,palette       ; ...and shift the rest of the pallette up
     add si,3             ;
     mov cx,3*397         ;
     rep movsb            ;

     mov cs:[di],ax       ; Matthew 20:16: So the last will be first, and the first last
     mov cs:[di+2],bl     ; In our case, move color from the beginning of the palette to the end


     lea si,palette             ; load palette offset to SI register

     mov di,398                 ; color 398 lines

     m_loop:
           mov dx,3dah          ; shift the palette only when bit 1 from port 3DA is set,
           h_retr1:             ;  which means waiting for vertical retrace
               in al,dx         ;
               and al,1         ;
           jz h_retr1           ;
           push dx              ; remember 3DA value

           mov al,7             ; color to replace (7 == normal text color)
                                ;
           mov dx,3c8h          ; Store color number in 3C8 port
           out dx,al            ;
           mov cx,3             ; 3, because we're going to put R, G, B values
           inc dx               ;  from z CS:[SI], which is 'palette' variable offset
           rep outsb            ;

           pop dx               ; recall 3DA value
           h_retr2:             ;
               in al,dx         ; wait for horizontal and vertical retrace
               and al,1         ;
           jnz h_retr2          ;

      dec di                    ; display the next line
      jnz m_loop                ; are we done with all 398 values?

      in al,60h                 ; check keyboard input for Esc key pressed
      cmp al,1                  ;
    jne again                   ; Not pressed? Start over!

      mov ax,3h                 ; Clear the screen
      int 10h                   ;
   ret                          ;  ...and goodbye


  thestring db 'coded by Rysie, Esc to stop $'    ; hmmm what could it be?
  palette   db 398*3 dup (?)                      ; 398 RGB colors

code ends
end start
