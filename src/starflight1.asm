;
;                               S T A R   F L I G H T
;                                 horizontal version
;                              created in 1997 by Rysie
;

.386
code segment use16
assume cs:code,ds:code
org 100h
start:
     mov ax,13h
     int 10h

     lea si,random
     mov word ptr [si],dx
     mov cx,500
     randomize:
        mov bx,[si]
        add bx,dx
        mov word ptr [si],bx
        mov ax,63999
        mul bx
        lodsw
     loop randomize

     again:
      push 0a000h
      pop es
      lea si,random
      mov cx,100
      pix:
      push cx
          mov cx,5
          drawme:
          mov bx,[si]
          mov es:[bx],word ptr 0
          cmp bx,63998
          jbe oakiedoakie
           mov [si],word ptr 0
          oakiedoakie:
          add bx,cx
          mov es:[bx],bl
          sub bx,cx
          add word ptr [si],cx
          lodsw
          loop drawme
          pop cx
      loop pix

     mov dx,3dah
     retr1:
         in al,dx
         test al,8
     je retr1

     in al,60h
     cmp al,1
     jne again

     mov ax,3h
     int 10h
     ret

; -----------
random dw 500 dup (?)

code ends
end start
